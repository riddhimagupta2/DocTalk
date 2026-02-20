class DoctorModel {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? userRatingsTotal;
  final String? phoneNumber;
  final bool? isOpenNow;
  final String? photoReference;

  DoctorModel({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.userRatingsTotal,
    this.phoneNumber,
    this.isOpenNow,
    this.photoReference,
  });

  factory DoctorModel.fromPlacesJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return DoctorModel(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? 'Doctor',
      address: json['vicinity'] ?? json['formatted_address'] ?? 'Address not available',
      latitude: location['lat']?.toDouble() ?? 0.0,
      longitude: location['lng']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['user_ratings_total'],
      phoneNumber: json['formatted_phone_number'],
      isOpenNow: json['opening_hours']?['open_now'],
      photoReference: json['photos']?[0]?['photo_reference'],
    );
  }

  String get ratingText => rating != null ? '⭐ ${rating!.toStringAsFixed(1)}' : 'No rating';
  String get distanceText => 'Nearby'; // You can calculate actual distance if needed
}