import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import '../models/doctor_slot_model.dart';

class DoctorRepository {
  final FirebaseFirestore _firestore;

  DoctorRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _doctorsCol =>
      _firestore.collection('doctors');

  CollectionReference<Map<String, dynamic>> get _slotsCol =>
      _firestore.collection('doctor_slots');

  /// Save or update Doctor Profile in Firestore
  Future<void> registerDoctorProfile(DoctorModel doctor) async {
    try {
      final docRef = _doctorsCol.doc(doctor.placeId);
      final data = doctor.toFirestore();
      await docRef.set(data, SetOptions(merge: true));
      developer.log('[DoctorRepository] Registered doctor ${doctor.placeId}');
    } catch (e) {
      developer.log('[DoctorRepository] Error registering doctor: $e');
      rethrow;
    }
  }

  /// Get single verified doctor by ID
  Future<DoctorModel?> getDoctorById(String doctorId) async {
    try {
      final doc = await _doctorsCol.doc(doctorId).get();
      if (doc.exists && doc.data() != null) {
        return DoctorModel.fromFirestore(doc);
      }
    } catch (e) {
      developer.log('[DoctorRepository] Error getting doctor $doctorId: $e');
    }
    return null;
  }

  /// Stream single doctor profile
  Stream<DoctorModel?> streamDoctorById(String doctorId) {
    return _doctorsCol.doc(doctorId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return DoctorModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Query all verified doctors from Firestore
  Future<List<DoctorModel>> getVerifiedDoctors() async {
    try {
      final snapshot = await _doctorsCol.where('verified', isEqualTo: true).get();
      return snapshot.docs.map((doc) => DoctorModel.fromFirestore(doc)).toList();
    } catch (e) {
      developer.log('[DoctorRepository] Error fetching verified doctors: $e');
      return [];
    }
  }

  /// Match a Google Maps doctor with Firestore registered doctors by phone or clinic name
  Future<DoctorModel?> matchGoogleMapsDoctor({
    required String phone,
    required String clinicName,
    required String doctorName,
  }) async {
    try {
      // 1. Try match by Phone Number
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPhone.length >= 8) {
        final phoneQuery = await _doctorsCol
            .where('verified', isEqualTo: true)
            .get();

        for (final doc in phoneQuery.docs) {
          final data = doc.data();
          final docPhone = (data['phone'] as String? ?? '').replaceAll(RegExp(r'[^0-9]'), '');
          if (docPhone.isNotEmpty && (docPhone.contains(cleanPhone) || cleanPhone.contains(docPhone))) {
            return DoctorModel.fromFirestore(doc);
          }
        }
      }

      // 2. Try match by Clinic Name or Doctor Name
      final cleanClinic = clinicName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      final cleanName = doctorName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

      final nameQuery = await _doctorsCol.where('verified', isEqualTo: true).get();

      for (final doc in nameQuery.docs) {
        final data = doc.data();
        final dbClinic = (data['clinicName'] as String? ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        final dbName = (data['name'] as String? ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

        if ((cleanClinic.isNotEmpty && dbClinic.isNotEmpty && (dbClinic.contains(cleanClinic) || cleanClinic.contains(dbClinic))) ||
            (cleanName.isNotEmpty && dbName.isNotEmpty && (dbName.contains(cleanName) || cleanName.contains(dbName)))) {
          return DoctorModel.fromFirestore(doc);
        }
      }
    } catch (e) {
      developer.log('[DoctorRepository] Error matching doctor: $e');
    }
    return null;
  }

  /// Get Doctor Slot Configuration
  Future<DoctorSlotModel> getDoctorSlots(String doctorId) async {
    try {
      final doc = await _slotsCol.doc(doctorId).get();
      if (doc.exists && doc.data() != null) {
        return DoctorSlotModel.fromFirestore(doc);
      }
    } catch (e) {
      developer.log('[DoctorRepository] Error getting doctor slots: $e');
    }
    return DoctorSlotModel(doctorId: doctorId);
  }

  /// Save or Update Doctor Slot Configuration
  Future<void> saveDoctorSlots(DoctorSlotModel slots) async {
    try {
      await _slotsCol.doc(slots.doctorId).set(slots.toMap(), SetOptions(merge: true));
    } catch (e) {
      developer.log('[DoctorRepository] Error saving doctor slots: $e');
      rethrow;
    }
  }

  /// Update doctor availability toggle
  Future<void> setDoctorAvailability(String doctorId, bool available) async {
    try {
      await _doctorsCol.doc(doctorId).update({'available': available});
    } catch (e) {
      developer.log('[DoctorRepository] Error toggling availability: $e');
    }
  }

  /// Admin: Stream all doctors in system
  Stream<List<DoctorModel>> streamAllDoctors() {
    return _doctorsCol.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DoctorModel.fromFirestore(doc)).toList();
    });
  }

  /// Admin: Verify or reject doctor
  Future<void> updateDoctorVerification(String doctorId, bool verified, String status) async {
    try {
      await _doctorsCol.doc(doctorId).update({
        'verified': verified,
        'verificationStatus': status,
        'status': status,
      });
    } catch (e) {
      developer.log('[DoctorRepository] Error updating verification: $e');
      rethrow;
    }
  }
}
