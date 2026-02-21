import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/booking_controller.dart';
import '../../models/doctor_model.dart';
import '../../resources/AppTheme.dart';


class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final DoctorModel doctor = args['doctor'];
    final controller = Get.put(BookingController(doctor: doctor));

    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final reasonController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor mini card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(doctor.specialization,
                          style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                      Text('₹${doctor.consultationFee.toInt()} consultation',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Date selection
            _SectionTitle(title: 'Select Date', icon: Icons.calendar_today),
            const SizedBox(height: 12),
            Obx(() => SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.availableDates.length,
                itemBuilder: (_, i) {
                  final date = controller.availableDates[i];
                  final isSelected = controller.selectedDate.value != null &&
                      DateUtils.isSameDay(controller.selectedDate.value, date);
                  final isToday = DateUtils.isSameDay(date, DateTime.now());
                  return GestureDetector(
                    onTap: () => controller.selectDate(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (isToday)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.white : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )),

            const SizedBox(height: 24),

            // Time slots
            _SectionTitle(title: 'Select Time Slot', icon: Icons.access_time),
            const SizedBox(height: 12),
            if (doctor.availableSlots.isEmpty)
              const Text('No slots available', style: TextStyle(color: AppColors.textSecondary))
            else
              Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: doctor.availableSlots.map((slot) {
                  final isSelected = controller.selectedSlot.value == slot;
                  return GestureDetector(
                    onTap: () => controller.selectSlot(slot),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),

            const SizedBox(height: 24),

            // Patient details
            _SectionTitle(title: 'Your Details', icon: Icons.person_outline),
            const SizedBox(height: 12),

            _AppTextField(
              controller: nameController,
              label: 'Full Name *',
              hint: 'Enter your full name',
              icon: Icons.person,
              onChanged: (v) => controller.patientNameController.value = v,
            ),
            const SizedBox(height: 12),
            _AppTextField(
              controller: phoneController,
              label: 'Phone Number',
              hint: '+91 XXXXX XXXXX',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              onChanged: (v) => controller.patientPhoneController.value = v,
            ),
            const SizedBox(height: 12),
            _AppTextField(
              controller: reasonController,
              label: 'Reason for Visit',
              hint: 'Brief description of your symptoms',
              icon: Icons.note_outlined,
              maxLines: 3,
              onChanged: (v) => controller.reasonController.value = v,
            ),

            const SizedBox(height: 32),

            // Book button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: controller.isBooking.value
                    ? null
                    : () async {
                  final appointment = await controller.bookAppointment();
                  if (appointment != null) {
                    Get.offNamed('/booking-confirmation', arguments: {'appointment': appointment});
                  } else if (!controller.canBook) {
                    Get.snackbar(
                      'Incomplete',
                      'Please select date, time slot and enter your name.',
                      backgroundColor: AppColors.error,
                      colorText: AppColors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.textHint,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: controller.isBooking.value
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                )
                    : const Text(
                  'Confirm Appointment',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _AppTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 14 : 0),
      ),
    );
  }
}