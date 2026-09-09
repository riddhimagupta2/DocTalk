import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/nav_controller.dart';
import '../resources/AppTheme.dart';
import '../resources/responsive.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontSize: context.sp(18),
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.wp(5).clamp(16.0, 24.0),
          vertical: context.hp(2).clamp(12.0, 20.0),
        ),
        child: Column(
          children: [
            SizedBox(height: context.hp(1.2)),

            // Profile card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.r(22)),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF089A97)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(context.r(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: context.r(76),
                    height: context.r(76),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('👤', style: TextStyle(fontSize: context.sp(34))),
                    ),
                  ),
                  SizedBox(height: context.hp(1.5)),
                  Obx(() => Text(
                        authController.userName,
                        style: TextStyle(
                          fontSize: context.sp(22),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Lato',
                        ),
                      )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        authController.userEmail,
                        style: TextStyle(
                          fontSize: context.sp(14),
                          color: Colors.white.withOpacity(0.75),
                        ),
                      )),
                ],
              ),
            ),

            SizedBox(height: context.hp(2.5)),

            // Menu items
            _ProfileMenuTile(
              icon: Icons.history_rounded,
              title: 'Consultation History',
              subtitle: 'View all past health checks & appointments',
              onTap: () {
                final navController = Get.find<NavController>();
                navController.goToHistory();
              },
            ),
            _ProfileMenuTile(
              icon: Icons.local_hospital_outlined,
              title: 'Find Doctors',
              subtitle: 'Discover nearby clinics & specialists',
              onTap: () {
                final navController = Get.find<NavController>();
                navController.goToDoctors();
              },
            ),
            _ProfileMenuTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage health reminders',
              onTap: () {},
            ),
            _ProfileMenuTile(
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              subtitle: 'Your health data is safe with us',
              onTap: () {},
            ),
            _ProfileMenuTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'FAQs and support contact',
              onTap: () {},
            ),
            _ProfileMenuTile(
              icon: Icons.info_outline_rounded,
              title: 'About DocTalk',
              subtitle: 'Version 1.0.0',
              onTap: () {},
            ),

            SizedBox(height: context.hp(1.5)),

            // Disclaimer
            Container(
              padding: EdgeInsets.all(context.r(16)),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.r(12)),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚠️', style: TextStyle(fontSize: context.sp(16))),
                  SizedBox(width: context.wp(2.5).clamp(8.0, 14.0)),
                  Expanded(
                    child: Text(
                      'DocTalk provides preliminary AI health guidance for informational purposes. Always consult a qualified medical professional for clinical diagnosis and treatment.',
                      style: TextStyle(
                        fontSize: context.sp(12),
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: context.hp(2.5)),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: context.hp(6).clamp(46.0, 54.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.r(16))),
                      title: Text('Logout?',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: context.sp(17))),
                      content: Text(
                        'Are you sure you want to logout from DocTalk?',
                        style: TextStyle(fontSize: context.sp(14), height: 1.5),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel', style: TextStyle(fontSize: context.sp(14))),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                            authController.logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            minimumSize: const Size(0, 0),
                            padding: EdgeInsets.symmetric(
                                horizontal: context.r(16), vertical: context.hp(1)),
                          ),
                          child: Text('Logout', style: TextStyle(color: Colors.white, fontSize: context.sp(14))),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.logout_rounded, size: context.r(18)),
                label: Text('Logout', style: TextStyle(fontSize: context.sp(15), fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  foregroundColor: AppColors.error,
                  elevation: 0,
                  side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
                ),
              ),
            ),

            SizedBox(height: context.hp(10)),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.hp(1.0).clamp(8.0, 12.0)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: context.r(40),
          height: context.r(40),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(context.r(10)),
          ),
          child: Icon(icon, color: AppColors.primary, size: context.r(20)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: context.sp(15),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: context.sp(12),
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded,
            color: AppColors.textHint, size: context.r(20)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.r(14),
          vertical: context.hp(0.5).clamp(2.0, 6.0),
        ),
      ),
    );
  }
}
