import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../resources/AppRoutes.dart';
import '../../resources/AppTheme.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    const Text(
                      'Welcome to\nDocTalk 🩺',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.15,
                        letterSpacing: -1,
                        fontFamily: 'Lato',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'How would you like to use the app?',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Patient Card
                    _RoleCard(
                      emoji: '🤒',
                      title: 'I Need Help',
                      subtitle: 'Get AI health advice, find nearby helpers, and send SOS alerts',
                      gradient: const [AppColors.primary, Color(0xFF089A97)],
                      onTap: () => Get.toNamed(AppRoutes.signup),
                    ),

                    const SizedBox(height: 20),

                    // Helper Card
                    _RoleCard(
                      emoji: '🤝',
                      title: 'I Can Help',
                      subtitle: 'ASHA worker, chemist, clinic, or volunteer — register to assist patients nearby',
                      gradient: const [Color(0xFF9B59B6), Color(0xFF6C3483)],
                      onTap: () => Get.toNamed(AppRoutes.helperSignup),
                    ),

                    const SizedBox(height: 48),

                    // Already have account
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.login),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Lato')),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}