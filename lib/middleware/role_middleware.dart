import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../resources/app_routes.dart';

class DoctorMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) return null;
    final authCtrl = Get.find<AuthController>();
    final user = authCtrl.userModel.value;
    final role = user?.role ?? 'patient';
    if (role == 'patient') {
      Get.snackbar(
        'Access Denied 🔒',
        'Doctor portal is restricted to verified healthcare professionals.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return const RouteSettings(name: AppRoutes.home);
    }
    return null;
  }
}

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) return null;
    final authCtrl = Get.find<AuthController>();
    final role = authCtrl.userModel.value?.role ?? 'patient';
    if (role != 'admin') {
      Get.snackbar(
        'Access Denied 🛡️',
        'Admin dashboard is restricted to system administrators.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return const RouteSettings(name: AppRoutes.home);
    }
    return null;
  }
}
