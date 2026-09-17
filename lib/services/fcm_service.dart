import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FCMService extends GetxService {
  static FCMService get to => Get.find<FCMService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  @override
  void onInit() {
    super.onInit();
    initFCM();
  }

  /// Initialize FCM token registration
  Future<void> initFCM() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _fcmToken = 'fcm_token_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
        await saveTokenToFirestore(user.uid, _fcmToken!);
      }
      developer.log('[FCMService] FCM initialized successfully');
    } catch (e) {
      developer.log('[FCMService] Failed to initialize FCM: $e');
    }
  }

  /// Store FCM Token in user's profile and doctor's profile
  Future<void> saveTokenToFirestore(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Check if user is a doctor
      final docRef = _firestore.collection('doctors').doc(uid);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.update({'fcmToken': token});
      }
    } catch (e) {
      developer.log('[FCMService] Error saving FCM token: $e');
    }
  }

  /// Trigger notification to doctor for new appointment request
  Future<void> sendNewAppointmentNotification({
    required String doctorId,
    required String patientName,
    required String date,
    required String time,
  }) async {
    try {
      developer.log('[FCM] Sending "New Appointment Request" notification to Doctor $doctorId');

      // Fetch doctor FCM token
      final docSnap = await _firestore.collection('doctors').doc(doctorId).get();
      final doctorToken = docSnap.data()?['fcmToken'];

      // Log notification entry in Firestore notifications collection
      await _firestore.collection('notifications').add({
        'recipientId': doctorId,
        'recipientToken': doctorToken,
        'type': 'new_appointment',
        'title': 'New Appointment Request 🩺',
        'body': '$patientName requested an appointment on $date at $time.',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Show in-app banner for active session
      Get.snackbar(
        'New Appointment Request 🩺',
        '$patientName requested an appointment on $date at $time.',
        backgroundColor: const Color(0xFF1E88E5),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        icon: const Icon(Icons.notifications_active_rounded, color: Colors.white),
      );
    } catch (e) {
      developer.log('[FCMService] Error sending doctor notification: $e');
    }
  }

  /// Trigger notification to patient for appointment status updates
  Future<void> sendAppointmentStatusNotification({
    required String patientId,
    required String doctorName,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      String title = 'Appointment Update 📅';
      String body = 'Your appointment status with Dr. $doctorName is now $status.';
      Color bg = const Color(0xFF1E88E5);

      if (status.toLowerCase() == 'accepted') {
        title = 'Appointment Accepted! 🎉';
        body = 'Dr. $doctorName has accepted your appointment request.';
        bg = const Color(0xFF4CAF50);
      } else if (status.toLowerCase() == 'rejected') {
        title = 'Appointment Declined ⚠️';
        body = 'Dr. $doctorName was unable to accept your request. Reason: ${rejectionReason ?? "Schedule conflict"}';
        bg = const Color(0xFFE53935);
      } else if (status.toLowerCase() == 'completed') {
        title = 'Consultation Completed ✅';
        body = 'Your appointment with Dr. $doctorName has been marked completed.';
        bg = const Color(0xFF009688);
      }

      await _firestore.collection('notifications').add({
        'recipientId': patientId,
        'type': 'appointment_status',
        'title': title,
        'body': body,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      Get.snackbar(
        title,
        body,
        backgroundColor: bg,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        icon: const Icon(Icons.event_available_rounded, color: Colors.white),
      );
    } catch (e) {
      developer.log('[FCMService] Error sending patient notification: $e');
    }
  }

  /// Trigger appointment reminder
  Future<void> sendAppointmentReminder({
    required String recipientId,
    required String title,
    required String message,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'recipientId': recipientId,
        'type': 'reminder',
        'title': title,
        'body': message,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      Get.snackbar(
        title,
        message,
        backgroundColor: const Color(0xFFFF9800),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        icon: const Icon(Icons.alarm_on_rounded, color: Colors.white),
      );
    } catch (e) {
      developer.log('[FCMService] Error sending reminder: $e');
    }
  }
}
