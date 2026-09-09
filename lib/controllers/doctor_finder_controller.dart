import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/doctor_model.dart';
import '../resources/AppRoutes.dart';
import '../services/doctor_finder_service.dart';

class DoctorFinderController extends GetxController {
  final String specialist;
  final DoctorFinderService _service = DoctorFinderService();

  DoctorFinderController({required this.specialist});

  final RxList<DoctorModel> doctors = <DoctorModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxDouble userLat = 26.8467.obs; // Default: Lucknow
  final RxDouble userLng = 80.9462.obs;
  final RxInt selectedIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    searchDoctors();
  }

  Future<void> searchDoctors() async {
    isLoading.value = true;
    errorMessage.value = '';
    doctors.clear();
    selectedIndex.value = -1;

    try {
      final position = await _service.getCurrentLocation();
      if (position != null) {
        userLat.value = position.latitude;
        userLng.value = position.longitude;
      } else {
        // Location not available — use default and inform user
        errorMessage.value = '';
      }
      await _searchWithCoordinates(userLat.value, userLng.value);
    } catch (e) {
      errorMessage.value = 'Doctors search mein issue aaya. Please retry.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchDoctorsByLocation(String location) async {
    if (location.trim().isEmpty) return;
    isLoading.value = true;
    errorMessage.value = '';
    doctors.clear();
    selectedIndex.value = -1;

    try {
      final locations = await locationFromAddress(location);
      if (locations.isEmpty) {
        errorMessage.value = 'Location nahi mila. Dusri city try karein.';
        return;
      }
      userLat.value = locations.first.latitude;
      userLng.value = locations.first.longitude;
      await _searchWithCoordinates(userLat.value, userLng.value);
    } catch (e) {
      errorMessage.value = 'Location search failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _searchWithCoordinates(double lat, double lng) async {
    final found = await _service.findNearbyDoctors(
      latitude: lat,
      longitude: lng,
      specialist: specialist,
      radius: 5000,
    );
    if (found.isEmpty) {
      errorMessage.value =
          'No $specialist found nearby.\nTry searching a different location.';
    } else {
      doctors.value = found;
    }
  }

  /// Navigate to doctor details — passes DoctorModel safely
  void selectDoctor(int index) {
    if (index < 0 || index >= doctors.length) return;
    selectedIndex.value = index;
    Get.toNamed(
      AppRoutes.doctorDetails,
      arguments: {'doctor': doctors[index]},
    );
  }

  Future<void> openInGoogleMaps(DoctorModel doctor) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${doctor.latitude},${doctor.longitude}'
      '&query_place_id=${doctor.placeId}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Google Maps open nahi ho paaya',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> openAllInGoogleMaps() async {
    final query = Uri.encodeComponent('$specialist near me');
    final url = Uri.parse(
      'https://www.google.com/maps/search/$query/'
      '@${userLat.value},${userLng.value},15z',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}