import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../resources/app_colors.dart';
import '../../resources/app_routes.dart';
import '../../resources/responsive.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(6).clamp(20.0, 36.0),
            vertical: context.hp(3).clamp(16.0, 32.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.hp(2)),

              // Header Branding
              Row(
                children: [
                  Container(
                    width: context.r(44),
                    height: context.r(44),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF089A97)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('🩺', style: TextStyle(fontSize: context.sp(22))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'DocTalk',
                    style: TextStyle(
                      fontSize: context.sp(24),
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                      fontFamily: 'Lato',
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.hp(4)),

              // Title
              Text(
                'Welcome! 👋\nChoose Your Role',
                style: TextStyle(
                  fontSize: context.sp(28),
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                  height: 1.2,
                  fontFamily: 'Lato',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select how you want to use DocTalk to get personalized health experiences.',
                style: TextStyle(
                  fontSize: context.sp(13.5),
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              SizedBox(height: context.hp(4)),

              // Option 1: Patient Card
              _buildRoleCard(
                context,
                title: 'Continue as Patient',
                subtitle: 'Consult AI assistant, find nearby verified doctors, analyze medical images & book appointments.',
                badge: 'PATIENT PORTAL',
                badgeColor: AppColors.primary,
                icon: Icons.person_rounded,
                iconBg: AppColors.primary.withValues(alpha: 0.12),
                iconColor: AppColors.primary,
                onTap: () => Get.toNamed(AppRoutes.login, arguments: {'role': 'patient'}),
              ),

              SizedBox(height: context.hp(2.5)),

              // Option 2: Doctor Card
              _buildRoleCard(
                context,
                title: 'Continue as Doctor',
                subtitle: 'Manage consultation hours, accept patient appointments, issue digital prescriptions & emergency duty.',
                badge: 'DOCTOR PORTAL',
                badgeColor: const Color(0xFF8B5CF6),
                icon: Icons.medical_services_rounded,
                iconBg: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                iconColor: const Color(0xFF8B5CF6),
                onTap: () => Get.toNamed(AppRoutes.doctorRegistration),
              ),

              const Spacer(),

              // Admin notice footer
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.admin_panel_settings_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'System Admins: Use assigned credentials in Login',
                          style: TextStyle(
                            fontSize: context.sp(11.5),
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.hp(1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(context.r(18)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(context.r(14)),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: context.r(28)),
            ),
            SizedBox(width: context.wp(4)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: context.sp(9.5),
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.sp(12),
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
