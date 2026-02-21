import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/doctor_finder_controller.dart';
import '../models/doctor_model.dart';
import '../resources/AppTheme.dart';

class DoctorFinderScreen extends StatelessWidget {
  const DoctorFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final specialist = args?['specialist'] ?? 'General Physician';
    final controller = Get.put(DoctorFinderController(specialist: specialist));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find $specialist',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'Nearby doctors',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.showMap.value ? Icons.list : Icons.map,
              color: AppColors.primary,
            ),
            onPressed: controller.toggleView,
          )),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: () => _showLocationDialog(controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('Finding nearby doctors...', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorView(controller);
        }

        if (controller.doctors.isEmpty) {
          return _buildEmptyView(controller);
        }

        if (controller.showMap.value) {
          return _buildMapView(controller);
        } else {
          return _buildListView(controller);
        }
      }),
    );
  }

  Widget _buildMapView(DoctorFinderController controller) {
    return Column(
      children: [
        SizedBox(
          height: 260,
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
            myLocationButtonEnabled: true,
            onMapCreated: (c) => controller.mapController = c,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                '${controller.doctors.length} doctors found',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildDoctorList(controller)),
      ],
    );
  }

  Widget _buildListView(DoctorFinderController controller) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: AppColors.white,
          child: Text(
            '${controller.doctors.length} doctors found nearby',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(child: _buildDoctorList(controller)),
      ],
    );
  }

  Widget _buildDoctorList(DoctorFinderController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: controller.doctors.length,
      itemBuilder: (_, i) => _DoctorCard(
        doctor: controller.doctors[i],
        onTap: () => controller.selectDoctor(controller.doctors[i]),
        onMap: () => controller.openInGoogleMaps(controller.doctors[i]),
      ),
    );
  }

  Widget _buildErrorView(DoctorFinderController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.searchDoctors,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showLocationDialog(controller),
              icon: const Icon(Icons.search),
              label: const Text('Search Location'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(DoctorFinderController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.medical_services_outlined, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text('No doctors found nearby', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showLocationDialog(controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Search Another Location'),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(DoctorFinderController controller) {
    final textController = TextEditingController();
    Get.defaultDialog(
      title: 'Search Location',
      titleStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      content: Column(
        children: [
          TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'City or area name',
              hintStyle: const TextStyle(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onSubmitted: (v) {
              controller.searchDoctorsByLocation(v);
              Get.back();
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.searchDoctorsByLocation(textController.text);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Search'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;
  final VoidCallback onMap;

  const _DoctorCard({
    required this.doctor,
    required this.onTap,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctor.specialization,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctor.experience,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Availability badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: doctor.isAvailableToday
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      doctor.isAvailableToday ? 'Available' : 'Busy',
                      style: TextStyle(
                        color: doctor.isAvailableToday ? AppColors.success : AppColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Address
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      doctor.address,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Stats row
              Row(
                children: [
                  _StatChip(
                    icon: Icons.star,
                    label: '${doctor.rating} (${doctor.reviewCount})',
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.near_me,
                    label: '${doctor.distanceKm} km',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.currency_rupee,
                    label: '${doctor.consultationFee.toInt()}',
                    color: AppColors.coral,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onMap,
                    child: const Icon(Icons.map_outlined, color: AppColors.primary, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Book button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Book Appointment',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}