import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentService {
  static const _key = 'booked_appointments';

  // ── Save appointment ──────────────────────────────────────────────────
  Future<bool> saveAppointment(dynamic appointment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_key) ?? [];
      existing.add(jsonEncode(appointment.toJson()));
      return await prefs.setStringList(_key, existing);
    } catch (_) {
      return false;
    }
  }

  // ── Get all appointments (newest first) ───────────────────────────────
  Future<List<Map<String, dynamic>>> getAllAppointments() async {
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

  // ── Cancel by ID (sets status = 'cancelled') ──────────────────────────
  Future<bool> cancelAppointment(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      final updated = list.map((e) {
        final map = jsonDecode(e) as Map<String, dynamic>;
        if (map['id'] == id) {
          map['status'] = 'cancelled';
        }
        return jsonEncode(map);
      }).toList();
      return await prefs.setStringList(_key, updated);
    } catch (_) {
      return false;
    }
  }
}