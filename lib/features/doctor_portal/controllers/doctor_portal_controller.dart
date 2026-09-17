import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import '../../../models/doctor_slot_model.dart';
import '../../../repositories/doctor_repository.dart';
import '../models/doctor_portal_models.dart';
import '../services/doctor_portal_service.dart';

class DoctorPortalController extends GetxController {
  final DoctorPortalService _service = DoctorPortalService();

  final Rx<DoctorProfile?> profile = Rx<DoctorProfile?>(null);
  final Rx<DoctorSchedule> schedule = Rx<DoctorSchedule>(DoctorSchedule());
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool emergencyMode = false.obs;

  // Verification status getter
  bool get isApproved => profile.value?.verificationStatus == 'approved';
  bool get isPending => profile.value?.verificationStatus == 'pending';
  bool get isRejected => profile.value?.verificationStatus == 'rejected';

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final docProfile = await _service.getDoctorProfile();
      if (docProfile != null) {
        profile.value = docProfile;
        emergencyMode.value = docProfile.emergencyMode;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not load doctor profile: $e',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleEmergencyMode(bool val) async {
    emergencyMode.value = val;
    if (profile.value != null) {
      profile.value = profile.value!.copyWith(emergencyMode: val);
    }
    await _service.toggleEmergencyMode(val);
    Get.snackbar(
      val ? 'Emergency Mode Activated' : 'Emergency Mode Deactivated',
      val
          ? 'You are now marked available for high-priority urgent cases.'
          : 'Normal consultation schedule restored.',
      backgroundColor: val ? Colors.red.withValues(alpha: 0.85) : Colors.blueGrey.withValues(alpha: 0.85),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<bool> registerDoctor({
    required String name,
    required String email,
    required String phone,
    required String specialization,
    required String qualification,
    required String licenseNumber,
    required String clinicName,
    required String address,
    required String city,
    required double consultationFee,
  }) async {
    final uid = _service.currentUserId;
    if (uid == null || uid.isEmpty) {
      Get.snackbar(
        'Authentication Required 🔒',
        'You must be signed in to register as a doctor.',
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    try {
      isSaving.value = true;
      final newProfile = DoctorProfile(
        id: uid,
        name: name,
        email: email,
        phone: phone,
        specialization: specialization,
        qualification: qualification,
        licenseNumber: licenseNumber,
        clinicName: clinicName,
        address: address,
        city: city,
        consultationFee: consultationFee,
        isVerified: false,
        verificationStatus: 'pending',
      );

      await _service.registerDoctor(newProfile);
      profile.value = newProfile;

      // Update AuthController state if registered
      if (Get.isRegistered<AuthController>()) {
        final authCtrl = Get.find<AuthController>();
        final currUser = authCtrl.userModel.value;
        if (currUser != null) {
          authCtrl.userModel.value = UserModel(
            uid: currUser.uid,
            name: currUser.name,
            email: currUser.email,
            role: 'doctor',
            phoneNumber: currUser.phoneNumber,
            photoUrl: currUser.photoUrl,
            createdAt: currUser.createdAt,
          );
        }
      }

      return true;
    } on FirebaseException catch (e) {
      String msg = 'Error submitting application.';
      if (e.code == 'permission-denied') {
        msg = 'Permission denied. You do not have authorization to perform this action.';
      } else if (e.code == 'unavailable') {
        msg = 'Network failure. Please check your connection and try again.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        msg = e.message!;
      }
      Get.snackbar(
        'Registration Failed',
        msg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateSchedule(DoctorSchedule newSchedule) async {
    schedule.value = newSchedule;
    try {
      final user = FirebaseAuth.instance.currentUser;
      final docId = user?.uid ?? _service.currentUserId ?? 'doc_current';
      final slotModel = DoctorSlotModel(
        doctorId: docId,
        availableDays: newSchedule.availableDays,
        startTime: newSchedule.startTime,
        endTime: newSchedule.endTime,
        slotDurationMinutes: 30,
        breakStartTime: newSchedule.breakStartTime,
        breakEndTime: newSchedule.breakEndTime,
      );
      await DoctorRepository().saveDoctorSlots(slotModel);
    } catch (_) {}

    Get.snackbar(
      'Schedule Updated',
      'Your consultation hours have been refreshed successfully.',
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
