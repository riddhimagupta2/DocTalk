import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/doctor_model.dart';

class _CacheEntry {
  final List<DoctorModel> doctors;
  final DateTime timestamp;
  _CacheEntry(this.doctors) : timestamp = DateTime.now();
  bool get isValid => DateTime.now().difference(timestamp).inMinutes < 5;
}

class DoctorFinderService {
  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // In-memory cache to prevent duplicate slow network calls
  static final Map<String, _CacheEntry> _memoryCache = {};

  // ── Ultra-Fast Location Detection ─────────────────────────────────────

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // 1. FAST PATH: Check last known position first (<20ms response)
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          developer.log('[DoctorFinder] Using last known location instantly');
          // Trigger fresh location in background if needed
          _refreshLocationInBackground();
          return lastKnown;
        }
      } catch (_) {}

      // 2. Fallback: Quick GPS query with short timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 3),
      );
    } catch (_) {
      return null;
    }
  }

  void _refreshLocationInBackground() async {
    try {
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 4),
      );
    } catch (_) {}
  }

  /// Fast reverse geocoding with 2-second timeout
  Future<String> getCityFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng).timeout(
        const Duration(seconds: 2),
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final locality = p.locality?.isNotEmpty == true
            ? p.locality
            : (p.subAdministrativeArea?.isNotEmpty == true
                ? p.subAdministrativeArea
                : p.administrativeArea);
        final subLocality = p.subLocality?.isNotEmpty == true ? '${p.subLocality}, ' : '';
        if (locality != null && locality.isNotEmpty) {
          return '$subLocality$locality';
        }
      }
    } catch (_) {}
    return '';
  }

  // ── Parallel Real Doctor Discovery (< 2 seconds) ──────────────────────

  Future<List<DoctorModel>> findNearbyDoctors({
    required double latitude,
    required double longitude,
    required String specialist,
    int radiusMeters = 15000,
  }) async {
    // Check cache first
    final cacheKey = '${(latitude * 50).round()}_${(longitude * 50).round()}_${specialist.toLowerCase()}';
    final cached = _memoryCache[cacheKey];
    if (cached != null && cached.isValid && cached.doctors.isNotEmpty) {
      developer.log('[DoctorFinder] Returning ${cached.doctors.length} doctors from cache');
      return cached.doctors;
    }

    final results = <DoctorModel>[];
    final seenKeys = <String>{};

    void addUniqueDoctor(DoctorModel doc) {
      final cleanName = doc.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      final key = '${cleanName}_${(doc.latitude * 100).round()}_${(doc.longitude * 100).round()}';
      if (!seenKeys.contains(key) && doc.name.trim().isNotEmpty) {
        seenKeys.add(key);
        results.add(doc);
      }
    }

    // Run Overpass and Nominatim in PARALLEL to slash latency
    final futures = <Future<List<DoctorModel>>>[
      _fetchFromNominatimParallel(latitude, longitude, specialist, radiusMeters),
      _fetchFromOverpass(latitude, longitude, specialist, radiusMeters),
    ];

    final responses = await Future.wait(futures);
    for (final list in responses) {
      for (final d in list) {
        addUniqueDoctor(d);
      }
    }

    // Optional Google Places fallback only if both returned nothing
    final apiKey = _apiKey;
    if (results.isEmpty && apiKey.isNotEmpty) {
      try {
        final googleDocs = await _fetchFromGooglePlaces(
          lat: latitude,
          lng: longitude,
          specialist: specialist,
          radius: radiusMeters,
          apiKey: apiKey,
        );
        for (final d in googleDocs) {
          addUniqueDoctor(d);
        }
      } catch (_) {}
    }

    // Calculate exact distances & sort
    final maxKm = radiusMeters / 1000.0;
    final List<DoctorModel> processed = [];

    for (final doc in results) {
      double distKm = doc.distanceKm;
      if (latitude != 0.0 && longitude != 0.0 && doc.latitude != 0.0 && doc.longitude != 0.0) {
        final distMeters = Geolocator.distanceBetween(latitude, longitude, doc.latitude, doc.longitude);
        distKm = double.parse((distMeters / 1000).toStringAsFixed(1));
      }

      processed.add(doc.copyWith(distanceKm: distKm));
    }

    // Filter within reasonable radius (up to 1.5x of search radius)
    final withinRadius = processed.where((d) => d.distanceKm <= (maxKm * 1.5)).toList();
    final finalList = withinRadius.isNotEmpty ? withinRadius : processed;

    // Strict sort: closest first
    finalList.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    if (finalList.isNotEmpty) {
      _memoryCache[cacheKey] = _CacheEntry(finalList);
    }

    return finalList;
  }

  /// OpenStreetMap Overpass with 3.5-second timeout
  Future<List<DoctorModel>> _fetchFromOverpass(
    double lat,
    double lng,
    String specialist,
    int radiusMeters,
  ) async {
    final query = '[out:json][timeout:4];'
        '('
        'node["amenity"~"hospital|clinic|doctors"](around:$radiusMeters,$lat,$lng);'
        'node["healthcare"](around:$radiusMeters,$lat,$lng);'
        'way["amenity"~"hospital|clinic|doctors"](around:$radiusMeters,$lat,$lng);'
        ');'
        'out center 25;';

    final mirrors = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
    ];

    for (final mirror in mirrors) {
      try {
        final uri = Uri.parse('$mirror?data=${Uri.encodeComponent(query)}');
        final response = await http.get(
          uri,
          headers: {'User-Agent': 'DocTalkHealthApp/1.0'},
        ).timeout(const Duration(milliseconds: 3500));

        if (response.statusCode == 200) {
          final body = json.decode(response.body) as Map<String, dynamic>;
          final elements = body['elements'] as List<dynamic>? ?? [];

          final doctors = <DoctorModel>[];
          for (final item in elements) {
            if (item is Map<String, dynamic>) {
              final tags = item['tags'] as Map<String, dynamic>?;
              if (tags != null && (tags.containsKey('name') || tags.containsKey('amenity') || tags.containsKey('healthcare'))) {
                doctors.add(DoctorModel.fromOsmJson(
                  item,
                  specialist: specialist,
                  userLat: lat,
                  userLng: lng,
                ));
              }
            }
          }
          if (doctors.isNotEmpty) return doctors;
        }
      } catch (_) {
        // Quiet failover to next mirror
      }
    }
    return [];
  }

  /// Parallel Nominatim Search - queries doctor, clinic, hospital simultaneously
  Future<List<DoctorModel>> _fetchFromNominatimParallel(
    double lat,
    double lng,
    String specialist,
    int radiusMeters,
  ) async {
    final delta = (radiusMeters / 111000.0).clamp(0.05, 0.35);
    final left = lng - delta;
    final top = lat + delta;
    final right = lng + delta;
    final bottom = lat - delta;

    final terms = <String>['clinic', 'hospital', 'doctor'];
    if (specialist.isNotEmpty && specialist.toLowerCase() != 'all') {
      terms.insert(0, specialist);
    }

    final futures = terms.map((term) async {
      try {
        final url =
            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(term)}&format=json&viewbox=$left,$top,$right,$bottom&bounded=1&limit=10&addressdetails=1';
        final response = await http.get(
          Uri.parse(url),
          headers: {'User-Agent': 'DocTalkHealthApp/1.0'},
        ).timeout(const Duration(milliseconds: 3200));

        if (response.statusCode == 200) {
          final items = json.decode(response.body) as List<dynamic>? ?? [];
          return items
              .whereType<Map<String, dynamic>>()
              .map((item) => DoctorModel.fromNominatimJson(
                    item,
                    specialist: specialist,
                    userLat: lat,
                    userLng: lng,
                  ))
              .toList();
        }
      } catch (_) {}
      return <DoctorModel>[];
    });

    final resultsLists = await Future.wait(futures);
    final combined = <DoctorModel>[];
    for (final list in resultsLists) {
      combined.addAll(list);
    }
    return combined;
  }

  /// Google Places API
  Future<List<DoctorModel>> _fetchFromGooglePlaces({
    required double lat,
    required double lng,
    required String specialist,
    required int radius,
    required String apiKey,
  }) async {
    try {
      final keyword = specialist.toLowerCase() == 'all' ? 'hospital doctor clinic' : specialist;
      final url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=$radius&keyword=${Uri.encodeComponent(keyword)}&key=$apiKey';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 3),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        if (body['status'] == 'OK') {
          final results = body['results'] as List<dynamic>? ?? [];
          return results
              .whereType<Map<String, dynamic>>()
              .map((item) => DoctorModel.fromPlacesJson(
                    item,
                    specialist: specialist,
                    userLat: lat,
                    userLng: lng,
                  ))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }
}
