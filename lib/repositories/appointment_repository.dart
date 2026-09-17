import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore;

  AppointmentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _appointmentsCol =>
      _firestore.collection('appointments');

  /// Create a new appointment document in Firestore
  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      final docRef = _appointmentsCol.doc();
      final finalAppointment = appointment.copyWith(appointmentId: docRef.id);
      await docRef.set(finalAppointment.toMap());
      developer.log('[AppointmentRepository] Created appointment ${docRef.id}');
      return docRef.id;
    } catch (e) {
      developer.log('[AppointmentRepository] Error creating appointment: $e');
      rethrow;
    }
  }

  /// Real-time stream of patient's appointments
  Stream<List<AppointmentModel>> streamPatientAppointments(String patientId) {
    if (patientId.isEmpty) return Stream.value([]);
    return _appointmentsCol
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Real-time stream of doctor's appointments
  Stream<List<AppointmentModel>> streamDoctorAppointments(String doctorId) {
    if (doctorId.isEmpty) return Stream.value([]);
    return _appointmentsCol
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Stream single appointment details
  Stream<AppointmentModel?> streamAppointmentById(String appointmentId) {
    return _appointmentsCol.doc(appointmentId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return AppointmentModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Update appointment status (Pending -> Accepted / Rejected / Completed / Cancelled)
  Future<void> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus status, {
    String? rejectionReason,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (rejectionReason != null && rejectionReason.isNotEmpty) {
        updateData['rejectionReason'] = rejectionReason;
      }
      await _appointmentsCol.doc(appointmentId).update(updateData);
    } catch (e) {
      developer.log('[AppointmentRepository] Error updating status: $e');
      rethrow;
    }
  }

  /// Reschedule an appointment
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required String newDate,
    required String newTime,
  }) async {
    try {
      await _appointmentsCol.doc(appointmentId).update({
        'date': newDate,
        'time': newTime,
        'rescheduleDate': newDate,
        'rescheduleTime': newTime,
        'status': AppointmentStatus.pending.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('[AppointmentRepository] Error rescheduling appointment: $e');
      rethrow;
    }
  }

  /// Stream all appointments for Admin
  Stream<List<AppointmentModel>> streamAllAppointments() {
    return _appointmentsCol.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
