import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/appointment_model.dart';
import '../../../models/doctor_model.dart';
import '../../../repositories/appointment_repository.dart';
import '../../../repositories/doctor_repository.dart';

class AdminController extends GetxController {
  final DoctorRepository _doctorRepo = DoctorRepository();
  final AppointmentRepository _appointmentRepo = AppointmentRepository();

  final RxList<DoctorModel> allDoctors = <DoctorModel>[].obs;
  final RxList<AppointmentModel> allAppointments = <AppointmentModel>[].obs;
  final RxBool isLoading = true.obs;

  List<DoctorModel> get pendingDoctors =>
      allDoctors.where((d) => !d.isDocTalkVerified).toList();

  List<DoctorModel> get verifiedDoctors =>
      allDoctors.where((d) => d.isDocTalkVerified).toList();

  int get totalDoctorsCount => allDoctors.length;
  int get verifiedCount => verifiedDoctors.length;
  int get pendingCount => pendingDoctors.length;
  int get totalAppointmentsCount => allAppointments.length;

  double get totalRevenue {
    return allAppointments.fold(0.0, (sum, apt) => sum + apt.consultationFee);
  }

  @override
  void onInit() {
    super.onInit();
    allDoctors.bindStream(_doctorRepo.streamAllDoctors());
    allAppointments.bindStream(_appointmentRepo.streamAllAppointments());
    isLoading.value = false;
  }

  /// Verify doctor application
  Future<void> verifyDoctor(String doctorId) async {
    try {
      await _doctorRepo.updateDoctorVerification(doctorId, true, 'approved');
      Get.snackbar(
        'Doctor Verified ✅',
        'Doctor has been approved and can now receive online appointments.',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to verify doctor: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  /// Block doctor account
  Future<void> blockDoctor(String doctorId) async {
    try {
      await _doctorRepo.updateDoctorVerification(doctorId, false, 'blocked');
      Get.snackbar(
        'Doctor Blocked',
        'Doctor account blocked.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to block doctor: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
