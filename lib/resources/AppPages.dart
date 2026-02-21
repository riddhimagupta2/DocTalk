import 'package:get/get.dart';
import 'package:doctalk/resources/AppRoutes.dart';
import 'package:doctalk/screens/Auth/login_screen.dart';
import 'package:doctalk/screens/Auth/signUp_screen.dart';
import 'package:doctalk/screens/Auth/splash_screen.dart';
import 'package:doctalk/screens/HomeScreen.dart';
import 'package:doctalk/screens/chat_screen.dart';
import 'package:doctalk/screens/doctor_finder_screen.dart';

import '../screens/AppointmentBooking/booking_confirmation_screen.dart';
import '../screens/AppointmentBooking/booking_screen.dart';
import '../screens/AppointmentBooking/doctor_detail_screen.dart';

class AppPages {
  static final pages = [
    /// Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),

    /// Login
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    /// Signup
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    /// Home
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    /// Chat
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatScreen(),
      transition: Transition.upToDown,
      transitionDuration: const Duration(milliseconds: 350),
    ),

    /// Doctor Finder
    GetPage(
      name: AppRoutes.doctorFinder,
      page: () => const DoctorFinderScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    /// Doctor Details
    GetPage(
      name: AppRoutes.doctorDetails,
      page: () => const DoctorDetailsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    /// Booking
    GetPage(
      name: AppRoutes.booking,
      page: () => const BookingScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    /// Booking Confirmation
    GetPage(
      name: AppRoutes.bookingConfirmation,
      page: () => const BookingConfirmationScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
