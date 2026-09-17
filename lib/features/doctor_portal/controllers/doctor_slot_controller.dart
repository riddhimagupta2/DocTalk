import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/doctor_slot_model.dart';
import '../../../repositories/doctor_repository.dart';

class DoctorSlotController extends GetxController {
  final DoctorRepository _doctorRepo = DoctorRepository();

  final Rx<DoctorSlotModel?> slotConfig = Rx<DoctorSlotModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  final RxList<String> selectedDays = <String>[].obs;
  final RxString startTime = '09:00 AM'.obs;
  final RxString endTime = '05:00 PM'.obs;
  final RxInt slotDuration = 30.obs;
  final RxString breakStartTime = '01:00 PM'.obs;
  final RxString breakEndTime = '02:00 PM'.obs;
  final RxList<String> holidays = <String>[].obs;

  static const List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void onInit() {
    super.onInit();
    loadSlots();
  }

  Future<void> loadSlots() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final config = await _doctorRepo.getDoctorSlots(user.uid);
        slotConfig.value = config;
        selectedDays.assignAll(config.availableDays);
        startTime.value = config.startTime;
        endTime.value = config.endTime;
        slotDuration.value = config.slotDurationMinutes;
        breakStartTime.value = config.breakStartTime;
        breakEndTime.value = config.breakEndTime;
        holidays.assignAll(config.holidays);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load schedule: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      if (selectedDays.length > 1) {
        selectedDays.remove(day);
      }
    } else {
      selectedDays.add(day);
    }
  }

  void addHoliday(String dateIso) {
    if (!holidays.contains(dateIso)) {
      holidays.add(dateIso);
    }
  }

  void removeHoliday(String dateIso) {
    holidays.remove(dateIso);
  }

  /// Save schedule configuration to Firestore
  Future<bool> saveSlotConfig() async {
    try {
      isSaving.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Auth Error', 'You must be logged in as a doctor.', backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }

      final newSlots = DoctorSlotModel(
        doctorId: user.uid,
        availableDays: selectedDays.toList(),
        startTime: startTime.value,
        endTime: endTime.value,
        slotDurationMinutes: slotDuration.value,
        breakStartTime: breakStartTime.value,
        breakEndTime: breakEndTime.value,
        holidays: holidays.toList(),
        updatedAt: DateTime.now(),
      );

      await _doctorRepo.saveDoctorSlots(newSlots);
      slotConfig.value = newSlots;

      Get.snackbar(
        'Schedule Updated 🎉',
        'Your availability slots have been regenerated.',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save schedule: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
