import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { patient, helper }

enum HelperType { ashaWorker, chemist, localClinic, volunteer, other }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final UserRole role;
  final DateTime createdAt;

  // Helper-specific fields
  final HelperType? helperType;
  final double? latitude;
  final double? longitude;
  final String? address;
  final bool? isAvailable;
  final String? description;
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    this.role = UserRole.patient,
    required this.createdAt,
    this.helperType,
    this.latitude,
    this.longitude,
    this.address,
    this.isAvailable,
    this.description,
    this.profileImageUrl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      photoUrl: data['photoUrl'],
      role: data['role'] == 'helper' ? UserRole.helper : UserRole.patient,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      helperType: _parseHelperType(data['helperType']),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      address: data['address'],
      isAvailable: data['isAvailable'],
      description: data['description'],
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'role': role == UserRole.helper ? 'helper' : 'patient',
      'createdAt': Timestamp.fromDate(createdAt),
    };

    if (role == UserRole.helper) {
      map['helperType'] = helperType?.name;
      map['latitude'] = latitude;
      map['longitude'] = longitude;
      map['address'] = address;
      map['isAvailable'] = isAvailable ?? true;
      map['description'] = description;
      map['profileImageUrl'] = profileImageUrl;
    }

    return map;
  }

  static HelperType? _parseHelperType(String? value) {
    if (value == null) return null;
    return HelperType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => HelperType.other,
    );
  }

  String get firstName => name.split(' ').first;

  String get helperTypeLabel {
    switch (helperType) {
      case HelperType.ashaWorker:
        return 'ASHA Worker';
      case HelperType.chemist:
        return 'Chemist';
      case HelperType.localClinic:
        return 'Local Clinic';
      case HelperType.volunteer:
        return 'Volunteer';
      case HelperType.other:
        return 'Other';
      default:
        return 'Helper';
    }
  }
}