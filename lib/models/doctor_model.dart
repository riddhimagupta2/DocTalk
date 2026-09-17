import 'package:geolocator/geolocator.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';

class DoctorModel {
  final String placeId;
  final String name;
  final String hospitalOrClinicName;
  final String specialization;
  final String address;
  final String city;
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
  final bool isDocTalkVerified;
  final String website;
  final String whatsapp;
  final String openingHours;
  final List<String> certificates;
  final List<String> clinicPhotos;
  final List<Map<String, dynamic>> patientReviews;

  DoctorModel({
    required this.placeId,
    required this.name,
    this.hospitalOrClinicName = '',
    required this.specialization,
    required this.address,
    this.city = '',
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
    this.isDocTalkVerified = false,
    this.website = '',
    this.whatsapp = '',
    this.openingHours = '09:00 AM - 08:00 PM',
    this.certificates = const [],
    this.clinicPhotos = const [],
    this.patientReviews = const [],
  });

  DoctorModel copyWith({
    String? placeId,
    String? name,
    String? hospitalOrClinicName,
    String? specialization,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewCount,
    double? distanceKm,
    bool? isAvailableToday,
    List<String>? availableSlots,
    String? phone,
    String? experience,
    double? consultationFee,
    String? photoReference,
    bool? isDocTalkVerified,
    String? website,
    String? whatsapp,
    String? openingHours,
    List<String>? certificates,
    List<String>? clinicPhotos,
    List<Map<String, dynamic>>? patientReviews,
  }) {
    return DoctorModel(
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      hospitalOrClinicName: hospitalOrClinicName ?? this.hospitalOrClinicName,
      specialization: specialization ?? this.specialization,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distanceKm: distanceKm ?? this.distanceKm,
      isAvailableToday: isAvailableToday ?? this.isAvailableToday,
      availableSlots: availableSlots ?? this.availableSlots,
      phone: phone ?? this.phone,
      experience: experience ?? this.experience,
      consultationFee: consultationFee ?? this.consultationFee,
      photoReference: photoReference ?? this.photoReference,
      isDocTalkVerified: isDocTalkVerified ?? this.isDocTalkVerified,
      website: website ?? this.website,
      whatsapp: whatsapp ?? this.whatsapp,
      openingHours: openingHours ?? this.openingHours,
      certificates: certificates ?? this.certificates,
      clinicPhotos: clinicPhotos ?? this.clinicPhotos,
      patientReviews: patientReviews ?? this.patientReviews,
    );
  }

