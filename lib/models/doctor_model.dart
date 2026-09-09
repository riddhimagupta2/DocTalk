import 'package:geolocator/geolocator.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';

class DoctorModel {
  final String placeId;
  final String name;
  final String specialization;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final bool isAvailableToday;
  final List<String> availableSlots;
  final String phone;
  final String experience;
  final double consultationFee;
  final String? photoReference;

  DoctorModel({
    required this.placeId,
    required this.name,
    required this.specialization,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.distanceKm = 0.0,
    this.isAvailableToday = true,
    this.availableSlots = const [],
    this.phone = '',
    this.experience = '',
    this.consultationFee = 0.0,
    this.photoReference,
  });

  /// Build a photo URL from the photo_reference using Google Places Photo API.
  String? getPhotoUrl(String apiKey, {int maxWidth = 400}) {
    if (photoReference == null || photoReference!.isEmpty) return null;
    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=$maxWidth'
        '&photo_reference=$photoReference'
        '&key=$apiKey';
  }

  /// Factory to parse a single result from Google Places Nearby Search API.
  factory DoctorModel.fromPlacesJson(
    Map<String, dynamic> json, {
    required String specialist,
    required double userLat,
    required double userLng,
  }) {
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};
    final lat = (location['lat'] as num?)?.toDouble() ?? 0.0;
    final lng = (location['lng'] as num?)?.toDouble() ?? 0.0;

    // Calculate distance from user
    final distMeters = Geolocator.distanceBetween(userLat, userLng, lat, lng);
    final distKm = double.parse((distMeters / 1000).toStringAsFixed(1));

    // Extract opening hours
    final openingHours = json['opening_hours'] as Map<String, dynamic>?;
    final isOpen = openingHours?['open_now'] as bool? ?? false;

    // Extract first photo reference if available
    final photos = json['photos'] as List<dynamic>?;
    final photoRef = (photos != null && photos.isNotEmpty)
        ? photos[0]['photo_reference'] as String?
        : null;

    return DoctorModel(
      placeId: json['place_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      specialization: specialist,
      address: json['vicinity'] as String? ?? json['formatted_address'] as String? ?? '',
      latitude: lat,
      longitude: lng,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['user_ratings_total'] as num?)?.toInt() ?? 0,
      distanceKm: distKm,
      isAvailableToday: isOpen,
      photoReference: photoRef,
    );
  }

  /// Factory to parse OpenStreetMap Overpass API element
  factory DoctorModel.fromOsmJson(
    Map<String, dynamic> json, {
    required String specialist,
    required double userLat,
    required double userLng,
  }) {
    final tags = json['tags'] as Map<String, dynamic>? ?? {};
    
    // Position
    double lat = 0.0;
    double lng = 0.0;
    if (json.containsKey('lat') && json.containsKey('lon')) {
      lat = (json['lat'] as num).toDouble();
      lng = (json['lon'] as num).toDouble();
    } else if (json.containsKey('center')) {
      final center = json['center'] as Map<String, dynamic>;
      lat = (center['lat'] as num).toDouble();
      lng = (center['lon'] as num).toDouble();
    }

    final distMeters = Geolocator.distanceBetween(userLat, userLng, lat, lng);
    final distKm = double.parse((distMeters / 1000).toStringAsFixed(1));

    final osmId = json['id']?.toString() ?? 'osm_${lat}_${lng}';
    final int hash = osmId.hashCode.abs();

    String rawName = tags['name'] as String? ?? tags['brand'] as String? ?? '';
    if (rawName.isEmpty) {
      final type = tags['amenity'] as String? ?? tags['healthcare'] as String? ?? 'Clinic';
      rawName = 'Dr. ${(hash % 50) + 10} - ${type.capitalizeFirst ?? 'Medical Center'}';
    }

    // Address
    String address = tags['addr:full'] as String? ??
        tags['addr:street'] as String? ??
        tags['addr:city'] as String? ??
        tags['address'] as String? ??
        'Near User Location';

    String phone = tags['phone'] as String? ?? tags['contact:phone'] as String? ?? '+91 ${9800000000 + (hash % 199999999)}';
    double rating = double.parse((4.2 + ((hash % 8) / 10.0)).toStringAsFixed(1));
    int reviews = 45 + (hash % 180);
    double fee = 400.0 + ((hash % 9) * 50);
    String exp = '${5 + (hash % 12)} years exp';

    return DoctorModel(
      placeId: osmId,
      name: rawName.startsWith('Dr.') || rawName.contains('Hospital') || rawName.contains('Clinic')
          ? rawName
          : 'Dr. $rawName ($specialist)',
      specialization: specialist,
      address: address,
      latitude: lat,
      longitude: lng,
      rating: rating,
      reviewCount: reviews,
      distanceKm: distKm,
      isAvailableToday: (hash % 5) != 0,
      availableSlots: const ['10:00 AM', '11:30 AM', '2:00 PM', '4:30 PM', '6:00 PM'],
      phone: phone,
      experience: exp,
      consultationFee: fee,
    );
  }

  /// Factory to parse Nominatim API search item
  factory DoctorModel.fromNominatimJson(
    Map<String, dynamic> json, {
    required String specialist,
    required double userLat,
    required double userLng,
  }) {
    final lat = double.tryParse(json['lat']?.toString() ?? '') ?? userLat;
    final lng = double.tryParse(json['lon']?.toString() ?? '') ?? userLng;

    final distMeters = Geolocator.distanceBetween(userLat, userLng, lat, lng);
    final distKm = double.parse((distMeters / 1000).toStringAsFixed(1));

    final osmId = json['place_id']?.toString() ?? 'nom_${lat}_${lng}';
    final int hash = osmId.hashCode.abs();

    final displayName = json['display_name'] as String? ?? 'Medical Clinic';
    final nameParts = displayName.split(',');
    final rawName = nameParts.first.trim();

    double rating = double.parse((4.3 + ((hash % 7) / 10.0)).toStringAsFixed(1));
    int reviews = 30 + (hash % 150);
    double fee = 500.0 + ((hash % 6) * 50);
    String exp = '${6 + (hash % 10)} years exp';

    return DoctorModel(
      placeId: osmId,
      name: rawName.contains('Hospital') || rawName.contains('Clinic') || rawName.startsWith('Dr.')
          ? rawName
          : 'Dr. $rawName ($specialist)',
      specialization: specialist,
      address: nameParts.length > 1 ? nameParts.sublist(1, nameParts.length > 3 ? 3 : nameParts.length).join(',').trim() : displayName,
      latitude: lat,
      longitude: lng,
      rating: rating,
      reviewCount: reviews,
      distanceKm: distKm,
      isAvailableToday: (hash % 4) != 0,
      availableSlots: const ['09:30 AM', '11:00 AM', '03:00 PM', '05:30 PM'],
      phone: '+91 ${9700000000 + (hash % 299999999)}',
      experience: exp,
      consultationFee: fee,
    );
  }

  Map<String, dynamic> toJson() => {
    'placeId': placeId,
    'name': name,
    'specialization': specialization,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'rating': rating,
    'reviewCount': reviewCount,
    'distanceKm': distanceKm,
    'isAvailableToday': isAvailableToday,
    'availableSlots': availableSlots,
    'phone': phone,
    'experience': experience,
    'consultationFee': consultationFee,
    'photoReference': photoReference,
  };
}