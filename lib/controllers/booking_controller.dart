import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../models/doctor_model.dart';
import '../models/doctor_slot_model.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/doctor_repository.dart';
import '../services/fcm_service.dart';

class BookingController extends GetxController {
  final AppointmentRepository _appointmentRepo = AppointmentRepository();
  final DoctorRepository _doctorRepo = DoctorRepository();

  final Rx<DoctorModel?> doctor = Rx<DoctorModel?>(null);
  final Rx<DoctorSlotModel?> slotConfig = Rx<DoctorSlotModel?>(null);

  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxString selectedSlot = ''.obs;
  final RxList<String> availableSlots = <String>[].obs;

  final RxBool isLoadingSlots = false.obs;
  final RxBool isBooking = false.obs;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final reasonController = TextEditingController();

  List<DateTime> get next7Days {
    final today = DateTime.now();
    return List.generate(14, (i) => today.add(Duration(days: i)));
  }

  bool get canBook =>
      doctor.value != null &&
      selectedDate.value != null &&
      selectedSlot.isNotEmpty &&
      nameController.text.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args.containsKey('doctor')) {
      doctor.value = args['doctor'] as DoctorModel;
    }

    // Pre-fill user details if logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        nameController.text = user.displayName!;
      }
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        phoneController.text = user.phoneNumber!;
      }
    }

    if (doctor.value != null) {
      fetchDoctorSlots(doctor.value!.placeId);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    reasonController.dispose();
    super.onClose();
  }

  /// Fetch doctor slot configuration and generate available slots for selected date
  Future<void> fetchDoctorSlots(String doctorId) async {
    try {
      isLoadingSlots.value = true;
      final config = await _doctorRepo.getDoctorSlots(doctorId);
      slotConfig.value = config;

      // Default select today
      if (selectedDate.value == null) {
        selectDate(DateTime.now());
      } else {
        selectDate(selectedDate.value!);
      }
    } catch (e) {
      availableSlots.assignAll(['09:00 AM', '10:30 AM', '02:00 PM', '04:30 PM']);
    } finally {
      isLoadingSlots.value = false;
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedSlot.value = '';

    if (slotConfig.value != null) {
      final generated = slotConfig.value!.generateTimeSlotsForDate(date);
      availableSlots.assignAll(generated);
    } else {
      final defaultSlots = doctor.value?.availableSlots;
      if (defaultSlots != null && defaultSlots.isNotEmpty) {
        availableSlots.assignAll(defaultSlots);
      } else {
        availableSlots.assignAll(['09:00 AM', '11:00 AM', '02:30 PM', '05:00 PM']);
      }
    }
  }

  void selectSlot(String slot) {
    selectedSlot.value = slot;
  }

  /// Submit appointment booking to Firestore
  Future<AppointmentModel?> confirmBooking() async {
    if (doctor.value == null) {
      Get.snackbar('Error', 'Doctor information missing.', backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }

    if (!canBook) {
      Get.snackbar(
        'Incomplete Details',
        'Please select a date, time slot, and enter your name.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    isBooking.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      final patientId = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value!);

      final appointment = AppointmentModel(
        appointmentId: '',
        patientId: patientId,
        doctorId: doctor.value!.placeId,
        doctorName: doctor.value!.name,
        doctorSpecialization: doctor.value!.specialization,
        doctorAddress: doctor.value!.address,
        doctorPhone: doctor.value!.phone,
        patientName: nameController.text.trim(),
        patientPhone: phoneController.text.trim(),
        date: formattedDate,
        time: selectedSlot.value,
        status: AppointmentStatus.pending,
        symptoms: reasonController.text.trim(),
        consultationFee: doctor.value!.consultationFee,
        createdAt: DateTime.now(),
        doctorObj: doctor.value,
      );

      final docId = await _appointmentRepo.createAppointment(appointment);
      final createdAppointment = appointment.copyWith(appointmentId: docId);

      // Send FCM push notification to doctor
      Get.find<FCMService>().sendNewAppointmentNotification(
        doctorId: doctor.value!.placeId,
        patientName: nameController.text.trim(),
        date: formattedDate,
        time: selectedSlot.value,
      );

      return createdAppointment;
    } catch (e) {
      Get.snackbar(
        'Booking Failed',
        'An error occurred while creating your appointment: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isBooking.value = false;
    }
  }
}
