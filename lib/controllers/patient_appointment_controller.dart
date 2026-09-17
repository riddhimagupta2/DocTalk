import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/appointment_model.dart';
import '../repositories/appointment_repository.dart';
import '../services/fcm_service.dart';

class PatientAppointmentController extends GetxController {
  final AppointmentRepository _repository = AppointmentRepository();

  final RxList<AppointmentModel> allAppointments = <AppointmentModel>[].obs;
  final RxBool isLoading = true.obs;

  List<AppointmentModel> get upcomingAppointments => allAppointments
      .where((a) => a.status == AppointmentStatus.pending || a.status == AppointmentStatus.accepted)
      .toList();

  List<AppointmentModel> get completedAppointments => allAppointments
      .where((a) => a.status == AppointmentStatus.completed)
      .toList();

  List<AppointmentModel> get cancelledAppointments => allAppointments
      .where((a) => a.status == AppointmentStatus.cancelled || a.status == AppointmentStatus.rejected)
      .toList();

  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      allAppointments.bindStream(_repository.streamPatientAppointments(user.uid));
    } else {
      isLoading.value = false;
    }
  }

  /// Cancel an existing appointment
  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      await _repository.updateAppointmentStatus(
        appointmentId,
        AppointmentStatus.cancelled,
        rejectionReason: reason,
      );

      Get.snackbar(
        'Appointment Cancelled',
        'Your appointment has been cancelled successfully.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel appointment: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Reschedule an existing appointment
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required String newDate,
    required String newTime,
  }) async {
    try {
      await _repository.rescheduleAppointment(
        appointmentId: appointmentId,
        newDate: newDate,
        newTime: newTime,
      );

      Get.snackbar(
        'Appointment Rescheduled',
        'Your request to reschedule to $newDate at $newTime has been submitted.',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reschedule appointment: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Set reminder notification
  void setAppointmentReminder(AppointmentModel appointment) {
    Get.find<FCMService>().sendAppointmentReminder(
      recipientId: appointment.patientId,
      title: 'Upcoming Appointment Reminder ⏰',
      message: 'Reminder for your appointment with Dr. ${appointment.doctorName} on ${appointment.date} at ${appointment.time}.',
    );
  }
}
