import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment_model.dart';
import '../repositories/appointment_repository.dart';

class AppointmentService {
  static const _key = 'booked_appointments';
  final AppointmentRepository _repository = AppointmentRepository();

  /// Save appointment to Firestore and local cache fallback
  Future<bool> saveAppointment(AppointmentModel appointment) async {
    try {
      // 1. Primary: Save to Firestore
      final user = FirebaseAuth.instance.currentUser;
      final finalAppointment = appointment.copyWith(
        patientId: user?.uid ?? appointment.patientId,
      );
      await _repository.createAppointment(finalAppointment);

      // 2. Cache locally in SharedPreferences for offline support
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_key) ?? [];
      existing.add(jsonEncode(finalAppointment.toMap()));
      await prefs.setStringList(_key, existing);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get all appointments (Firestore + local fallback)
  Future<List<Map<String, dynamic>>> getAllAppointments() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: user.uid)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs.map((d) => d.data()).toList();
          list.sort((a, b) {
            final tA = a['createdAt'] as Timestamp?;
            final tB = b['createdAt'] as Timestamp?;
            if (tA != null && tB != null) return tB.compareTo(tA);
            return 0;
          });
          return list;
        }
      }
    } catch (_) {}

    // Fallback to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      return list
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList()
          .reversed
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Cancel by ID (sets status = 'cancelled')
  Future<bool> cancelAppointment(String id) async {
    try {
      await _repository.updateAppointmentStatus(id, AppointmentStatus.cancelled);

      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      final updated = list.map((e) {
        final map = jsonDecode(e) as Map<String, dynamic>;
        if (map['id'] == id || map['appointmentId'] == id) {
          map['status'] = 'Cancelled';
        }
        return jsonEncode(map);
      }).toList();
      await prefs.setStringList(_key, updated);
      return true;
    } catch (_) {
      return false;
    }
  }
}