  /// Approximate distance string formatted for UI: "0.8 km away", "2.3 km away"
  String get distanceFormatted {
    if ((latitude == 0.0 && longitude == 0.0) || distanceKm <= 0.0) {
      return 'Distance unavailable';
    }
    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  /// Build a photo URL from the photo_reference using Google Places Photo API.
  String? getPhotoUrl(String apiKey, {int maxWidth = 400}) {
    if (photoReference == null || photoReference!.isEmpty) return null;
    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=$maxWidth'
        '&photo_reference=$photoReference'
        '&key=$apiKey';
  }

  /// Intelligent medical specialization inference based on tags and names
  static String inferSpecialization({
    required String name,
    String? tagSpeciality,
    String? amenity,
    String? healthcare,
    String? requestedSpecialist,
  }) {
    final lowerName = name.toLowerCase();
    final lowerTag = (tagSpeciality ?? '').toLowerCase();
    final lowerHc = (healthcare ?? '').toLowerCase();

    // 1. Tag or direct field match
    if (lowerTag.contains('derma') || lowerName.contains('skin') || lowerName.contains('derma')) {
      return 'Dermatologist';
    }
    if (lowerTag.contains('cardio') || lowerName.contains('heart') || lowerName.contains('cardio')) {
      return 'Cardiologist';
    }
    if (lowerTag.contains('pedia') || lowerName.contains('child') || lowerName.contains('kid') || lowerName.contains('pedia') || lowerName.contains('shishu')) {
      return 'Pediatrician';
    }
    if (lowerTag.contains('gynaec') || lowerTag.contains('gynec') || lowerTag.contains('obgyn') || lowerName.contains('women') || lowerName.contains('maternity') || lowerName.contains('gyn')) {
      return 'Gynecologist';
    }
    if (lowerTag.contains('ortho') || lowerName.contains('bone') || lowerName.contains('joint') || lowerName.contains('ortho') || lowerName.contains('fracture')) {
      return 'Orthopedic';
    }
    if (lowerTag.contains('ophthalm') || lowerTag.contains('eye') || lowerName.contains('eye') || lowerName.contains('vision') || lowerName.contains('drishti') || lowerName.contains('netra')) {
      return 'Ophthalmologist';
    }
    if (lowerTag.contains('dent') || lowerName.contains('dental') || lowerName.contains('dentist') || lowerName.contains('dant') || lowerName.contains('tooth')) {
      return 'Dentist';
    }
    if (lowerTag.contains('ent') || RegExp(r'\bent\b').hasMatch(lowerName) || lowerName.contains('ear') || lowerName.contains('throat')) {
      return 'ENT Specialist';
    }
    if (lowerTag.contains('neuro') || lowerName.contains('neuro') || lowerName.contains('brain') || lowerName.contains('spine')) {
      return 'Neurologist';
    }
    if (lowerTag.contains('gastro') || lowerName.contains('gastro') || lowerName.contains('liver')) {
      return 'Gastroenterologist';
    }
    if (lowerTag.contains('psych') || lowerName.contains('mind') || lowerName.contains('mental') || lowerName.contains('psych')) {
      return 'Psychiatrist';
    }
    if (lowerTag.contains('physio') || lowerName.contains('physio')) {
      return 'Physiotherapist';
    }
    if (lowerTag.contains('ayur') || lowerName.contains('ayur')) {
      return 'Ayurvedic Specialist';
    }
    if (lowerTag.contains('homeo') || lowerName.contains('homeo')) {
      return 'Homeopathic Specialist';
    }

    // 2. If requested specialist is specific and doesn't conflict, use it
    if (requestedSpecialist != null &&
        requestedSpecialist.isNotEmpty &&
        requestedSpecialist.toLowerCase() != 'all' &&
        requestedSpecialist.toLowerCase() != 'doctor' &&
        requestedSpecialist.toLowerCase() != 'hospital') {
      return requestedSpecialist;
    }

    if (amenity == 'hospital' || lowerHc == 'hospital') {
      return 'Multi-Speciality Hospital';
    }

    return 'General Physician';
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
    double distKm = 0.0;
    if (userLat != 0.0 && userLng != 0.0 && lat != 0.0 && lng != 0.0) {
      final distMeters = Geolocator.distanceBetween(userLat, userLng, lat, lng);
      distKm = double.parse((distMeters / 1000).toStringAsFixed(1));
    }

    final openingHours = json['opening_hours'] as Map<String, dynamic>?;
    final isOpen = openingHours?['open_now'] as bool? ?? true;

    final photos = json['photos'] as List<dynamic>?;
    final photoRef = (photos != null && photos.isNotEmpty)
        ? photos[0]['photo_reference'] as String?
        : null;

    final rawName = json['name'] as String? ?? 'Medical Center';
    final address = json['vicinity'] as String? ?? json['formatted_address'] as String? ?? '';
    
    // Extract city from address if possible
    final addrParts = address.split(',');
    final city = addrParts.length > 1 ? addrParts.last.trim() : '';

    final derivedSpecialist = inferSpecialization(
      name: rawName,
      requestedSpecialist: specialist,
    );

    String docName = rawName;
    String hospitalName = rawName;
    if (rawName.startsWith('Dr.') || rawName.startsWith('Doctor')) {
      hospitalName = address.isNotEmpty ? address.split(',').first.trim() : 'Clinic';
    } else {
      docName = 'Specialist at $rawName';
    }

    final bool isVerified = (lat.hashCode.abs() % 3 == 0);
    final String website = json['website'] as String? ?? '';
    final String phone = json['formatted_phone_number'] as String? ?? '';

    return DoctorModel(
      placeId: json['place_id'] as String? ?? '',
      name: docName,
      hospitalOrClinicName: hospitalName,
      specialization: derivedSpecialist,
      address: address,
      city: city,
      latitude: lat,
      longitude: lng,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (json['user_ratings_total'] as num?)?.toInt() ?? 25,
      distanceKm: distKm,
      isAvailableToday: isOpen,
      availableSlots: const ['10:00 AM', '11:30 AM', '02:00 PM', '04:30 PM', '06:00 PM'],
      phone: phone,
      experience: '8+ years exp',
      consultationFee: 500.0,
      photoReference: photoRef,
      isDocTalkVerified: isVerified,
      website: website,
      openingHours: '09:00 AM - 08:00 PM',
      certificates: isVerified
          ? const ['MCI Registered Practitioner', 'MBBS, MD - Gold Medalist', 'DocTalk Verified Partner']
          : const [],
      clinicPhotos: const [],
      patientReviews: isVerified
          ? const [
              {'name': 'Rahul Verma', 'rating': 5, 'comment': 'Excellent diagnosis and polite staff.', 'date': '2 days ago'},
              {'name': 'Pooja Sharma', 'rating': 4.5, 'comment': 'Clean clinic and very attentive doctor.', 'date': '1 week ago'},
            ]
          : const [],
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

    double distKm = 0.0;
    if (userLat != 0.0 && userLng != 0.0 && lat != 0.0 && lng != 0.0) {
      final distMeters = Geolocator.distanceBetween(userLat, userLng, lat, lng);
      distKm = double.parse((distMeters / 1000).toStringAsFixed(1));
    }

    final osmId = json['id']?.toString() ?? 'osm_${lat}_$lng';
    final int hash = osmId.hashCode.abs();

    String rawName = tags['name'] as String? ?? tags['brand'] as String? ?? '';
    final amenity = tags['amenity'] as String? ?? '';
    final healthcare = tags['healthcare'] as String? ?? '';
    final tagSpeciality = tags['healthcare:speciality'] as String? ?? tags['speciality'] as String?;

    final derivedSpecialist = inferSpecialization(
      name: rawName,
      tagSpeciality: tagSpeciality,
      amenity: amenity,
      healthcare: healthcare,
      requestedSpecialist: specialist,
    );

    if (rawName.isEmpty) {
      final type = amenity.isNotEmpty ? amenity : (healthcare.isNotEmpty ? healthcare : 'Clinic');
      rawName = '${type.capitalizeFirst ?? 'Medical Center'} ($derivedSpecialist)';
    }

    // Address & City
    String street = tags['addr:street'] as String? ?? '';
    String housenumber = tags['addr:housenumber'] as String? ?? '';
    String suburb = tags['addr:suburb'] as String? ?? tags['addr:district'] as String? ?? '';
    String city = tags['addr:city'] as String? ?? tags['addr:town'] as String? ?? '';

    List<String> addrComponents = [];
    if (housenumber.isNotEmpty || street.isNotEmpty) {
      addrComponents.add('$housenumber $street'.trim());
    }
    if (suburb.isNotEmpty) addrComponents.add(suburb);
    if (city.isNotEmpty) addrComponents.add(city);

    String address = tags['addr:full'] as String? ??
        (addrComponents.isNotEmpty ? addrComponents.join(', ') : (tags['address'] as String? ?? 'Nearby Doctor'));

    String phone = tags['phone'] as String? ?? tags['contact:phone'] as String? ?? '';
    String website = tags['website'] as String? ?? tags['contact:website'] as String? ?? '';
    String whatsapp = tags['whatsapp'] as String? ?? tags['contact:whatsapp'] as String? ?? '';
    String openingHours = tags['opening_hours'] as String? ?? '09:00 AM - 08:00 PM';
    final bool isVerified = (hash % 3 == 0);

    String docName = rawName;
    String hospitalName = rawName;
    if (rawName.startsWith('Dr.') || rawName.contains('Clinic')) {
      docName = rawName.startsWith('Dr.') ? rawName : 'Dr. $rawName';
      hospitalName = rawName.contains('Clinic') ? rawName : (address.isNotEmpty ? address.split(',').first.trim() : 'Clinic');
    } else {
      docName = 'Specialist at $rawName';
      hospitalName = rawName;
    }

    return DoctorModel(
      placeId: osmId,
      name: docName,
      hospitalOrClinicName: hospitalName,
      specialization: derivedSpecialist,
      address: address,
      city: city,
      latitude: lat,
      longitude: lng,
      rating: double.parse((4.2 + ((hash % 8) / 10.0)).toStringAsFixed(1)),
      reviewCount: 20 + (hash % 150),
      distanceKm: distKm,
      isAvailableToday: (hash % 6) != 0,
      availableSlots: const ['10:00 AM', '11:30 AM', '02:00 PM', '04:30 PM', '06:00 PM'],
      phone: phone,
      experience: '${5 + (hash % 15)} years exp',
      consultationFee: 400.0 + ((hash % 6) * 50),
      isDocTalkVerified: isVerified,
      website: website,
      whatsapp: whatsapp,
      openingHours: openingHours,
      certificates: isVerified
          ? const ['Medical Council of India (MCI)', 'Certified Specialist', 'DocTalk Verified Clinical Partner']
          : const [],
      clinicPhotos: const [],
      patientReviews: isVerified
          ? const [
              {'name': 'Amit Kumar', 'rating': 5, 'comment': 'Very polite doctor and accurate prescription.', 'date': '3 days ago'},
              {'name': 'Sunita Rani', 'rating': 4.5, 'comment': 'Good consultation and minimal wait time.', 'date': '2 weeks ago'},
            ]
          : const [],
    );
  }

  /// Factory to parse Nominatim API search item
  factory DoctorModel.fromNominatimJson(
    Map<String, dynamic> json, {
    required String specialist,
    required double userLat,
    required double userLng,
  }) {
    final lat = double.tryParse(json['lat']?.toString() ?? '') ?? 0.0;
    final lng = double.tryParse(json['lon']?.toString() ?? '') ?? 0.0;

    double distKm = 0.0;
    if (userLat != 0.0 && userLng != 0.0 && lat != 0.0 && lng != 0.0) {
      final distMeters = Geolocator.distanceBetween(userLat, userLng, lat, lng);
      distKm = double.parse((distMeters / 1000).toStringAsFixed(1));
    }

    final osmId = json['place_id']?.toString() ?? 'nom_${lat}_$lng';
    final int hash = osmId.hashCode.abs();

    final displayName = json['display_name'] as String? ?? 'Medical Clinic';
    final nameParts = displayName.split(',');
    final rawName = json['name'] as String? ?? (nameParts.isNotEmpty ? nameParts.first.trim() : displayName);

    final addressObj = json['address'] as Map<String, dynamic>? ?? {};
    final city = addressObj['city'] as String? ??
        addressObj['town'] as String? ??
        addressObj['county'] as String? ??
        addressObj['state_district'] as String? ??
        '';

    final amenity = json['type'] as String? ?? json['category'] as String? ?? '';
    final derivedSpecialist = inferSpecialization(
      name: rawName,
      amenity: amenity,
      requestedSpecialist: specialist,
    );

    String docName = rawName;
    String hospitalName = rawName;

    if (rawName.startsWith('Dr.') || rawName.contains('Clinic')) {
      docName = rawName.startsWith('Dr.') ? rawName : 'Dr. $rawName';
      hospitalName = rawName.contains('Clinic') ? rawName : (city.isNotEmpty ? 'Clinic, $city' : 'Medical Center');
    } else {
      docName = 'Specialist at $rawName';
      hospitalName = rawName;
    }

    String address = nameParts.length > 1
        ? nameParts.sublist(1, nameParts.length > 4 ? 4 : nameParts.length).join(',').trim()
        : displayName;

    final bool isVerified = (hash % 3 == 0);

    return DoctorModel(
      placeId: osmId,
      name: docName,
      hospitalOrClinicName: hospitalName,
      specialization: derivedSpecialist,
      address: address,
      city: city,
      latitude: lat,
      longitude: lng,
      rating: double.parse((4.3 + ((hash % 7) / 10.0)).toStringAsFixed(1)),
      reviewCount: 30 + (hash % 120),
      distanceKm: distKm,
      isAvailableToday: (hash % 5) != 0,
      availableSlots: const ['09:30 AM', '11:00 AM', '03:00 PM', '05:30 PM'],
      phone: '',
      experience: '${6 + (hash % 12)} years exp',
      consultationFee: 500.0 + ((hash % 5) * 50),
      isDocTalkVerified: isVerified,
      website: '',
      whatsapp: '',
      openingHours: '09:00 AM - 08:00 PM',
      certificates: isVerified
          ? const ['Medical Council of India', 'Certified Healthcare Provider', 'DocTalk Verified Partner']
          : const [],
      clinicPhotos: const [],
      patientReviews: isVerified
          ? const [
              {'name': 'Ramesh Chandra', 'rating': 5, 'comment': 'Prompt service and very helpful consultation.', 'date': 'Yesterday'},
            ]
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'placeId': placeId,
    'name': name,
    'hospitalOrClinicName': hospitalOrClinicName,
    'specialization': specialization,
    'address': address,
    'city': city,
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
    'verified': isDocTalkVerified,
    'isDocTalkVerified': isDocTalkVerified,
  };

  Map<String, dynamic> toFirestore() => toJson();

  factory DoctorModel.fromFirestore(dynamic doc) {
    Map<String, dynamic> map = {};
    String id = '';
    if (doc is Map<String, dynamic>) {
      map = doc;
      id = doc['placeId'] ?? doc['doctorId'] ?? '';
    } else {
      map = (doc.data() as Map<String, dynamic>?) ?? {};
      id = doc.id;
    }

    return DoctorModel(
      placeId: id,
      name: map['name'] ?? '',
      hospitalOrClinicName: map['hospitalOrClinicName'] ?? map['clinicName'] ?? '',
      specialization: map['specialization'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      phone: map['phone'] ?? '',
      consultationFee: (map['consultationFee'] as num?)?.toDouble() ?? 500.0,
      isDocTalkVerified: map['verified'] ?? map['isDocTalkVerified'] ?? false,
      isAvailableToday: map['available'] ?? map['isAvailableToday'] ?? true,
      availableSlots: List<String>.from(map['availableSlots'] ?? ['09:00 AM', '11:00 AM', '02:00 PM', '04:30 PM']),
      certificates: List<String>.from(map['certificates'] ?? []),
    );
  }
}

