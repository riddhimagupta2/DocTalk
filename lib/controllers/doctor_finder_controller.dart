import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/doctor_model.dart';
import '../services/doctor_finder_service.dart';

class DoctorFinderController extends GetxController {
  final String specialist;
  final DoctorFinderService _service = DoctorFinderService();

  DoctorFinderController({required this.specialist});

  final RxList<DoctorModel> doctors = <DoctorModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Position?> userLocation = Rx<Position?>(null);
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxBool showMap = true.obs;
  final Rx<DoctorModel?> selectedDoctor = Rx<DoctorModel?>(null);

  GoogleMapController? mapController;

  @override
  void onInit() {
    super.onInit();
    searchDoctors();
  }

  Future<void> searchDoctors() async {
    isLoading.value = true;
    errorMessage.value = '';
    doctors.clear();
    markers.clear();

    try {
      final position = await _service.getCurrentLocation();

      if (position == null) {
        errorMessage.value =
            'Could not get your location.\nPlease enable location services.';
        return;
      }

      userLocation.value = position;
      await _searchWithCoordinates(position.latitude, position.longitude);
    } catch (e) {
      errorMessage.value = 'Error finding doctors: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchDoctorsByLocation(String location) async {
    if (location.trim().isEmpty) return;
    isLoading.value = true;
    errorMessage.value = '';
    doctors.clear();
    markers.clear();

    try {
      final locations = await locationFromAddress(location);

      if (locations.isEmpty) {
        errorMessage.value = 'Location not found. Try a different area.';
        return;
      }

      final loc = locations.first;
      await _searchWithCoordinates(loc.latitude, loc.longitude);
    } catch (e) {
      errorMessage.value = 'Failed to search location: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _searchWithCoordinates(double lat, double lng) async {
    final foundDoctors = await _service.findNearbyDoctors(
      latitude: lat,
      longitude: lng,
      specialist: specialist,
      radius: 5000,
    );

    if (foundDoctors.isEmpty) {
      errorMessage.value =
          'No doctors found nearby.\nTry searching another location.';
    } else {
      doctors.value = foundDoctors;
      _createMarkers();
    }
  }

  void _createMarkers() {
    final Set<Marker> newMarkers = {};
    for (final doctor in doctors) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(doctor.placeId),
          position: LatLng(doctor.latitude, doctor.longitude),
          infoWindow: InfoWindow(
            title: doctor.name,
            snippet: '${doctor.specialization} • ⭐ ${doctor.rating}',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () {
            selectedDoctor.value = doctor;
          },
        ),
      );
    }
    markers.value = newMarkers;
  }

  void selectDoctor(DoctorModel doctor) {
    selectedDoctor.value = doctor;
    Get.toNamed('/doctor-details', arguments: {'doctor': doctor});
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
      Get.snackbar('Error', 'Could not open Google Maps');
    }
  }

  void toggleView() => showMap.value = !showMap.value;

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }
}
