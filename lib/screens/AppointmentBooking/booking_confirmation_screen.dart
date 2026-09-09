import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../resources/AppRoutes.dart';
import '../../resources/AppTheme.dart';
import '../../resources/responsive.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut);
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    AppointmentModel? appointment;

    if (args != null &&
        args is Map &&
        args.containsKey('appointment') &&
        args['appointment'] is AppointmentModel) {
      appointment = args['appointment'] as AppointmentModel;
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: appointment == null
            ? _buildFallback(context)
            : _buildSuccess(context, appointment),
      ),
    );
  }

  /// ---------------- FALLBACK UI ----------------
  Widget _buildFallback(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: context.r(72)),
          SizedBox(height: context.hp(2.5)),
          Text(
            'Appointment Booked!',
            style: TextStyle(
              fontSize: context.sp(22),
              fontWeight: FontWeight.w800,
              fontFamily: 'Lato',
            ),
          ),
          SizedBox(height: context.hp(3)),
          ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(12))),
            ),
            child: Text('Back to Home', style: TextStyle(fontSize: context.sp(14))),
          ),
        ],
      ),
    );
  }

  /// ---------------- SUCCESS UI ----------------
  Widget _buildSuccess(BuildContext context, AppointmentModel appt) {
    final doctor = appt.doctor;

    final bookingId = appt.id.length > 8
        ? appt.id.substring(appt.id.length - 8)
        : appt.id;

    final successIconSize = context.r(100).clamp(70.0, 120.0);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.wp(6).clamp(16.0, 32.0),
        ),
        child: Column(
          children: [
            SizedBox(height: context.hp(4).clamp(24.0, 48.0)),

            /// Animated Icon
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: successIconSize,
                height: successIconSize,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: context.r(58),
                ),
              ),
            ),

            SizedBox(height: context.hp(2)),

            Text(
              'Appointment Booked!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.sp(24),
                fontWeight: FontWeight.w800,
                fontFamily: 'Lato',
              ),
            ),

            SizedBox(height: context.hp(0.8)),

            Text(
              'Booking ID: #$bookingId',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.sp(13),
              ),
            ),

            SizedBox(height: context.hp(3)),

            // Details card
            Container(
              padding: EdgeInsets.all(context.r(20)),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(context.r(18)),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _RowItem('Doctor', doctor.name, isBold: true),
                  SizedBox(height: context.hp(1.2)),
                  _RowItem('Specialization', doctor.specialization),
                  SizedBox(height: context.hp(1.2)),
                  _RowItem('Date', DateFormat('dd MMM yyyy').format(appt.date)),
                  SizedBox(height: context.hp(1.2)),
                  _RowItem('Time Slot', appt.timeSlot),
                  SizedBox(height: context.hp(1.2)),
                  _RowItem('Patient', appt.patientName),
                ],
              ),
            ),

            SizedBox(height: context.hp(4)),

            SizedBox(
              width: double.infinity,
              height: context.hp(6.2).clamp(46.0, 56.0),
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.r(14)),
                  ),
                ),
                child: Text('Done', style: TextStyle(fontSize: context.sp(16), fontWeight: FontWeight.bold)),
              ),
            ),

            SizedBox(height: context.hp(4)),
          ],
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _RowItem(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: context.sp(13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: context.sp(13),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
