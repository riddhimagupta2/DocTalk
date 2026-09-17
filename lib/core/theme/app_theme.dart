import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF0ABFBC);
  static const primaryDark = Color(0xFF089A97);
  static const primaryLight = Color(0xFFD0F4F4);
  static const coral = Color(0xFFF95738);
  static const navy = Color(0xFF0D1B2A);
  static const navyLight = Color(0xFF1A2D3F);
  static const gold = Color(0xFFFFD166);
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF7F3EE);
  static const cardBg = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1209);
  static const textSecondary = Color(0xFF6B6560);
  static const textHint = Color(0xFFAAAAAA);
  static const border = Color(0xFFE0DDD8);
  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF39C12);
  static const error = Color(0xFFE74C3C);
  static const urgent = Color(0xFFE74C3C);
  static const medium = Color(0xFFF39C12);
  static const low = Color(0xFF2ECC71);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 54),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textHint,
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          fontSize: 15,
        ),
      ),
    );
  }
}

class AppStrings {
  static const appName = 'DocTalk';
  static const tagline = 'Your AI Health Companion';
  static const splashTagline =
      'Doctors give you a diagnosis.\nDocTalk gives you a Saathi.';

  // Auth
  static const login = 'Login';
  static const signup = 'Sign Up';
  static const email = 'Email Address';
  static const password = 'Password';
  static const confirmPassword = 'Confirm Password';
  static const fullName = 'Full Name';
  static const loginTitle = 'Welcome Back!';
  static const loginSubtitle = 'Login to your DocTalk account';
  static const signupTitle = 'Create Account';
  static const signupSubtitle =
      'Join DocTalk and take charge of your health';
  static const dontHaveAccount = "Don't have an account? ";
  static const alreadyHaveAccount = 'Already have an account? ';

  // Errors
  static const emailRequired = 'Please enter your email';
  static const emailInvalid = 'Please enter a valid email';
  static const passwordRequired = 'Please enter your password';
  static const passwordShort = 'Password must be at least 6 characters';
  static const nameRequired = 'Please enter your name';
  static const passwordMismatch = 'Passwords do not match';
}
