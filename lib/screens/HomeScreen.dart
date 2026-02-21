import 'package:doctalk/screens/profile_screen.dart' hide NavController;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/nav_controller.dart';
import '../resources/AppTheme.dart';
import 'AnonymousChat/community_screen.dart';
import 'chat_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavController>();
    final authController = Get.find<AuthController>();

    final screens = [
      const _HomeTab(),
      const HistoryScreen(),
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
    return GestureDetector(
      onTap: () {
        Get.to(
          () => const ChatScreen(),
          transition: Transition.downToUp,
          duration: const Duration(milliseconds: 350),
          binding: _ChatBinding(),
        );
      },
      child: Container(
        width: 62,
        height: 62,
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.add_rounded, color: Colors.white, size: 28)],
        ),
      ),
    );
  }
}

// Lazy binding for chat
class _ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(_ChatControllerLazy());
  }
}

// Just to trigger ChatController init
class _ChatControllerLazy {
  _ChatControllerLazy();
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
        height: 60,
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                currentIndex: navController.currentIndex.value,
                onTap: () => navController.changePage(0),
              ),

              // History
              _NavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history_rounded,
                label: 'History',
                index: 1,
                currentIndex: navController.currentIndex.value,
                onTap: () => navController.changePage(1),
              ),

              // Spacer for FAB
              const SizedBox(width: 60),

              // Profile
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                index: 2,
                currentIndex: navController.currentIndex.value,
                onTap: () => navController.changePage(2),
              ),

              // Settings placeholder (can be expanded later)
              _NavItem(
                icon: Icons.info_outline_rounded,
                activeIcon: Icons.info_rounded,
                label: 'About',
                index: 3,
                currentIndex: navController.currentIndex.value,
                onTap: () {
                  Get.snackbar(
                    'DocTalk v1.0',
                    'Your AI Health Companion 🩺',
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    borderRadius: 12,
                    margin: const EdgeInsets.all(16),
                  );
                },
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive ? AppColors.primary : AppColors.textHint,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.primary : AppColors.textHint,
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

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
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                              fontFamily: 'Lato',
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'How are you feeling today?',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ═══════════════════════════════════════════════
                  // ✨ NEW: COMMUNITY BUTTON (REPLACED NOTIFICATIONS)
                  // ═══════════════════════════════════════════════
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        () => const CommunityScreen(),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF9B59B6),
                            Color(0xFF8E44AD),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9B59B6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  // ═══════════════════════════════════════════════
                ],
              ),

              const SizedBox(height: 24),

              // Hero CTA Card
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
                  padding: const EdgeInsets.all(24),
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
                    borderRadius: BorderRadius.circular(24),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'AI HEALTH CHECK',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Not feeling well?\nTalk to DocTalk',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.25,
                                fontFamily: 'Lato',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Start Chat',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('🩺', style: TextStyle(fontSize: 72)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ═══════════════════════════════════════════════
              // ✨ NEW: ANONYMOUS COMMUNITY CARD
              // ═══════════════════════════════════════════════
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
                  padding: const EdgeInsets.all(20),
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
                    borderRadius: BorderRadius.circular(20),
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
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text('🎭', style: TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anonymous Community',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'Lato',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Share & learn from others anonymously',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ═══════════════════════════════════════════════

              const SizedBox(height: 28),

              // Section: Quick Symptom Shortcuts
              const Text(
                'Quick Start',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Lato',
                ),
              ),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _SymptomCard(
                    emoji: '🤕',
                    title: 'Head & Fever',
                    color: const Color(0xFFFFF3D6),
                    borderColor: const Color(0xFFFFC947),
                    symptom: 'Sar dard aur bukhar hai',
                  ),
                  _SymptomCard(
                    emoji: '🫁',
                    title: 'Cough & Cold',
                    color: const Color(0xFFD0F4F4),
                    borderColor: AppColors.primary,
                    symptom: 'Khasi aur nazla ho raha hai',
                  ),
                  _SymptomCard(
                    emoji: '🤢',
                    title: 'Stomach Issues',
                    color: const Color(0xFFFFE8E4),
                    borderColor: AppColors.coral,
                    symptom: 'Pet mein dard aur ulti hai',
                  ),
                  _SymptomCard(
                    emoji: '🧠',
                    title: 'Mental Health',
                    color: const Color(0xFFEDE9FF),
                    borderColor: const Color(0xFF7B61FF),
                    symptom: 'Stress aur anxiety feel ho rahi hai',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your data is safe 🔒',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'All chats are private and encrypted',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Space for FAB
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
        // Navigate to chat with pre-filled symptom
        Get.to(
          () => ChatScreen(initialSymptom: symptom),
          transition: Transition.downToUp,
          duration: const Duration(milliseconds: 350),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
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
