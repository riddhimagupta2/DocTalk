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
  final String imageUrl;
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
    this.imageUrl = '',
    this.availableSlots = const [],
    this.phone = '',
    this.experience = '5+ years',
    this.consultationFee = 500.0,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? 'General Physician',
      address: json['vicinity'] ?? json['address'] ?? '',
      latitude: (json['geometry']?['location']?['lat'] ?? json['latitude'] ?? 0).toDouble(),
      longitude: (json['geometry']?['location']?['lng'] ?? json['longitude'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 4.5).toDouble(),
      reviewCount: json['user_ratings_total'] ?? json['reviewCount'] ?? 0,
      distanceKm: (json['distanceKm'] ?? 0.0).toDouble(),
      isAvailableToday: json['isAvailableToday'] ?? true,
      imageUrl: json['imageUrl'] ?? '',
      availableSlots: List<String>.from(json['availableSlots'] ?? []),
      phone: json['phone'] ?? '',
      experience: json['experience'] ?? '5+ years',
      consultationFee: (json['consultationFee'] ?? 500.0).toDouble(),
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
    'imageUrl': imageUrl,
    'availableSlots': availableSlots,
    'phone': phone,
    'experience': experience,
    'consultationFee': consultationFee,
  };
}