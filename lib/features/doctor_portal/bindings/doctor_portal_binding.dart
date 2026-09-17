import 'package:get/get.dart';
import '../controllers/doctor_portal_controller.dart';
import '../controllers/doctor_appointment_controller.dart';

class DoctorPortalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorPortalController>(() => DoctorPortalController(), fenix: true);
    Get.lazyPut<DoctorAppointmentController>(() => DoctorAppointmentController(), fenix: true);
  }
}
