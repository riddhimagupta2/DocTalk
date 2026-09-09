import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/nav_controller.dart';
import '../resources/AppTheme.dart';
import '../resources/AppRoutes.dart';
import '../resources/responsive.dart';
import 'AnonymousChat/community_screen.dart';
import 'chat_screen.dart';
import 'doctor_finder_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavController>();

    final screens = [
      const _HomeTab(),
      const HistoryScreen(),
      const DoctorFinderScreen(),
      const ProfileScreen(),
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: navController.currentIndex.value,
          children: screens,
        ),
        bottomNavigationBar: _BottomNavBar(navController: navController),
        floatingActionButton: _CenterFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

// ── CENTER FAB ──
class _CenterFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fabSize = context.r(62);

    return GestureDetector(
      onTap: () {
        Get.to(
          () => const ChatScreen(),
          transition: Transition.downToUp,
          duration: const Duration(milliseconds: 350),
        );
      },
      child: Container(
        width: fabSize,
        height: fabSize,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF089A97)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: context.r(28)),
        ),
      ),
    );
  }
}

// ── BOTTOM NAV BAR ──
class _BottomNavBar extends StatelessWidget {
  final NavController navController;

  const _BottomNavBar({required this.navController});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: AppColors.white,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      child: SizedBox(
        height: context.hp(7.5).clamp(54.0, 68.0),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                currentIndex: navController.currentIndex.value,
                onTap: () => navController.goToHome(),
              ),
              _NavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history_rounded,
                label: 'History',
                index: 1,
                currentIndex: navController.currentIndex.value,
                onTap: () => navController.goToHistory(),
              ),
              SizedBox(width: context.wp(14).clamp(48.0, 72.0)),
              _NavItem(
                icon: Icons.medical_services_outlined,
                activeIcon: Icons.medical_services_rounded,
                label: 'Doctors',
                index: 2,
                currentIndex: navController.currentIndex.value,
                onTap: () => navController.goToDoctors(),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                index: 3,
                currentIndex: navController.currentIndex.value,
                onTap: () => navController.goToProfile(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    const activeColor = AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: context.wp(14).clamp(50.0, 70.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive ? activeColor : AppColors.textHint,
                size: context.r(24),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: context.sp(10),
                color: isActive ? activeColor : AppColors.textHint,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── HOME TAB CONTENT ──
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final navController = Get.find<NavController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.wp(5).clamp(16.0, 28.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.hp(2.5)),

              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            'Namaste, ${authController.userFirstName}! 🙏',
                            style: TextStyle(
                              fontSize: context.sp(24),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                              fontFamily: 'Lato',
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'How are you feeling today?',
                          style: TextStyle(
                            fontSize: context.sp(14),
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Community shortcut button
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        () => const CommunityScreen(),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                    child: Container(
                      width: context.r(46),
                      height: context.r(46),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF9B59B6),
                            Color(0xFF8E44AD),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(context.r(14)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9B59B6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.people_alt_rounded,
                        color: Colors.white,
                        size: context.r(22),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.hp(2.8)),

              // Hero CTA Card - AI Health Check
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => const ChatScreen(),
                    transition: Transition.downToUp,
                    duration: const Duration(milliseconds: 350),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.r(22)),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        Color(0xFF089A97),
                        Color(0xFF056B68),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(context.r(24)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.r(10),
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'AI HEALTH CHECK',
                                style: TextStyle(
                                  fontSize: context.sp(10),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            SizedBox(height: context.hp(1.2)),
                            Text(
                              'Not feeling well?\nTalk to DocTalk',
                              style: TextStyle(
                                fontSize: context.sp(22),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.25,
                                fontFamily: 'Lato',
                              ),
                            ),
                            SizedBox(height: context.hp(1.2)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.r(16),
                                vertical: context.hp(0.9),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Start Chat',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: context.sp(14),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.primary,
                                    size: context.r(16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: context.wp(2.5)),
                      Text('🩺', style: TextStyle(fontSize: context.sp(62))),
                    ],
                  ),
                ),
              ),

              SizedBox(height: context.hp(2)),

              // AI Medical Image Analysis Card
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.imageAnalysis),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.r(20)),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6C5CE7),
                        Color(0xFFA29BFE),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(context.r(20)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: context.r(52),
                        height: context.r(52),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(context.r(14)),
                        ),
                        child: Center(
                          child: Text('📸', style: TextStyle(fontSize: context.sp(26))),
                        ),
                      ),
                      SizedBox(width: context.wp(4).clamp(12.0, 18.0)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'AI Image Analysis',
                                  style: TextStyle(
                                    fontSize: context.sp(17),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.sp(10),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Analyze rashes, burns, cuts & skin symptoms',
                              style: TextStyle(
                                fontSize: context.sp(12),
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: context.r(16),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: context.hp(2)),

              // Find Doctors Card
              GestureDetector(
                onTap: () => navController.goToDoctors(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.r(20)),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2980B9),
                        Color(0xFF3498DB),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(context.r(20)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2980B9).withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: context.r(52),
                        height: context.r(52),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(context.r(14)),
                        ),
                        child: Center(
                          child: Text('👨‍⚕️', style: TextStyle(fontSize: context.sp(26))),
                        ),
                      ),
                      SizedBox(width: context.wp(4).clamp(12.0, 18.0)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find Nearby Doctors',
                              style: TextStyle(
                                fontSize: context.sp(17),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'Lato',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Discover specialists & book visits',
                              style: TextStyle(
                                fontSize: context.sp(12.5),
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(context.r(8)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(context.r(10)),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: context.r(20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: context.hp(2)),

              // Anonymous Community Card
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => const CommunityScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.r(20)),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF9B59B6),
                        Color(0xFF8E44AD),
                        Color(0xFF6C3483),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(context.r(20)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9B59B6).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: context.r(52),
                        height: context.r(52),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(context.r(14)),
                        ),
                        child: Center(
                          child: Text('🎭', style: TextStyle(fontSize: context.sp(26))),
                        ),
                      ),
                      SizedBox(width: context.wp(4).clamp(12.0, 18.0)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anonymous Community',
                              style: TextStyle(
                                fontSize: context.sp(17),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'Lato',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Share & learn from others anonymously',
                              style: TextStyle(
                                fontSize: context.sp(12.5),
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(context.r(8)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(context.r(10)),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: context.r(20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: context.hp(3)),

              // Section: Quick Symptom Shortcuts
              Text(
                'Quick Start',
                style: TextStyle(
                  fontSize: context.sp(18),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Lato',
                ),
              ),
              SizedBox(height: context.hp(1.5)),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: context.isTabletDevice ? 4 : 2,
                mainAxisSpacing: context.hp(1.5).clamp(10.0, 16.0),
                crossAxisSpacing: context.wp(3).clamp(10.0, 16.0),
                childAspectRatio: context.isTabletDevice ? 1.4 : 1.3,
                children: const [
                  _SymptomCard(
                    emoji: '🤕',
                    title: 'Head & Fever',
                    color: Color(0xFFFFF3D6),
                    borderColor: Color(0xFFFFC947),
                    symptom: 'Sar dard aur bukhar hai',
                  ),
                  _SymptomCard(
                    emoji: '🫁',
                    title: 'Cough & Cold',
                    color: Color(0xFFD0F4F4),
                    borderColor: AppColors.primary,
                    symptom: 'Khasi aur nazla ho raha hai',
                  ),
                  _SymptomCard(
                    emoji: '🤢',
                    title: 'Stomach Issues',
                    color: Color(0xFFFFE8E4),
                    borderColor: AppColors.coral,
                    symptom: 'Pet mein dard aur ulti hai',
                  ),
                  _SymptomCard(
                    emoji: '🧠',
                    title: 'Mental Health',
                    color: Color(0xFFEDE9FF),
                    borderColor: Color(0xFF7B61FF),
                    symptom: 'Stress aur anxiety feel ho rahi hai',
                  ),
                ],
              ),

              SizedBox(height: context.hp(3)),

              // Info card
              Container(
                padding: EdgeInsets.all(context.r(16)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(context.r(16)),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: context.r(44),
                      height: context.r(44),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(context.r(12)),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                        size: context.r(22),
                      ),
                    ),
                    SizedBox(width: context.wp(3.5).clamp(10.0, 16.0)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your data is safe 🔒',
                            style: TextStyle(
                              fontSize: context.sp(14),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'All chats are private and encrypted',
                            style: TextStyle(
                              fontSize: context.sp(12),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.hp(12)), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }
}

class _SymptomCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final Color borderColor;
  final String symptom;

  const _SymptomCard({
    required this.emoji,
    required this.title,
    required this.color,
    required this.borderColor,
    required this.symptom,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ChatScreen(initialSymptom: symptom),
          transition: Transition.downToUp,
          duration: const Duration(milliseconds: 350),
        );
      },
      child: Container(
        padding: EdgeInsets.all(context.r(16)),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(color: borderColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(emoji, style: TextStyle(fontSize: context.sp(28))),
            Text(
              title,
              style: TextStyle(
                fontSize: context.sp(14),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
