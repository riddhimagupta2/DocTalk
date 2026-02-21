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

  DoctorModel({
    required this.placeId,
    required this.name,
    required this.specialization,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.distanceKm = 0.0,
    this.isAvailableToday = true,
    this.availableSlots = const [],
    this.phone = '',
    this.experience = '5+ years',
    this.consultationFee = 500.0,
  });

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
  };
}