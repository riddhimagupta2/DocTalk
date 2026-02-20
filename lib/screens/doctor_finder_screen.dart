import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/doctor_finder_controller.dart';
import '../resources/AppTheme.dart';

class DoctorFinderScreen extends StatelessWidget {
  const DoctorFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final specialist = args?['specialist'] ?? 'General Physician';

    final controller =
    Get.put(DoctorFinderController(specialist: specialist));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Find $specialist'),
        backgroundColor: AppColors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _ErrorView(controller);
        }

        if (controller.doctors.isEmpty) {
          return _EmptyView(controller);
        }

        return Column(
          children: [
            SizedBox(
              height: 280,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    controller.userLocation.value?.latitude ?? 0,
                    controller.userLocation.value?.longitude ?? 0,
                  ),
                  zoom: 14,
                ),
                markers: controller.markers,
                myLocationEnabled: true,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.doctors.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(controller.doctors[i].name),
                  subtitle: Text(controller.doctors[i].address),
                  onTap: () =>
                      controller.openInGoogleMaps(controller.doctors[i]),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _ErrorView(DoctorFinderController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(controller.errorMessage.value),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.searchDoctors,
            child: const Text("Retry"),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _showLocationDialog(controller),
            child: const Text("Change Location"),
          ),
        ],
      ),
    );
  }

  Widget _EmptyView(DoctorFinderController controller) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _showLocationDialog(controller),
        child: const Text("Search another location"),
      ),
    );
  }

  void _showLocationDialog(DoctorFinderController controller) {
    final TextEditingController locationController = TextEditingController();

    Get.defaultDialog(
      title: "Enter Location",
      content: Column(
        children: [
          TextField(
            controller: locationController,
            decoration: const InputDecoration(
              hintText: "City or area",
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              controller.searchDoctorsByLocation(locationController.text);
              Get.back();
            },
            child: const Text("Search"),
          )
        ],
      ),
    );
  }
}
