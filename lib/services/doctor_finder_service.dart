import 'package:geolocator/geolocator.dart';
import '../models/doctor_model.dart';

class DoctorFinderService {
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<DoctorModel>> findNearbyDoctors({
    required double latitude,
    required double longitude,
    required String specialist,
    int radius = 5000,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return mock doctors (replace this with real API call if available)
    return _generateMockDoctors(latitude, longitude, specialist);
  }

  List<DoctorModel> _generateMockDoctors(
      double lat, double lng, String specialist) {
    const offsets = [
      [0.008, 0.005],
      [-0.006, 0.010],
      [0.012, -0.003],
      [-0.009, -0.008],
      [0.003, 0.015],
    ];

    final names = [
      'Dr. Anika Sharma',
      'Dr. Rajesh Patel',
      'Dr. Priya Menon',
      'Dr. Arjun Singh',
      'Dr. Deepa Nair',
    ];

    final hospitals = [
      'City Care Hospital, MG Road',
      'Apollo Clinic, Sector 17',
      'Max Healthcare, Ring Road',
      'Fortis Medical Centre, Phase 2',
      'Medanta Clinic, Civil Lines',
    ];

    final phones = [
      '+91 98765 43210',
      '+91 87654 32109',
      '+91 76543 21098',
      '+91 65432 10987',
      '+91 54321 09876',
    ];

    final fees = [500.0, 700.0, 600.0, 800.0, 550.0];
    final experiences = [
      '8 years',
      '12 years',
      '6 years',
      '15 years',
      '10 years'
    ];
    final ratings = [4.8, 4.6, 4.9, 4.7, 4.5];
    final reviews = [120, 98, 210, 156, 87];

    final slots = [
      ['10:00 AM', '11:30 AM', '2:00 PM', '4:30 PM'],
      ['9:00 AM', '10:30 AM', '3:00 PM', '5:00 PM'],
      ['11:00 AM', '1:00 PM', '3:30 PM', '6:00 PM'],
      ['9:30 AM', '12:00 PM', '2:30 PM', '4:00 PM'],
      ['10:00 AM', '12:30 PM', '3:00 PM', '5:30 PM'],
    ];

    return List.generate(5, (i) {
      final dLat = lat + offsets[i][0];
      final dLng = lng + offsets[i][1];
      final dist = Geolocator.distanceBetween(lat, lng, dLat, dLng) / 1000;

      return DoctorModel(
        placeId: 'mock_doctor_$i',
        name: names[i],
        specialization: specialist,
        address: hospitals[i],
        latitude: dLat,
        longitude: dLng,
        rating: ratings[i],
        reviewCount: reviews[i],
        distanceKm: double.parse(dist.toStringAsFixed(1)),
        isAvailableToday: i != 2,
        availableSlots: slots[i],
        phone: phones[i],
        experience: experiences[i],
        consultationFee: fees[i],
      );
    });
  }
}
