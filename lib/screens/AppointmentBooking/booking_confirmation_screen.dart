import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../resources/AppTheme.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final AppointmentModel appointment = args['appointment'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Success animation
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
              ),
              const SizedBox(height: 24),

              const Text(
                'Appointment Confirmed!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your appointment has been successfully booked.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),

              const SizedBox(height: 32),

              // Booking details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking ID
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Booking ID',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text(
                          appointment.id.substring(appointment.id.length - 8),
                          style: const TextStyle(
                              color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Doctor
                    _ConfirmRow(
                      icon: Icons.person,
                      label: 'Doctor',
                      value: appointment.doctor.name,
                    ),
                    const SizedBox(height: 14),
                    _ConfirmRow(
                      icon: Icons.medical_services_outlined,
                      label: 'Specialization',
                      value: appointment.doctor.specialization,
                    ),
                    const SizedBox(height: 14),
                    _ConfirmRow(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: DateFormat('EEEE, d MMMM yyyy').format(appointment.date),
                    ),
                    const SizedBox(height: 14),
                    _ConfirmRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: appointment.timeSlot,
                    ),
                    const SizedBox(height: 14),
                    _ConfirmRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: appointment.doctor.address,
                    ),
                    const SizedBox(height: 14),
                    _ConfirmRow(
                      icon: Icons.person_outline,
                      label: 'Patient',
                      value: appointment.patientName,
                    ),
                    const SizedBox(height: 14),
                    _ConfirmRow(
                      icon: Icons.currency_rupee,
                      label: 'Fee',
                      value: '₹${appointment.doctor.consultationFee.toInt()}',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, color: AppColors.success, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Confirmed',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Done button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to root (chat screen typically)
                    Get.until((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.offAllNamed('/doctor-finder',
                    arguments: {'specialist': appointment.doctor.specialization}),
                child: const Text(
                  'Book Another Appointment',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConfirmRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}