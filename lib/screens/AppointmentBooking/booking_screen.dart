import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/booking_controller.dart';
import '../../resources/app_colors.dart';
import '../../resources/app_routes.dart';
import '../../resources/responsive.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject or find BookingController
    final controller = Get.put(BookingController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: context.r(20)),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Appointment',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.sp(16),
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              'Fill in the details below',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.sp(11.5),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Obx(() {
        final doc = controller.doctor.value;
        final doctorName = doc?.name ?? 'Doctor';
        final specialization = doc?.specialization ?? 'Specialist';
        final fee = doc?.consultationFee.toInt() ?? 0;
        final selectedDate = controller.selectedDate.value;
        final selectedSlot = controller.selectedSlot.value;
        final slots = controller.availableSlots;
        final isLoadingSlots = controller.isLoadingSlots.value;
        final isBooking = controller.isBooking.value;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(4).clamp(12.0, 20.0),
            vertical: context.hp(1.5).clamp(10.0, 18.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Doctor Mini Summary Card ──
              Container(
                padding: EdgeInsets.all(context.r(14)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryLight,
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(context.r(16)),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: context.r(50),
                      height: context.r(50),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(context.r(12)),
                      ),
                      child: Icon(Icons.person_rounded,
                          color: AppColors.primary, size: context.r(28)),
                    ),
                    SizedBox(width: context.wp(3).clamp(8.0, 14.0)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  doctorName,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: context.sp(14.5),
                                    fontFamily: 'Poppins',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded,
                                  color: Color(0xFF10B981), size: 16),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            specialization,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: context.sp(12.5),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          if (fee > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              '₹$fee consultation fee',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: context.sp(11.5),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.hp(2.5)),

              // ── Date Selector ──
              _sectionTitle(context, Icons.calendar_month_rounded, 'Select Consultation Date'),
              SizedBox(height: context.hp(1.2)),
              SizedBox(
                height: context.hp(9.5).clamp(64.0, 80.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.next7Days.length,
                  itemBuilder: (_, i) {
                    final date = controller.next7Days[i];
                    final isSel = selectedDate != null &&
                        DateUtils.isSameDay(selectedDate, date);
                    final isToday = DateUtils.isSameDay(date, DateTime.now());

                    return GestureDetector(
                      onTap: () => controller.selectDate(date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: context.wp(2).clamp(6.0, 10.0)),
                        width: context.wp(14.5).clamp(52.0, 68.0),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary : AppColors.white,
                          borderRadius: BorderRadius.circular(context.r(14)),
                          border: Border.all(
                            color: isSel ? AppColors.primary : AppColors.border,
                            width: isSel ? 2 : 1,
                          ),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('EEE').format(date),
                              style: TextStyle(
                                color: isSel ? Colors.white70 : AppColors.textSecondary,
                                fontSize: context.sp(10.5),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              DateFormat('d').format(date),
                              style: TextStyle(
                                color: isSel ? Colors.white : AppColors.textPrimary,
                                fontSize: context.sp(19),
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            if (isToday)
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  color: isSel ? Colors.white : AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: context.hp(2.5)),

              // ── Time Slot Selector ──
              _sectionTitle(context, Icons.access_time_rounded, 'Available Time Slots'),
              SizedBox(height: context.hp(1.2)),
              if (isLoadingSlots)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (slots.isEmpty)
                Container(
                  padding: EdgeInsets.all(context.r(14)),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(context.r(12)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.error, size: context.r(16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No consultation slots available on this date. Please pick another day.',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: context.sp(12.5),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: slots.map((slot) {
                    final isSel = selectedSlot == slot;
                    return GestureDetector(
                      onTap: () => controller.selectSlot(slot),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.r(16),
                          vertical: context.hp(1.2).clamp(8.0, 14.0),
                        ),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary : AppColors.white,
                          borderRadius: BorderRadius.circular(context.r(12)),
                          border: Border.all(
                            color: isSel ? AppColors.primary : AppColors.border,
                            width: isSel ? 2 : 1,
                          ),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          slot,
                          style: TextStyle(
                            color: isSel ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: context.sp(12.5),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              SizedBox(height: context.hp(2.5)),

              // ── Patient Details Form ──
              _sectionTitle(context, Icons.person_outline_rounded, 'Patient Consultation Details'),
              SizedBox(height: context.hp(1.2)),
              _AppField(
                controller: controller.nameController,
                label: 'Patient Full Name *',
                hint: 'Enter patient full name',
                icon: Icons.person_rounded,
              ),
              SizedBox(height: context.hp(1.2)),
              _AppField(
                controller: controller.phoneController,
                label: 'Contact Phone Number',
                hint: '+91 XXXXX XXXXX',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: context.hp(1.2)),
              _AppField(
                controller: controller.reasonController,
                label: 'Reason for Visit / Symptoms',
                hint: 'Describe primary symptoms or health concern...',
                icon: Icons.note_alt_outlined,
                maxLines: 3,
              ),

              SizedBox(height: context.hp(3.5)),

              // ── Confirm Booking Button ──
              SizedBox(
                width: double.infinity,
                height: context.hp(6.5).clamp(48.0, 56.0),
                child: ElevatedButton(
                  onPressed: isBooking
                      ? null
                      : () async {
                          final appointment = await controller.confirmBooking();
                          if (appointment != null) {
                            Get.toNamed(
                              AppRoutes.bookingConfirmation,
                              arguments: {'appointment': appointment},
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(15)),
                    ),
                  ),
                  child: isBooking
                      ? SizedBox(
                          width: context.r(22),
                          height: context.r(22),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Confirm Appointment',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: context.sp(15.5),
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
              SizedBox(height: context.hp(3)),
            ],
          ),
        );
      }),
    );
  }

  Widget _sectionTitle(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: context.r(16), color: AppColors.primary),
        const SizedBox(width: 7),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: context.sp(14),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}

class _AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _AppField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: context.sp(14),
        fontFamily: 'Poppins',
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textHint,
          fontSize: context.sp(13),
          fontFamily: 'Poppins',
        ),
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: context.sp(13),
          fontFamily: 'Poppins',
        ),
        prefixIcon: Icon(icon, color: AppColors.primary, size: context.r(19)),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.r(13)),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.r(13)),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.r(13)),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.r(16),
          vertical: maxLines > 1 ? context.hp(1.5) : 0,
        ),
      ),
    );
  }
}
