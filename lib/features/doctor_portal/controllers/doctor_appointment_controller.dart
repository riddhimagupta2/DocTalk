import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/appointment_model.dart';
import '../../../repositories/appointment_repository.dart';
import '../../../services/fcm_service.dart';
import '../models/doctor_portal_models.dart';
import '../services/doctor_portal_service.dart';

class DoctorAppointmentController extends GetxController {
  final AppointmentRepository _appointmentRepo = AppointmentRepository();
  final DoctorPortalService _service = DoctorPortalService();

  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxString selectedFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      appointments.bindStream(_appointmentRepo.streamDoctorAppointments(user.uid));
    } else {
      isLoading.value = false;
    }
  }

  List<AppointmentModel> get filteredAppointments {
    return appointments.where((apt) {
      final statusStr = apt.status.value.toLowerCase();
      final filterStr = selectedFilter.value.toLowerCase();
      final matchesFilter = filterStr == 'all' || statusStr == filterStr;

      final query = searchQuery.value.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          apt.patientName.toLowerCase().contains(query) ||
          apt.symptoms.toLowerCase().contains(query) ||
          apt.time.toLowerCase().contains(query);

      return matchesFilter && matchesQuery;
    }).toList();
  }

  int get pendingCount => appointments.where((a) => a.status == AppointmentStatus.pending).length;
  int get acceptedCount => appointments.where((a) => a.status == AppointmentStatus.accepted).length;
  int get completedCount => appointments.where((a) => a.status == AppointmentStatus.completed).length;

  /// Accept pending appointment request
  Future<void> acceptAppointment(String appointmentId) async {
    try {
      final apt = appointments.firstWhereOrNull((a) => a.appointmentId == appointmentId);
      await _appointmentRepo.updateAppointmentStatus(appointmentId, AppointmentStatus.accepted);

      if (apt != null) {
        Get.find<FCMService>().sendAppointmentStatusNotification(
          patientId: apt.patientId,
          doctorName: apt.doctorName,
          status: 'Accepted',
        );
      }

      Get.snackbar(
        'Appointment Accepted 🎉',
        'Patient has been notified of the confirmed consultation.',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept appointment: $e');
    }
  }

  /// Reject appointment request with a reason
  Future<void> rejectAppointment(String appointmentId, String reason) async {
    try {
      final apt = appointments.firstWhereOrNull((a) => a.appointmentId == appointmentId);
      await _appointmentRepo.updateAppointmentStatus(
        appointmentId,
        AppointmentStatus.rejected,
        rejectionReason: reason,
      );

      if (apt != null) {
        Get.find<FCMService>().sendAppointmentStatusNotification(
          patientId: apt.patientId,
          doctorName: apt.doctorName,
          status: 'Rejected',
          rejectionReason: reason,
        );
      }

      Get.snackbar(
        'Appointment Declined',
        'Slot released and patient notified.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject appointment: $e');
    }
  }

  /// Mark appointment completed
  Future<void> completeAppointment(String appointmentId) async {
    try {
      final apt = appointments.firstWhereOrNull((a) => a.appointmentId == appointmentId);
      await _appointmentRepo.updateAppointmentStatus(appointmentId, AppointmentStatus.completed);

      if (apt != null) {
        Get.find<FCMService>().sendAppointmentStatusNotification(
          patientId: apt.patientId,
          doctorName: apt.doctorName,
          status: 'Completed',
        );
      }

      Get.snackbar(
        'Appointment Completed ✅',
        'Consultation successfully marked complete.',
        backgroundColor: const Color(0xFF009688),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete appointment: $e');
    }
  }

  /// Save digital prescription
  Future<bool> savePrescription(DoctorPrescription prescription) async {
    try {
      isSubmitting.value = true;
      await _service.savePrescription(prescription);
      await completeAppointment(prescription.appointmentId);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save prescription: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
