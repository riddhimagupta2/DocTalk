import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';
import '../controllers/nav_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Auth controller
    Get.put<AuthController>(AuthController(), permanent: true);

    // Nav controller
    Get.put<NavController>(NavController(), permanent: true);
  }
}

class ChatBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatController>(ChatController());
  }
}
