import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/doctor_finder_controller.dart';
import '../models/doctor_model.dart';
import '../resources/AppTheme.dart';
import 'AppointmentBooking/doctor_map_view.dart';

class DoctorFinderScreen extends StatelessWidget {
  const DoctorFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Safe args parsing
    Map<String, dynamic>? args;
    try {
      args = Get.arguments as Map<String, dynamic>?;
    } catch (_) {}
    final specialist = args?['specialist'] ?? 'General Physician';

    // Always create fresh controller
    if (Get.isRegistered<DoctorFinderController>()) {
      Get.delete<DoctorFinderController>();
    }
    final controller =
    Get.put(DoctorFinderController(specialist: specialist));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(specialist, controller),
      body: Obx(() {
        if (controller.isLoading.value) return _loadingView();
        if (controller.errorMessage.value.isNotEmpty) {
          return _errorView(controller);
        }
        if (controller.doctors.isEmpty) return _emptyView(controller);
        return _mainBody(controller);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(
      String specialist, DoctorFinderController controller) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find $specialist',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Lato',
            ),
          ),
          Obx(() => Text(
            controller.isLoading.value
                ? 'Searching...'
                : '${controller.doctors.length} doctors found',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11.5),
          )),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded,
              color: AppColors.primary, size: 22),
          onPressed: () => _locationDialog(controller),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: AppColors.textSecondary, size: 22),
          onPressed: controller.searchDoctors,
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── Main body ─────────────────────────────────────────────────────────
  Widget _mainBody(DoctorFinderController controller) {
    return Column(
      children: [
        // Custom map — pure Flutter, zero crash
        Obx(() => DoctorMapView(
          doctors: controller.doctors,
          userLat: controller.userLat.value,
          userLng: controller.userLng.value,
          selectedIndex: controller.selectedIndex.value,
          onDoctorTap: (i) {
            if (i >= 0) controller.selectedIndex.value = i;
          },
          onOpenMaps: controller.openAllInGoogleMaps,
        )),

        // List header
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 11, 16, 10),
          child: Row(
            children: [
              Obx(() => Text(
                '${controller.doctors.length} Nearby ${controller.specialist}s',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  fontFamily: 'Lato',
                ),
              )),
              const Spacer(),
              GestureDetector(
                onTap: controller.openAllInGoogleMaps,
                child: const Row(
                  children: [
                    Icon(Icons.map_outlined,
                        color: AppColors.primary, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'View on Maps',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.border),

        // Doctor cards
        Expanded(
          child: Obx(() => ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
            itemCount: controller.doctors.length,
            itemBuilder: (_, i) => _DoctorCard(
              doctor: controller.doctors[i],
              index: i,
              isSelected: controller.selectedIndex.value == i,
              onTap: () => controller.selectDoctor(i),
              onMaps: () =>
                  controller.openInGoogleMaps(controller.doctors[i]),
            ),
          )),
        ),
      ],
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────
  Widget _loadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 3),
          SizedBox(height: 18),
          Text(
            'Aapke paas doctors dhundh rahe hain...',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontFamily: 'Lato'),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────
  Widget _errorView(DoctorFinderController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 46, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.6,
                  fontFamily: 'Lato'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.searchDoctors,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontFamily: 'Lato'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _locationDialog(controller),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Location Manually Enter Karein'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontFamily: 'Lato'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty ─────────────────────────────────────────────────────────────
  Widget _emptyView(DoctorFinderController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.medical_services_outlined,
              size: 60, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text(
            'Koi doctor nahi mila nearby',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _locationDialog(controller),
            icon: const Icon(Icons.search_rounded),
            label: const Text('Dusri Location Try Karein'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Location dialog ───────────────────────────────────────────────────
  void _locationDialog(DoctorFinderController controller) {
    final tc = TextEditingController();
    Get.defaultDialog(
      title: 'Location Search Karein',
      titleStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          fontFamily: 'Lato'),
      radius: 18,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(children: [
          TextField(
            controller: tc,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'City ya area likhein',
              hintStyle: const TextStyle(color: AppColors.textHint),
              prefixIcon:
              const Icon(Icons.location_on, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onSubmitted: (v) {
              controller.searchDoctorsByLocation(v);
              Get.back();
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.searchDoctorsByLocation(tc.text);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontFamily: 'Lato'),
              ),
              child: const Text('Search'),
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Doctor Card Widget
// ══════════════════════════════════════════════════════════════════════════════

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onMaps;

  const _DoctorCard({
    required this.doctor,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.onMaps,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
          isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withOpacity(0.14)
                : Colors.black.withOpacity(0.055),
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row ────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColors.primaryLight,
                          AppColors.primary.withOpacity(0.12),
                        ]),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(width: 11),

                    // Name / spec / exp
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              fontFamily: 'Lato',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            doctor.specialization,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            doctor.experience,
                            style: const TextStyle(
                                color: AppColors.textHint, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),

                    // Availability badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: doctor.isAvailableToday
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 3.5,
                            backgroundColor: doctor.isAvailableToday
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doctor.isAvailableToday
                                ? 'Available'
                                : 'Busy',
                            style: TextStyle(
                              color: doctor.isAvailableToday
                                  ? AppColors.success
                                  : AppColors.error,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 9),

                // ── Address ───────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor.address,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Container(height: 1, color: AppColors.border),
                const SizedBox(height: 10),

                // ── Stats row ─────────────────────────────────
                Row(
                  children: [
                    _Chip(
                        icon: Icons.star_rounded,
                        label: '${doctor.rating}',
                        color: AppColors.gold),
                    const SizedBox(width: 12),
                    _Chip(
                        icon: Icons.near_me_rounded,
                        label: '${doctor.distanceKm} km',
                        color: AppColors.primary),
                    const SizedBox(width: 12),
                    _Chip(
                        icon: Icons.currency_rupee,
                        label: '${doctor.consultationFee.toInt()}',
                        color: AppColors.coral),
                    const Spacer(),
                    // Open in Maps icon
                    GestureDetector(
                      onTap: onMaps,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.map_outlined,
                            color: AppColors.primary, size: 15),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Book button ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? AppColors.primary
                          : AppColors.primaryLight,
                      foregroundColor: isSelected
                          ? Colors.white
                          : AppColors.primaryDark,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          fontFamily: 'Lato'),
                    ),
                    child: const Text('Book Appointment'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}