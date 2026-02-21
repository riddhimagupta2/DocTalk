import 'package:get/get.dart';
import '../models/appointment_model.dart';
import '../models/doctor_model.dart';
import '../services/appoint_service.dart';

class BookingController extends GetxController {
  final DoctorModel doctor;
  final AppointmentService _appointmentService = AppointmentService();

  BookingController({required this.doctor});

  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxString selectedSlot = ''.obs;
  final RxBool isBooking = false.obs;

  final patientNameController = ''.obs;
  final patientPhoneController = ''.obs;
  final reasonController = ''.obs;

  List<DateTime> get availableDates {
    final today = DateTime.now();
    return List.generate(7, (i) => today.add(Duration(days: i)));
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedSlot.value = '';
  }

  void selectSlot(String slot) {
    selectedSlot.value = slot;
  }

  bool get canBook =>
      selectedDate.value != null &&
          selectedSlot.isNotEmpty &&
          patientNameController.value.trim().isNotEmpty;

  Future<AppointmentModel?> bookAppointment() async {
    if (!canBook) return null;
    isBooking.value = true;

    try {
      await Future.delayed(const Duration(seconds: 1)); // simulate API

      final appointment = AppointmentModel(
        id: 'APT_${DateTime.now().millisecondsSinceEpoch}',
        doctor: doctor,
        date: selectedDate.value!,
        timeSlot: selectedSlot.value,
        patientName: patientNameController.value.trim(),
        patientPhone: patientPhoneController.value.trim(),
        reason: reasonController.value.trim(),
      );

      await _appointmentService.saveAppointment(appointment);
      return appointment;
    } catch (e) {
      Get.snackbar('Error', 'Booking failed: $e');
      return null;
    } finally {
      isBooking.value = false;
    }
  }
}