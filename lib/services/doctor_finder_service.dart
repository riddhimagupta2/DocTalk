import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/doctor_model.dart';

class DoctorFinderService {
  // ⚠️ REPLACE WITH YOUR GOOGLE PLACES API KEY
  // Get it from: console.cloud.google.com
  // Enable: Places API + Maps SDK for Android
  static const String _placesApiKey = 'AIzaSyDXAGOvtcPNQzHNxqui5uEBATFpApi0bsw';

  /// Get user's current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled');
        return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permissions denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permissions permanently denied');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('✅ Location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  /// Find nearby doctors using Google Places API
  Future<List<DoctorModel>> findNearbyDoctors({
    required double latitude,
    required double longitude,
    String specialist = 'doctor',
    int radius = 5000, // 5km
  }) async {
    if (_placesApiKey == 'YOUR_GOOGLE_PLACES_API_KEY') {
      print('❌ Google Places API key not set!');
      return [];
    }

    try {
      // Build search query based on specialist type
      String keyword = _buildSearchKeyword(specialist);

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
            '?location=$latitude,$longitude'
            '&radius=$radius'
            '&type=doctor'
            '&keyword=$keyword'
            '&key=$_placesApiKey',
      );

      print('📍 Searching for: $keyword near ($latitude, $longitude)');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK') {
          final List results = data['results'] ?? [];
          print('✅ Found ${results.length} doctors');

          return results
              .take(10) // Top 10 results
              .map((json) => DoctorModel.fromPlacesJson(json))
              .toList();
        } else {
          print('⚠️ Places API returned status: ${data['status']}');
          return [];
        }
      } else {
        print('❌ Places API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error finding doctors: $e');
      return [];
    }
  }

  /// Build search keyword based on specialist type
  String _buildSearchKeyword(String specialist) {
    final Map<String, String> specialistKeywords = {
      'General Physician': 'general physician clinic',
      'ENT Specialist': 'ent specialist doctor',
      'Cardiologist': 'cardiologist heart doctor',
      'Neurologist': 'neurologist brain doctor',
      'Dermatologist': 'dermatologist skin doctor',
      'Gastroenterologist': 'gastroenterologist stomach doctor',
      'Orthopedic': 'orthopedic bone doctor',
      'Pulmonologist': 'pulmonologist lung doctor',
      'Psychiatrist': 'psychiatrist mental health',
      'Gynecologist': 'gynecologist women doctor',
      'Urologist': 'urologist kidney doctor',
      'Ophthalmologist': 'ophthalmologist eye doctor',
      'Pediatrician': 'pediatrician child doctor',
    };

    return specialistKeywords[specialist] ?? 'doctor clinic';
  }

  /// Get distance between two points in km
  double calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km
  }
}