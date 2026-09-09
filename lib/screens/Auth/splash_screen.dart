import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../resources/AppRoutes.dart';
import '../../resources/AppTheme.dart';
import '../../resources/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5)),
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Pulse animation for the background circle
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )
      ..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 2500));

    if (Get.currentRoute == AppRoutes.splash) {
      final authController = Get.find<AuthController>();
      if (authController.isLoggedIn) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgCircleSize = context.wp(75).clamp(240.0, 420.0);

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1B2A),
                  Color(0xFF0A2030),
                  Color(0xFF051218),
                ],
              ),
            ),
          ),

          // Animated background circle
          Center(
            child: ScaleTransition(
              scale: _pulseScale,
              child: Container(
                width: bgCircleSize,
                height: bgCircleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top decoration dots
          Positioned(
            top: context.hp(10),
            right: context.wp(10),
            child: _buildDot(8, AppColors.primary.withOpacity(0.4)),
          ),
          Positioned(
            top: context.hp(15),
            right: context.wp(20),
            child: _buildDot(5, AppColors.primary.withOpacity(0.2)),
          ),
          Positioned(
            bottom: context.hp(18),
            left: context.wp(8),
            child: _buildDot(10, AppColors.coral.withOpacity(0.3)),
          ),
          Positioned(
            bottom: context.hp(23),
            left: context.wp(18),
            child: _buildDot(6, AppColors.coral.withOpacity(0.15)),
          ),

          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(scale: _logoScale, child: child),
                  );
                },
                child: _buildLogo(context),
              ),

              SizedBox(height: context.hp(3.5).clamp(20.0, 36.0)),

              // App name and tagline
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(position: _textSlide, child: child),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      'DocTalk',
                      style: TextStyle(
                        fontSize: context.sp(38),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                        fontFamily: 'Lato',
                      ),
                    ),
                    SizedBox(height: context.hp(1)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.r(16),
                        vertical: context.hp(0.8),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Your AI Health Companion',
                        style: TextStyle(
                          fontSize: context.sp(14),
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),
                    SizedBox(height: context.hp(2.5)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.wp(10).clamp(24.0, 56.0)),
                      child: Text(
                        'Doctors give you a diagnosis.\nDocTalk gives you a Saathi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.sp(14),
                          color: Colors.white.withOpacity(0.4),
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Loading indicator at bottom
          Positioned(
            bottom: context.hp(6).clamp(32.0, 64.0),
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return FadeTransition(opacity: _textOpacity, child: child);
              },
              child: Column(
                children: [
                  SizedBox(
                    width: context.r(24),
                    height: context.r(24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                  ),
                  SizedBox(height: context.hp(1.2)),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: context.sp(12),
                      color: Colors.white.withOpacity(0.3),
                      fontFamily: 'Lato',
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final logoSize = context.r(100).clamp(70.0, 120.0);
    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(28)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF089A97)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(child: Text('🩺', style: TextStyle(fontSize: context.sp(44)))),
    );
  }

  Widget _buildDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
