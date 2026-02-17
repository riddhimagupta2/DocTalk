import 'package:doctalk/resources/AppRoutes.dart';
import 'package:doctalk/resources/AppTheme.dart';
import 'package:doctalk/screens/Auth/login_screen.dart';
import 'package:doctalk/screens/Auth/signUp_screen.dart';
import 'package:doctalk/screens/Auth/splash_screen.dart';
import 'package:doctalk/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'screens/chat_screen.dart';
import 'bindings/app_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MediSaathiApp());
}

class MediSaathiApp extends StatelessWidget {
  const MediSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      initialBinding: AppBindings(),
      getPages: [
        GetPage(
          name: AppRoutes.splash,
          page: () => const SplashScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: AppRoutes.signup,
          page: () => const SignupScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: AppRoutes.home,
          page: () => const HomeScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 400),
        ),
        GetPage(
          name: AppRoutes.chat,
          page: () => const ChatScreen(),
          transition: Transition.upToDown,
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ],
    );
  }
}
