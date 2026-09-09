import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../resources/AppTheme.dart';
import '../../resources/responsive.dart';
import '../../widgets/CustomWidgets/custom_button.dart';
import '../../widgets/CustomWidgets/custom_textfields.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authController = Get.find<AuthController>();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      _authController.signUp(
        name: _nameController.text,
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
                  SizedBox(height: context.hp(2.5)),

                  // Back button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: context.r(42),
                      height: context.r(42),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(context.r(12)),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: context.r(18),
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  SizedBox(height: context.hp(2.8)),

                  // Title
                  Text(
                    'Join\nMediSaathi 🌿',
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
                    'Create your account and take charge of your health',
                    style: TextStyle(
                      fontSize: context.sp(15),
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),

                  SizedBox(height: context.hp(3.2)),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Full Name
                        CustomTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Rahul Sharma',
                          prefixIcon: Icons.person_outline,
                          textCapitalization: TextCapitalization.words,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppStrings.nameRequired;
                            }
                            if (val.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: context.hp(1.6)),

                        // Email
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
                        SizedBox(height: context.hp(1.6)),

                        // Password
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
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return AppStrings.passwordRequired;
                            }
                            if (val.length < 6) {
                              return AppStrings.passwordShort;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: context.hp(1.6)),

                        // Confirm Password
                        CustomTextField(
                          controller: _confirmController,
                          label: 'Confirm Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: context.r(20),
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                          onFieldSubmitted: (_) => _handleSignup(),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (val != _passwordController.text) {
                              return AppStrings.passwordMismatch;
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: context.hp(2.8)),

                        // Sign Up Button
                        Obx(
                          () => CustomButton(
                            label: 'Create Account',
                            isLoading: _authController.isLoading.value,
                            onPressed: _handleSignup,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.hp(2.4)),

                  // Terms
                  Center(
                    child: Text(
                      'By creating an account, you agree to our\nTerms of Service and Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.sp(12),
                        color: AppColors.textSecondary.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: context.hp(2)),

                  // Login redirect
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: context.sp(15),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Text(
                            'Login',
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
}
