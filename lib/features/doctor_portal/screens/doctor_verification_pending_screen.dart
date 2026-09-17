import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/responsive.dart';
import '../controllers/doctor_portal_controller.dart';
import '../../../resources/app_routes.dart';

class DoctorVerificationPendingScreen extends StatelessWidget {
  const DoctorVerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorPortalController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verification Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.offAllNamed(AppRoutes.home),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Check Status',
            onPressed: () async {
              await controller.fetchProfile();
              if (controller.isApproved) {
                Get.offNamed(AppRoutes.doctorDashboard);
              } else {
                Get.snackbar(
                  'Status Check',
                  'Your profile is still under review by our medical verification board.',
                  backgroundColor: AppColors.navy,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(5).clamp(16.0, 28.0),
            vertical: context.hp(2.5).clamp(16.0, 32.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: context.r(90),
                height: context.r(90),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                ),
                child: Center(
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    color: const Color(0xFFD97706),
                    size: context.r(46),
                  ),
                ),
              ),
              SizedBox(height: context.hp(2)),
              Text(
                'Application Under Review',
                style: TextStyle(
                  fontSize: context.sp(20),
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.hp(1)),
              Text(
                'Thank you for registering with DocTalk. To maintain healthcare trust and regulatory compliance, we verify every doctor\'s medical credentials before opening consultations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.sp(13.5),
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: context.hp(3.5)),

              // Verification Progress Stepper Card
              Container(
                padding: EdgeInsets.all(context.r(20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildStep(
                      context,
                      isCompleted: true,
                      title: 'Account Registration',
                      subtitle: 'Basic details & contact registered',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                    _buildStepDivider(),
                    _buildStep(
                      context,
                      isCompleted: true,
                      title: 'License & Certificate Submission',
                      subtitle: 'Medical council registration received',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                    _buildStepDivider(),
                    _buildStep(
                      context,
                      isCompleted: false,
                      isCurrent: true,
                      title: 'Credential Verification (In Progress)',
                      subtitle: 'Our compliance team is verifying credentials',
                      icon: Icons.sync_rounded,
                      color: const Color(0xFFD97706),
                    ),
                    _buildStepDivider(),
                    _buildStep(
                      context,
                      isCompleted: false,
                      title: 'Portal Activation',
                      subtitle: 'Accept consultations & manage digital clinics',
                      icon: Icons.radio_button_unchecked_rounded,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.hp(3.5)),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: () {
                  // Direct bypass for demonstration / dev approval
                  if (controller.profile.value != null) {
                    controller.profile.value = controller.profile.value!.copyWith(
                      isVerified: true,
                      verificationStatus: 'approved',
                    );
                    Get.offNamed(AppRoutes.doctorDashboard);
                  }
                },
                icon: const Icon(Icons.verified_user_rounded),
                label: const Text('Simulate Approval & Enter Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: context.hp(1.5)),
              OutlinedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.home),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Return to Patient App',
                  style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required bool isCompleted,
    bool isCurrent = false,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: context.r(24)),
        SizedBox(width: context.wp(3)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w700,
                  color: isCurrent ? const Color(0xFFD97706) : AppColors.navy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: context.sp(12),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
      height: 24,
      width: 2,
      color: Colors.grey.shade300,
    );
  }
}
