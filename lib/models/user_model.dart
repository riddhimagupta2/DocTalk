import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'patient' | 'doctor' | 'admin'
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'patient',
    this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'patient',
      phoneNumber: data['phoneNumber'] ?? data['phone'],
      photoUrl: data['photoUrl'] ?? data['photo'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isPatient => role == 'patient';
  bool get isDoctor => role == 'doctor';
  bool get isAdmin => role == 'admin';

  String get firstName => name.split(' ').first;
}
