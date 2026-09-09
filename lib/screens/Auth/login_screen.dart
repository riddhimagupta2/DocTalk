import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../resources/AppRoutes.dart';
import '../../resources/AppTheme.dart';
import '../../resources/responsive.dart';
import '../../widgets/CustomWidgets/custom_button.dart';
import '../../widgets/CustomWidgets/custom_textfields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      _authController.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.wp(6).clamp(16.0, 32.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.hp(5).clamp(24.0, 48.0)),

                  // Top Logo
                  _buildTopLogo(context),

                  SizedBox(height: context.hp(4).clamp(20.0, 40.0)),

                  // Title
                  Text(
                    'Welcome\nBack! 👋',
                    style: TextStyle(
                      fontSize: context.sp(34),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.15,
                      letterSpacing: -1,
                      fontFamily: 'Lato',
                    ),
                  ),
                  SizedBox(height: context.hp(1)),
                  Text(
                    'Login to your MediSaathi account',
                    style: TextStyle(
                      fontSize: context.sp(15),
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),

                  SizedBox(height: context.hp(3.5).clamp(20.0, 36.0)),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'you@example.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return AppStrings.emailRequired;
                            }
                            if (!GetUtils.isEmail(val)) {
                              return AppStrings.emailInvalid;
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: context.hp(1.8).clamp(12.0, 18.0)),

                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: context.r(20),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          onFieldSubmitted: (_) => _handleLogin(),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return AppStrings.passwordRequired;
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: context.hp(3).clamp(18.0, 28.0)),

                        // Login Button
                        Obx(
                          () => CustomButton(
                            label: 'Login',
                            isLoading: _authController.isLoading.value,
                            onPressed: _handleLogin,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.hp(2.5)),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: context.r(16)),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.6),
                            fontSize: context.sp(14),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),

                  SizedBox(height: context.hp(2.5)),

                  // Sign Up redirect
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: context.sp(15),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.signup),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: context.sp(15),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.hp(3.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopLogo(BuildContext context) {
    return Row(
      children: [
        Container(
          width: context.r(48),
          height: context.r(48),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF089A97)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(context.r(14)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text('🩺', style: TextStyle(fontSize: context.sp(22))),
          ),
        ),
        SizedBox(width: context.wp(3).clamp(8.0, 14.0)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MediSaathi',
              style: TextStyle(
                fontSize: context.sp(18),
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
                fontFamily: 'Lato',
              ),
            ),
            Text(
              'Your AI Health Companion',
              style: TextStyle(
                fontSize: context.sp(12),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
