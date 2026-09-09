import 'package:get/get.dart';
import '../controllers/image_analysis_controller.dart';

class ImageAnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageAnalysisController>(() => ImageAnalysisController());
  }
}
