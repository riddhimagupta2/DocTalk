import 'package:get/get.dart';

import '../controllers/auth_controller.dart';


class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Auth controller - permanent, lives throughout app life
    Get.put<AuthController>(AuthController(), permanent: true);

    // Nav controller - permanent for bottom nav state
    Get.put<NavController>(NavController(), permanent: true);
  }
}

class ChatBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatController>(ChatController());
  }
}