import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/responsive.dart';
import '../../../resources/app_routes.dart';
import '../controllers/doctor_appointment_controller.dart';
import '../models/doctor_portal_models.dart';
import '../../../models/appointment_model.dart';

class DoctorPatientDetailScreen extends StatelessWidget {
  const DoctorPatientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArg = Get.arguments;
    final AppointmentModel? appointmentModel = rawArg is AppointmentModel ? rawArg : null;
    final DoctorAppointmentItem? legacyItem = rawArg is DoctorAppointmentItem ? rawArg : null;

    if (appointmentModel == null && legacyItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient Details')),
        body: const Center(child: Text('No patient details provided.')),
      );
    }

    final id = appointmentModel?.appointmentId ?? legacyItem?.id ?? '';
    final patientName = appointmentModel?.patientName ?? legacyItem?.patientName ?? 'Patient';
    final patientAge = appointmentModel?.patientAge ?? legacyItem?.patientAge.toString() ?? '30';
    final patientGender = appointmentModel?.patientGender ?? legacyItem?.patientGender ?? 'General';
    final date = appointmentModel?.date ?? legacyItem?.date ?? '';
    final timeSlot = appointmentModel?.time ?? legacyItem?.timeSlot ?? '';
    final symptoms = appointmentModel?.symptoms ?? legacyItem?.symptoms ?? 'General checkup';
    final status = (appointmentModel?.status.value.toLowerCase() ?? legacyItem?.status.toLowerCase() ?? 'pending');
    final controller = Get.find<DoctorAppointmentController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patient Consultation Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(4).clamp(16.0, 24.0),
            vertical: context.hp(2).clamp(12.0, 20.0),
          ),
          children: [
            // Patient Profile Card
            Container(
              padding: EdgeInsets.all(context.r(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      patientName.isNotEmpty ? patientName[0] : 'P',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  SizedBox(width: context.wp(3.5)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName,
                          style: TextStyle(
                            fontSize: context.sp(16),
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$patientAge Years • $patientGender',
                          style: TextStyle(
                            fontSize: context.sp(12.5),
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Appointment: $date at $timeSlot',
                          style: TextStyle(
                            fontSize: context.sp(11.5),
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: context.hp(2)),

            // Chief Complaint / Symptoms Card
            _buildDetailCard(
              context,
              title: 'Reported Chief Symptoms & Notes',
              icon: Icons.notes_rounded,
              child: Text(
                symptoms,
                style: TextStyle(
                  fontSize: context.sp(13.5),
                  color: AppColors.navy,
                  height: 1.4,
                ),
              ),
            ),

            SizedBox(height: context.hp(2)),

            // Pre-Consultation Vitals & Triage
            _buildDetailCard(
              context,
              title: 'Preliminary AI Triage Assessment',
              icon: Icons.health_and_safety_rounded,
              child: Column(
                children: [
                  _buildTriageRow(context, 'Triage Urgency', 'Routine / Mild', const Color(0xFF10B981)),
                  const Divider(height: 16),
                  _buildTriageRow(context, 'Reported Temperature', '99.1 °F', AppColors.navy),
                  const Divider(height: 16),
                  _buildTriageRow(context, 'Known Allergies', 'None reported', AppColors.navy),
                ],
              ),
            ),

            SizedBox(height: context.hp(3.5)),

            // Action Buttons
            if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.rejectAppointment(id, 'Doctor unavailable');
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Decline Request', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.acceptAppointment(id);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Accept Consultation'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.doctorPrescription, arguments: appointmentModel ?? legacyItem),
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Start Consultation & Issue Rx'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            SizedBox(height: context.hp(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(context.r(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTriageRow(BuildContext context, String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: context.sp(13),
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: context.sp(13),
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
