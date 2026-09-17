import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/doctor_model.dart';
import '../repositories/doctor_repository.dart';
import '../resources/app_routes.dart';
import '../services/doctor_finder_service.dart';

class DoctorFinderController extends GetxController {
  final String initialSpecialist;
  final DoctorFinderService _service = DoctorFinderService();
  final DoctorRepository _doctorRepo = DoctorRepository();

  DoctorFinderController({this.initialSpecialist = 'All'});

  final RxList<DoctorModel> doctors = <DoctorModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Real user location
  final RxnDouble userLat = RxnDouble();
  final RxnDouble userLng = RxnDouble();
  final RxString currentCity = 'Detecting location...'.obs;

  // UI state: Map view toggle
  final RxBool showMap = false.obs;

  // Permission & GPS states
  final RxBool locationPermissionDenied = false.obs;
  final RxBool isGpsDisabled = false.obs;

  // Search & Filters
  final RxString selectedSpecialist = 'All'.obs;
  final RxDouble searchRadiusKm = 15.0.obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedIndex = (-1).obs;

  static const List<String> availableSpecializations = [
    'All',
    'General Physician',
    'Dermatologist',
    'Cardiologist',
    'Pediatrician',
    'Gynecologist',
    'Orthopedic',
    'ENT Specialist',
    'Dentist',
    'Ophthalmologist',
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['specialist'] != null) {
      final spec = args['specialist'].toString();
      if (spec.isNotEmpty) {
        selectedSpecialist.value = spec;
      }
    } else if (initialSpecialist.isNotEmpty && initialSpecialist != 'General Physician') {
      selectedSpecialist.value = initialSpecialist;
    } else {
      selectedSpecialist.value = 'All';
    }
    detectLocationAndSearch();
  }

  void toggleMap() {
    showMap.value = !showMap.value;
  }

  /// Automatically detect user location and search nearby doctors
  Future<void> detectLocationAndSearch({bool forceRefresh = false}) async {
    if (isLoading.value && !forceRefresh && doctors.isNotEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';
    selectedIndex.value = -1;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isGpsDisabled.value = true;
        currentCity.value = 'GPS Disabled';
        if (userLat.value == null) {
          errorMessage.value = 'Enable location or select your city to find nearby doctors.';
          isLoading.value = false;
          return;
        }
      } else {
        isGpsDisabled.value = false;
      }

      final position = await _service.getCurrentLocation();
      if (position != null) {
        locationPermissionDenied.value = false;
        userLat.value = position.latitude;
        userLng.value = position.longitude;

        _service.getCityFromCoordinates(position.latitude, position.longitude).then((city) {
          if (city.isNotEmpty) {
            currentCity.value = city;
          } else if (currentCity.value == 'Detecting location...') {
            currentCity.value = 'Near Your Location';
          }
        });

        await _searchWithCoordinates(userLat.value!, userLng.value!);
      } else {
        final perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
          locationPermissionDenied.value = true;
          currentCity.value = 'Location Permission Denied';
        }

        if (userLat.value != null && userLng.value != null) {
          await _searchWithCoordinates(userLat.value!, userLng.value!);
        } else {
          errorMessage.value = 'Enable location or select your city to find nearby doctors.';
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to locate doctors. Please retry or enter your location manually.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Search doctors by manually typed city or address
  Future<void> searchDoctorsByLocation(String location) async {
    final query = location.trim();
    if (query.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';
    selectedIndex.value = -1;

    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) {
        errorMessage.value = 'Location "$query" not found. Please try another city.';
        return;
      }

      final resolved = locations.first;
      userLat.value = resolved.latitude;
      userLng.value = resolved.longitude;
      locationPermissionDenied.value = false;
      isGpsDisabled.value = false;
      currentCity.value = query;

      _service.getCityFromCoordinates(resolved.latitude, resolved.longitude).then((city) {
        if (city.isNotEmpty) currentCity.value = city;
      });

      await _searchWithCoordinates(userLat.value!, userLng.value!);
    } catch (e) {
      errorMessage.value = 'Could not find "$query". Please check spelling or try a nearby city.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Perform search at specific latitude/longitude & match with Firestore Verified Doctors
  Future<void> _searchWithCoordinates(double lat, double lng) async {
    final radiusMeters = (searchRadiusKm.value * 1000).toInt();
    final rawDocs = await _service.findNearbyDoctors(
      latitude: lat,
      longitude: lng,
      specialist: selectedSpecialist.value,
      radiusMeters: radiusMeters,
    );

    // Also fetch all registered verified doctors directly from Firestore
    final firestoreVerified = await _doctorRepo.getVerifiedDoctors();

    final List<DoctorModel> matchedList = [];

    for (final rawDoc in rawDocs) {
      // Check if this doctor is registered in Firestore
      final matchedDoc = await _doctorRepo.matchGoogleMapsDoctor(
        phone: rawDoc.phone,
        clinicName: rawDoc.hospitalOrClinicName,
        doctorName: rawDoc.name,
      );

      if (matchedDoc != null) {
        // Matched with registered DocTalk doctor!
        matchedList.add(rawDoc.copyWith(
          placeId: matchedDoc.placeId,
          name: matchedDoc.name,
          specialization: matchedDoc.specialization,
          hospitalOrClinicName: matchedDoc.hospitalOrClinicName,
          consultationFee: matchedDoc.consultationFee,
          isDocTalkVerified: true,
          availableSlots: matchedDoc.availableSlots,
          certificates: matchedDoc.certificates,
        ));
      } else {
        // Non-registered doctor from Google Maps/Overpass
        matchedList.add(rawDoc.copyWith(isDocTalkVerified: false));
      }
    }

    // Prepend any Firestore verified doctors that were not in Maps result
    for (final fDoc in firestoreVerified) {
      if (!matchedList.any((d) => d.placeId == fDoc.placeId)) {
        matchedList.insert(0, fDoc.copyWith(isDocTalkVerified: true));
      }
    }

    if (matchedList.isEmpty) {
      errorMessage.value =
          'No doctors found within ${searchRadiusKm.value.toInt()} km.\nTry increasing the search radius or selecting another city.';
    } else {
      doctors.value = matchedList;
    }
  }

  /// Filter doctors list based on search query, specialization, and distance
  List<DoctorModel> get filteredDoctors {
    return doctors.where((doc) {
      if (doc.distanceKm > (searchRadiusKm.value * 1.5) && doc.distanceKm > 0) {
        return false;
      }

      if (selectedSpecialist.value != 'All') {
        final target = selectedSpecialist.value.toLowerCase();
        final docSpec = doc.specialization.toLowerCase();

        bool specMatch = docSpec.contains(target) || target.contains(docSpec);
        if (!specMatch) {
          if (target.contains('skin') || target.contains('derma')) {
            specMatch = docSpec.contains('skin') || docSpec.contains('derma');
          } else if (target.contains('eye') || target.contains('ophthalm')) {
            specMatch = docSpec.contains('eye') || docSpec.contains('ophthalm');
          } else if (target.contains('child') || target.contains('pedia')) {
            specMatch = docSpec.contains('child') || docSpec.contains('pedia');
          } else if (target.contains('heart') || target.contains('cardio')) {
            specMatch = docSpec.contains('heart') || docSpec.contains('cardio');
          } else if (target.contains('bone') || target.contains('ortho')) {
            specMatch = docSpec.contains('bone') || docSpec.contains('ortho');
          } else if (target.contains('dent')) {
            specMatch = docSpec.contains('dent');
          }
        }
        if (!specMatch) return false;
      }

      final q = searchQuery.value.trim().toLowerCase();
      if (q.isNotEmpty) {
        final matchesName = doc.name.toLowerCase().contains(q);
        final matchesHospital = doc.hospitalOrClinicName.toLowerCase().contains(q);
        final matchesSpec = doc.specialization.toLowerCase().contains(q);
        final matchesAddress = doc.address.toLowerCase().contains(q);
        final matchesCity = doc.city.toLowerCase().contains(q);

        if (!matchesName && !matchesHospital && !matchesSpec && !matchesAddress && !matchesCity) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void setSpecialist(String spec) {
    if (selectedSpecialist.value == spec) return;
    selectedSpecialist.value = spec;
    selectedIndex.value = -1;
  }

  void setRadius(double radiusKm) {
    searchRadiusKm.value = radiusKm;
    if (userLat.value != null && userLng.value != null) {
      _searchWithCoordinates(userLat.value!, userLng.value!);
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void selectDoctor(int index) {
    final list = filteredDoctors;
    if (index < 0 || index >= list.length) return;
    selectedIndex.value = index;
    Get.toNamed(
      AppRoutes.doctorDetails,
      arguments: {'doctor': list[index]},
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
      Get.snackbar('Maps', 'Could not open Google Maps', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> openAllInGoogleMaps() async {
    final lat = userLat.value ?? 28.6139;
    final lng = userLng.value ?? 77.2090;
    final spec = selectedSpecialist.value == 'All' ? 'doctors hospitals' : selectedSpecialist.value;
    final query = Uri.encodeComponent('$spec near me');
    final url = Uri.parse(
      'https://www.google.com/maps/search/$query/@$lat,$lng,14z',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

