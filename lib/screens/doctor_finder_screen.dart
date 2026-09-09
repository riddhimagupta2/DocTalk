import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/doctor_finder_controller.dart';
import '../models/doctor_model.dart';
import '../resources/AppTheme.dart';
import '../resources/responsive.dart';
import 'AppointmentBooking/doctor_map_view.dart';

class DoctorFinderScreen extends StatelessWidget {
  const DoctorFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? args;
    try {
      args = Get.arguments as Map<String, dynamic>?;
    } catch (_) {}
    final specialist = args?['specialist'] ?? 'General Physician';

    if (Get.isRegistered<DoctorFinderController>()) {
      Get.delete<DoctorFinderController>();
    }
    final controller =
    Get.put(DoctorFinderController(specialist: specialist));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, specialist, controller),
      body: Obx(() {
        if (controller.isLoading.value) return _loadingView(context);
        if (controller.errorMessage.value.isNotEmpty) {
          return _errorView(context, controller);
        }
        if (controller.doctors.isEmpty) return _emptyView(context, controller);
        return _mainBody(context, controller);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, String specialist, DoctorFinderController controller) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: context.r(20)),
              onPressed: () => Get.back(),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find ',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.sp(16),
              fontWeight: FontWeight.w800,
              fontFamily: 'Lato',
            ),
          ),
          Obx(() => Text(
            controller.isLoading.value
                ? 'Searching...'
                : '${controller.doctors.length} doctors found',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: context.sp(11.5)),
          )),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded,
              color: AppColors.primary, size: context.r(22)),
          onPressed: () => _locationDialog(context, controller),
        ),
        IconButton(
          icon: Icon(Icons.refresh_rounded,
              color: AppColors.textSecondary, size: context.r(22)),
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
  Widget _mainBody(BuildContext context, DoctorFinderController controller) {
    return Column(
      children: [
        // Custom map
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
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(4).clamp(12.0, 20.0),
            vertical: context.hp(1.2).clamp(8.0, 14.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(() => Text(
                  '${controller.doctors.length} Nearby ${controller.specialist}s',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: context.sp(13.5),
                    fontFamily: 'Lato',
                  ),
                  overflow: TextOverflow.ellipsis,
                )),
              ),
              GestureDetector(
                onTap: controller.openAllInGoogleMaps,
                child: Row(
                  children: [
                    Icon(Icons.map_outlined,
                        color: AppColors.primary, size: context.r(14)),
                    const SizedBox(width: 4),
                    Text(
                      'View on Maps',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: context.sp(12),
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
            padding: EdgeInsets.fromLTRB(
              context.wp(3.5).clamp(10.0, 18.0),
              context.hp(1.2).clamp(8.0, 14.0),
              context.wp(3.5).clamp(10.0, 18.0),
              context.hp(3).clamp(18.0, 30.0),
            ),
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
  Widget _loadingView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 3),
          SizedBox(height: context.hp(2)),
          Text(
            'Aapke paas doctors dhundh rahe hain...',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.sp(14),
                fontFamily: 'Lato'),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────
  Widget _errorView(BuildContext context, DoctorFinderController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.r(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.r(22)),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded,
                  size: context.r(46), color: AppColors.error),
            ),
            SizedBox(height: context.hp(2.5)),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.sp(14),
                  height: 1.6,
                  fontFamily: 'Lato'),
            ),
            SizedBox(height: context.hp(3)),
            SizedBox(
              width: double.infinity,
              height: context.hp(6).clamp(46.0, 54.0),
              child: ElevatedButton.icon(
                onPressed: controller.searchDoctors,
                icon: Icon(Icons.refresh_rounded, size: context.r(18)),
                label: Text('Retry', style: TextStyle(fontSize: context.sp(14), fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(14))),
                ),
              ),
            ),
            SizedBox(height: context.hp(1.5)),
            SizedBox(
              width: double.infinity,
              height: context.hp(6).clamp(46.0, 54.0),
              child: OutlinedButton.icon(
                onPressed: () => _locationDialog(context, controller),
                icon: Icon(Icons.search_rounded, size: context.r(18)),
                label: Text('Location Manually Enter Karein', style: TextStyle(fontSize: context.sp(14), fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(14))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty ─────────────────────────────────────────────────────────────
  Widget _emptyView(BuildContext context, DoctorFinderController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services_outlined,
              size: context.r(60), color: AppColors.textHint),
          SizedBox(height: context.hp(2)),
          Text(
            'Koi doctor nahi mila nearby',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.sp(15),
                fontWeight: FontWeight.w500),
          ),
          SizedBox(height: context.hp(3)),
          ElevatedButton.icon(
            onPressed: () => _locationDialog(context, controller),
            icon: Icon(Icons.search_rounded, size: context.r(18)),
            label: Text('Dusri Location Try Karein', style: TextStyle(fontSize: context.sp(14))),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.r(14))),
            ),
          ),
        ],
      ),
    );
  }

  // ── Location dialog ───────────────────────────────────────────────────
  void _locationDialog(BuildContext context, DoctorFinderController controller) {
    final tc = TextEditingController();
    Get.defaultDialog(
      title: 'Location Search Karein',
      titleStyle: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: context.sp(16),
          fontFamily: 'Lato'),
      radius: context.r(18),
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
      margin: EdgeInsets.only(bottom: context.hp(1.5).clamp(8.0, 14.0)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
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
        borderRadius: BorderRadius.circular(context.r(18)),
        child: InkWell(
          borderRadius: BorderRadius.circular(context.r(18)),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(context.r(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row ────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: context.r(52),
                      height: context.r(52),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColors.primaryLight,
                          AppColors.primary.withOpacity(0.12),
                        ]),
                        borderRadius: BorderRadius.circular(context.r(13)),
                      ),
                      child: Icon(Icons.person_rounded,
                          color: AppColors.primary, size: context.r(26)),
                    ),
                    SizedBox(width: context.wp(2.5).clamp(8.0, 14.0)),

                    // Name / spec / exp
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: context.sp(14.5),
                              fontFamily: 'Lato',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            doctor.specialization,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: context.sp(12.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            doctor.experience,
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: context.sp(11.5)),
                          ),
                        ],
                      ),
                    ),

                    // Availability badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.r(8), vertical: context.hp(0.5)),
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
                              fontSize: context.sp(10.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.hp(1)),

                // ── Address ───────────────────────────────────
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: context.r(12), color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor.address,
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: context.sp(12)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.hp(1)),
                Container(height: 1, color: AppColors.border),
                SizedBox(height: context.hp(1)),

                // ── Stats row ─────────────────────────────────
                Row(
                  children: [
                    _Chip(
                        icon: Icons.star_rounded,
                        label: '${doctor.rating}',
                        color: AppColors.gold),
                    SizedBox(width: context.wp(3).clamp(8.0, 14.0)),
                    _Chip(
                        icon: Icons.near_me_rounded,
                        label: '${doctor.distanceKm} km',
                        color: AppColors.primary),
                    SizedBox(width: context.wp(3).clamp(8.0, 14.0)),
                    _Chip(
                        icon: Icons.currency_rupee,
                        label: '${doctor.consultationFee.toInt()}',
                        color: AppColors.coral),
                    const Spacer(),
                    GestureDetector(
                      onTap: onMaps,
                      child: Container(
                        padding: EdgeInsets.all(context.r(7)),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(context.r(8)),
                        ),
                        child: Icon(Icons.map_outlined,
                            color: AppColors.primary, size: context.r(15)),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.hp(1.5)),

                // ── Book button ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: context.hp(5.5).clamp(42.0, 50.0),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.r(12))),
                    ),
                    child: Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: context.sp(13.5),
                        fontFamily: 'Lato',
                      ),
                    ),
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
        Icon(icon, size: context.r(13), color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                color: color, fontSize: context.sp(12), fontWeight: FontWeight.w600)),
      ],
    );
  }
}
