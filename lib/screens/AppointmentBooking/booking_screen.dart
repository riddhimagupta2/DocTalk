import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/doctor_model.dart';
import '../../models/appointment_model.dart';
import '../../resources/AppRoutes.dart';
import '../../resources/AppTheme.dart';
import '../../resources/responsive.dart';
import '../../services/appoint_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DoctorModel? _doctor;

  DateTime? _selectedDate;
  String _selectedSlot = '';
  bool _isBooking = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      _doctor = args['doctor'] as DoctorModel?;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  List<DateTime> get _next7Days {
    final today = DateTime.now();
    return List.generate(7, (i) => today.add(Duration(days: i)));
  }

  bool get _canBook =>
      _selectedDate != null &&
          _selectedSlot.isNotEmpty &&
          _nameCtrl.text.trim().isNotEmpty;

  Future<void> _confirmBooking() async {
    if (_doctor == null) {
      Get.snackbar('Error', 'Doctor information missing. Please go back.',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!_canBook) {
      Get.snackbar(
        'Incomplete Form',
        'Date, time slot aur apna naam zaroor bharen',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      final appointment = AppointmentModel(
        id: 'APT',
        doctor: _doctor!,
        date: _selectedDate!,
        timeSlot: _selectedSlot,
        patientName: _nameCtrl.text.trim(),
        patientPhone: _phoneCtrl.text.trim(),
        reason: _reasonCtrl.text.trim(),
      );

      await _appointmentService.saveAppointment(appointment);

      Get.toNamed(
        AppRoutes.bookingConfirmation,
        arguments: {'appointment': appointment},
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Booking failed. Please try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = _doctor?.name ?? 'Doctor';
    final specialization = _doctor?.specialization ?? '';
    final fee = _doctor?.consultationFee.toInt() ?? 0;
    final slots = _doctor?.availableSlots ?? [];

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
            Text('Book Appointment',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Lato')),
            Text('Fill in the details below',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: context.sp(11.5))),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.wp(4).clamp(12.0, 20.0),
          vertical: context.hp(1.5).clamp(10.0, 18.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Doctor mini card ──────────────────────────────────
            Container(
              padding: EdgeInsets.all(context.r(14)),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.primaryLight,
                  AppColors.primary.withOpacity(0.08)
                ]),
                borderRadius: BorderRadius.circular(context.r(16)),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(children: [
                Container(
                  width: context.r(48),
                  height: context.r(48),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(context.r(12)),
                  ),
                  child: Icon(Icons.person_rounded,
                      color: AppColors.primary, size: context.r(26)),
                ),
                SizedBox(width: context.wp(3).clamp(8.0, 14.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctorName,
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: context.sp(14.5),
                              fontFamily: 'Lato')),
                      Text(specialization,
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: context.sp(12.5),
                              fontWeight: FontWeight.w600)),
                      if (fee > 0)
                        Text('₹$fee consultation fee',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: context.sp(12))),
                    ],
                  ),
                ),
              ]),
            ),

            SizedBox(height: context.hp(2.5)),

            // ── Date selector ─────────────────────────────────────
            _sectionTitle(context, Icons.calendar_month_rounded, 'Select Date'),
            SizedBox(height: context.hp(1.2)),
            SizedBox(
              height: context.hp(9.5).clamp(64.0, 80.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _next7Days.length,
                itemBuilder: (_, i) {
                  final date = _next7Days[i];
                  final isSel = _selectedDate != null &&
                      DateUtils.isSameDay(_selectedDate, date);
                  final isToday =
                  DateUtils.isSameDay(date, DateTime.now());

                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedDate = date;
                      _selectedSlot = '';
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: context.wp(2).clamp(6.0, 10.0)),
                      width: context.wp(14.5).clamp(52.0, 68.0),
                      decoration: BoxDecoration(
                        color:
                        isSel ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(context.r(14)),
                        border: Border.all(
                          color: isSel
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSel ? 2 : 1,
                        ),
                        boxShadow: isSel
                            ? [
                          BoxShadow(
                              color: AppColors.primary
                                  .withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              color: isSel
                                  ? Colors.white70
                                  : AppColors.textSecondary,
                              fontSize: context.sp(10.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              color: isSel
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontSize: context.sp(20),
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Lato',
                            ),
                          ),
                          if (isToday)
                            Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? Colors.white
                                    : AppColors.primary,
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

            // ── Time slot selector ────────────────────────────────
            _sectionTitle(context, Icons.access_time_rounded, 'Select Time Slot'),
            SizedBox(height: context.hp(1.2)),
            slots.isEmpty
                ? Container(
              padding: EdgeInsets.all(context.r(14)),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.07),
                borderRadius: BorderRadius.circular(context.r(12)),
              ),
              child: Row(children: [
                Icon(Icons.info_outline,
                    color: AppColors.error, size: context.r(16)),
                const SizedBox(width: 8),
                Text('No slots available for this doctor',
                    style: TextStyle(color: AppColors.error, fontSize: context.sp(13))),
              ]),
            )
                : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: slots.map((slot) {
                final isSel = _selectedSlot == slot;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedSlot = slot),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                        horizontal: context.r(16), vertical: context.hp(1.2).clamp(8.0, 14.0)),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.primary
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(context.r(12)),
                      border: Border.all(
                        color: isSel
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSel ? 2 : 1,
                      ),
                      boxShadow: isSel
                          ? [
                        BoxShadow(
                            color: AppColors.primary
                                .withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]
                          : [],
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        color: isSel
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: context.sp(13),
                        fontFamily: 'Lato',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: context.hp(2.5)),

            // ── Patient details ───────────────────────────────────
            _sectionTitle(
                context, Icons.person_outline_rounded, 'Your Details'),
            SizedBox(height: context.hp(1.2)),
            _AppField(
              controller: _nameCtrl,
              label: 'Full Name *',
              hint: 'Apna poora naam likhein',
              icon: Icons.person_rounded,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: context.hp(1.2)),
            _AppField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              hint: '+91 XXXXX XXXXX',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: context.hp(1.2)),
            _AppField(
              controller: _reasonCtrl,
              label: 'Reason for Visit',
              hint: 'Symptoms ya concern likhein...',
              icon: Icons.note_alt_outlined,
              maxLines: 3,
            ),

            SizedBox(height: context.hp(3.5)),

            // ── Confirm button ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: context.hp(6.5).clamp(48.0, 56.0),
              child: ElevatedButton(
                onPressed: _isBooking ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _canBook ? AppColors.primary : AppColors.textHint,
                  foregroundColor: Colors.white,
                  elevation: _canBook ? 2 : 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(15))),
                ),
                child: _isBooking
                    ? SizedBox(
                    width: context.r(22),
                    height: context.r(22),
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                    : Text('Confirm Appointment',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: context.sp(16),
                        fontFamily: 'Lato')),
              ),
            ),
            SizedBox(height: context.hp(3)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, IconData icon, String title) {
    return Row(children: [
      Icon(icon, size: context.r(16), color: AppColors.primary),
      const SizedBox(width: 7),
      Text(title,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: context.sp(14.5),
              fontFamily: 'Lato')),
    ]);
  }
}

class _AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _AppField({
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
      style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: context.sp(14.5),
          fontFamily: 'Lato'),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle:
        TextStyle(color: AppColors.textHint, fontSize: context.sp(13.5)),
        labelStyle: TextStyle(
            color: AppColors.textSecondary, fontSize: context.sp(13.5)),
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
          borderSide:
          const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: context.r(16), vertical: maxLines > 1 ? context.hp(1.5) : 0),
      ),
    );
  }
}
