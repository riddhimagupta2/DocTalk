import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/doctor_finder_controller.dart';
import '../models/doctor_model.dart';
import '../../../resources/app_theme.dart';
import '../resources/responsive.dart';
import 'AppointmentBooking/doctor_map_view.dart';

class DoctorFinderScreen extends StatelessWidget {
  const DoctorFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DoctorFinderController controller = Get.isRegistered<DoctorFinderController>()
        ? Get.find<DoctorFinderController>()
        : Get.put(DoctorFinderController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, controller),
      body: Column(
        children: [
          // Sleek Search Bar & Location Bar combined
          _buildSearchAndLocationHeader(context, controller),

          // Horizontal Specialization Pills
          _buildSpecializationChips(context, controller),

          // Main View (List with optional expandable Map)
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _loadingView(context);
              }
              if (controller.errorMessage.value.isNotEmpty && controller.doctors.isEmpty) {
                return _errorView(context, controller);
              }
              if (controller.filteredDoctors.isEmpty) {
                return _emptyView(context, controller);
              }
              return _mainBody(context, controller);
            }),
          ),
        ],
      ),
    );
  }

  // ── Sleek Modern AppBar ───────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, DoctorFinderController controller) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: context.r(18)),
              onPressed: () => Get.back(),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Find Doctors & Clinics',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.sp(16),
              fontWeight: FontWeight.w800,
              fontFamily: 'Lato',
            ),
          ),
          Obx(() => Text(
            controller.isLoading.value
                ? 'Searching nearby...'
                : '${controller.filteredDoctors.length} facilities near ${controller.currentCity.value}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.sp(11),
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          )),
        ],
      ),
      actions: [
        // Map / List Toggle button
        Obx(() {
          final isMapOpen = controller.showMap.value;
          return IconButton(
            tooltip: isMapOpen ? 'Show List View' : 'Show Map View',
            icon: Icon(
              isMapOpen ? Icons.view_list_rounded : Icons.map_outlined,
              color: AppColors.primary,
              size: context.r(22),
            ),
            onPressed: controller.toggleMap,
          );
        }),
        IconButton(
          tooltip: 'Refresh Location',
          icon: Icon(Icons.my_location_rounded,
              color: AppColors.textSecondary, size: context.r(20)),
          onPressed: () => controller.detectLocationAndSearch(forceRefresh: true),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border.withValues(alpha:0.5)),
      ),
    );
  }

  // ── Unified Search & Location Bar ─────────────────────────────────────
  Widget _buildSearchAndLocationHeader(BuildContext context, DoctorFinderController controller) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        context.wp(4).clamp(12.0, 18.0),
        context.hp(1.0).clamp(6.0, 10.0),
        context.wp(4).clamp(12.0, 18.0),
        context.hp(0.8).clamp(4.0, 8.0),
      ),
      child: Column(
        children: [
          // Search Input
          Container(
            height: context.hp(5.0).clamp(40.0, 46.0),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(context.r(12)),
              border: Border.all(color: AppColors.border.withValues(alpha:0.7)),
            ),
            child: TextField(
              onChanged: controller.setSearchQuery,
              style: TextStyle(fontSize: context.sp(13), color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search doctor, clinic or specialty (e.g. Skin, ENT)',
                hintStyle: TextStyle(
                    fontSize: context.sp(11.5), color: AppColors.textHint),
                prefixIcon: Icon(Icons.search_rounded,
                    color: AppColors.primary, size: context.r(18)),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: Icon(Icons.close_rounded,
                          size: context.r(16), color: AppColors.textHint),
                      onPressed: () => controller.setSearchQuery(''),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          SizedBox(height: context.hp(0.8)),

          // Location & Radius Chip row
          Row(
            children: [
              // Current city chip
              Expanded(
                child: InkWell(
                  onTap: () => _locationDialog(context, controller),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.primary, size: context.r(14)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Obx(() => Text(
                            controller.currentCity.value,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: context.sp(11.5),
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ),
                        Text(
                          'Change',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: context.sp(11.5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Radius Selector Pill
              InkWell(
                onTap: () => _showRadiusDialog(context, controller),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.radar_rounded,
                          size: context.r(12), color: AppColors.primary),
                      const SizedBox(width: 4),
                      Obx(() => Text(
                        '${controller.searchRadiusKm.value.toInt()} km',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: context.sp(11),
                          fontWeight: FontWeight.w700,
                        ),
                      )),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_drop_down_rounded,
                          size: context.r(14), color: AppColors.primaryDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Specialization Filter Chips ───────────────────────────────────────
  Widget _buildSpecializationChips(BuildContext context, DoctorFinderController controller) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(bottom: context.hp(0.8).clamp(4.0, 8.0)),
      child: SizedBox(
        height: context.hp(3.8).clamp(30.0, 36.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: context.wp(4).clamp(12.0, 18.0)),
          itemCount: DoctorFinderController.availableSpecializations.length,
          itemBuilder: (context, i) {
            final spec = DoctorFinderController.availableSpecializations[i];
            return Obx(() {
              final isSelected = controller.selectedSpecialist.value == spec;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(spec),
                  selected: isSelected,
                  onSelected: (_) => controller.setSpecialist(spec),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: context.sp(11),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha:0.7),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  // ── Main Body (Clean List + Collapsible Map) ──────────────────────────
  Widget _mainBody(BuildContext context, DoctorFinderController controller) {
    return Column(
      children: [
        // Collapsible Map View (Shown only when toggled to save screen space)
        Obx(() {
          if (!controller.showMap.value) {
            return const SizedBox.shrink();
          }
          final lat = controller.userLat.value ?? 30.378;
          final lng = controller.userLng.value ?? 76.776;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 190.0,
            child: Stack(
              children: [
                DoctorMapView(
                  doctors: controller.filteredDoctors,
                  userLat: lat,
                  userLng: lng,
                  selectedIndex: controller.selectedIndex.value,
                  onDoctorTap: (i) {
                    if (i >= 0) controller.selectedIndex.value = i;
                  },
                  onOpenMaps: controller.openAllInGoogleMaps,
                ),
                // Close / Hide Map button
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: controller.toggleMap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded, size: context.r(12), color: AppColors.textPrimary),
                          const SizedBox(width: 3),
                          Text('Hide Map',
                              style: TextStyle(
                                  fontSize: context.sp(10.5),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        // List Header Bar
        Container(
          color: AppColors.background,
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(4).clamp(12.0, 18.0),
            vertical: context.hp(1.0).clamp(6.0, 10.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(() {
                  final count = controller.filteredDoctors.length;
                  final spec = controller.selectedSpecialist.value;
                  final label = spec == 'All' ? 'Nearby Doctors & Clinics' : spec;
                  return Text(
                    '$count $label',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: context.sp(12.5),
                      fontFamily: 'Lato',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ),
              Obx(() {
                if (!controller.showMap.value) {
                  return GestureDetector(
                    onTap: controller.toggleMap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_outlined,
                            color: AppColors.primary, size: context.r(14)),
                        const SizedBox(width: 4),
                        Text(
                          'Show Map',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: context.sp(11.5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),

        // Clean Doctor Card List with Ample Bottom Padding
        Expanded(
          child: Obx(() {
            final docs = controller.filteredDoctors;
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                context.wp(3.5).clamp(10.0, 16.0),
                context.hp(0.6).clamp(4.0, 8.0),
                context.wp(3.5).clamp(10.0, 16.0),
                120.0, // 120px bottom padding ensures cards never get cut off by bottom nav / FAB!
              ),
              itemCount: docs.length,
              itemBuilder: (_, i) => _DoctorCard(
                doctor: docs[i],
                index: i,
                isSelected: controller.selectedIndex.value == i,
                onTap: () => controller.selectDoctor(i),
                onMaps: () => controller.openInGoogleMaps(docs[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Fast Shimmer Loading Skeleton ──────────────────────────────────
  Widget _loadingView(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        context.wp(3.5).clamp(10.0, 16.0),
        context.hp(1.0).clamp(6.0, 10.0),
        context.wp(3.5).clamp(10.0, 16.0),
        100.0,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(context.r(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(context.r(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: context.r(52),
                    height: context.r(52),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9ECEF),
                      borderRadius: BorderRadius.circular(context.r(12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9ECEF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 90,
                          height: 11,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9ECEF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error View ────────────────────────────────────────────────────────
  Widget _errorView(BuildContext context, DoctorFinderController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.r(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.r(18)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha:0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_off_rounded,
                  size: context.r(36), color: AppColors.primary),
            ),
            SizedBox(height: context.hp(1.5)),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.sp(13),
                  height: 1.4,
                  fontFamily: 'Lato'),
            ),
            SizedBox(height: context.hp(2)),
            SizedBox(
              width: double.infinity,
              height: context.hp(5.0).clamp(40.0, 48.0),
              child: ElevatedButton.icon(
                onPressed: () => _locationDialog(context, controller),
                icon: Icon(Icons.search_rounded, size: context.r(16)),
                label: Text('Select City / Location',
                    style: TextStyle(fontSize: context.sp(13), fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(10))),
                ),
              ),
            ),
            SizedBox(height: context.hp(1)),
            SizedBox(
              width: double.infinity,
              height: context.hp(5.0).clamp(40.0, 48.0),
              child: OutlinedButton.icon(
                onPressed: () => controller.detectLocationAndSearch(forceRefresh: true),
                icon: Icon(Icons.my_location_rounded, size: context.r(16)),
                label: Text('Use Current GPS Location',
                    style: TextStyle(fontSize: context.sp(13), fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(10))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Beautiful Healthcare Empty View ───────────────────────────────────
  Widget _emptyView(BuildContext context, DoctorFinderController controller) {
    final spec = controller.selectedSpecialist.value;
    final city = controller.currentCity.value;
    final radius = controller.searchRadiusKm.value.toInt();

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.wp(6).clamp(20.0, 36.0),
          vertical: context.hp(3).clamp(16.0, 32.0),
        ),
        child: Container(
          padding: EdgeInsets.all(context.r(24)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(context.r(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular medical illustration badge
              Container(
                width: context.r(76),
                height: context.r(76),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F7F6), Color(0xFFD0F4F4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.local_hospital_rounded,
                    size: context.r(36),
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              SizedBox(height: context.hp(2.0)),

              Text(
                'No Doctors Found Nearby',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: context.sp(17),
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Lato',
                ),
              ),
              SizedBox(height: context.hp(0.8)),

              Text(
                spec == 'All'
                    ? 'We could not find medical facilities within $radius km of $city.'
                    : 'We could not find $spec facilities within $radius km of $city.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.sp(12.5),
                  height: 1.45,
                ),
              ),
              SizedBox(height: context.hp(2.5)),

              // Proactive Action 1: Expand search distance to 30km
              if (radius < 30)
                SizedBox(
                  width: double.infinity,
                  height: context.hp(5.0).clamp(42.0, 48.0),
                  child: ElevatedButton.icon(
                    onPressed: () => controller.setRadius(30.0),
                    icon: Icon(Icons.radar_rounded, size: context.r(18)),
                    label: Text(
                      'Expand Radius to 30 km',
                      style: TextStyle(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.r(12)),
                      ),
                    ),
                  ),
                ),

              // Proactive Action 2: Reset to All specialties if filtered
              if (spec != 'All') ...[
                SizedBox(height: context.hp(1.0)),
                SizedBox(
                  width: double.infinity,
                  height: context.hp(5.0).clamp(42.0, 48.0),
                  child: ElevatedButton.icon(
                    onPressed: () => controller.setSpecialist('All'),
                    icon: Icon(Icons.category_rounded, size: context.r(18)),
                    label: Text(
                      'Search All Specialties',
                      style: TextStyle(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF089A97),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.r(12)),
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: context.hp(1.0)),

              // Proactive Action 3: Change City / Location
              SizedBox(
                width: double.infinity,
                height: context.hp(5.0).clamp(42.0, 48.0),
                child: OutlinedButton.icon(
                  onPressed: () => _locationDialog(context, controller),
                  icon: Icon(Icons.location_city_rounded, size: context.r(18)),
                  label: Text(
                    'Search Another City',
                    style: TextStyle(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(12)),
                    ),
                  ),
                ),
              ),

              SizedBox(height: context.hp(1.0)),

              // Proactive Action 4: Retry GPS
              TextButton.icon(
                onPressed: () => controller.detectLocationAndSearch(forceRefresh: true),
                icon: Icon(Icons.refresh_rounded, size: context.r(16), color: AppColors.textSecondary),
                label: Text(
                  'Refresh GPS Location',
                  style: TextStyle(
                    fontSize: context.sp(12),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Location Search Dialog ────────────────────────────────────────────
  void _locationDialog(BuildContext context, DoctorFinderController controller) {
    final tc = TextEditingController();
    Get.defaultDialog(
      title: 'Choose Location',
      titleStyle: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: context.sp(15),
          fontFamily: 'Lato'),
      radius: context.r(16),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            TextField(
              controller: tc,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Ambala, KD Hospital, Mullana',
                hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12.5),
                prefixIcon:
                    const Icon(Icons.location_on, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (v) {
                controller.searchDoctorsByLocation(v);
                Get.back();
              },
            ),
            const SizedBox(height: 10),
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
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                child: const Text('Search',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () {
                Get.back();
                controller.detectLocationAndSearch(forceRefresh: true);
              },
              icon: const Icon(Icons.my_location_rounded, size: 14),
              label: const Text('Use Current GPS Location'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Radius Selection Bottom Sheet ─────────────────────────────────────
  void _showRadiusDialog(BuildContext context, DoctorFinderController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Distance',
              style: TextStyle(
                fontSize: context.sp(15),
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: 'Lato',
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [5.0, 10.0, 15.0, 25.0, 50.0].map((r) {
                return Obx(() {
                  final isSelected = controller.searchRadiusKm.value == r;
                  return ChoiceChip(
                    label: Text('${r.toInt()} km'),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    onSelected: (_) {
                      controller.setRadius(r);
                      Get.back();
                    },
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                });
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Decluttered Modern Doctor Card (Zero Overflow) ──────────────────────
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
    return Container(
      margin: EdgeInsets.only(bottom: context.hp(1.2).clamp(8.0, 12.0)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha:0.6),
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withValues(alpha:0.12)
                : Colors.black.withValues(alpha:0.035),
            blurRadius: isSelected ? 10 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(context.r(14)),
        child: InkWell(
          borderRadius: BorderRadius.circular(context.r(14)),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(context.r(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Name & Specialization + Availability
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile/Hospital Icon
                    Builder(builder: (context) {
                      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
                      final photoUrl = doctor.getPhotoUrl(apiKey);
                      return Container(
                        width: context.r(44),
                        height: context.r(44),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(context.r(10)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: photoUrl != null
                            ? CachedNetworkImage(
                                imageUrl: photoUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Icon(
                                    Icons.local_hospital_rounded,
                                    color: AppColors.primary,
                                    size: context.r(20)),
                                errorWidget: (_, __, ___) => Icon(
                                    Icons.local_hospital_rounded,
                                    color: AppColors.primary,
                                    size: context.r(20)),
                              )
                            : Icon(
                                doctor.specialization.contains('Dentist')
                                    ? Icons.medical_information_rounded
                                    : (doctor.specialization.contains('Eye') || doctor.specialization.contains('Ophthalm'))
                                        ? Icons.remove_red_eye_rounded
                                        : Icons.local_hospital_rounded,
                                color: AppColors.primary,
                                size: context.r(22),
                              ),
                      );
                    }),
                    SizedBox(width: context.wp(2.5).clamp(8.0, 12.0)),

                    // Name, Specialty, Clinic
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: context.sp(13.5),
                              fontFamily: 'Lato',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          // Specialization & Partner Badges Wrap
                          Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  doctor.specialization,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: context.sp(10.5),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: doctor.isDocTalkVerified
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: doctor.isDocTalkVerified
                                        ? const Color(0xFF81C784)
                                        : const Color(0xFF90CAF9),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      doctor.isDocTalkVerified
                                          ? Icons.verified_rounded
                                          : Icons.map_rounded,
                                      size: context.r(10),
                                      color: doctor.isDocTalkVerified
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFF1565C0),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      doctor.isDocTalkVerified
                                          ? 'DocTalk Partner'
                                          : 'Google Maps Listing',
                                      style: TextStyle(
                                        color: doctor.isDocTalkVerified
                                            ? const Color(0xFF2E7D32)
                                            : const Color(0xFF1565C0),
                                        fontSize: context.sp(9.5),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (doctor.hospitalOrClinicName.isNotEmpty &&
                              doctor.hospitalOrClinicName != doctor.name) ...[
                            const SizedBox(height: 2),
                            Text(
                              doctor.hospitalOrClinicName,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: context.sp(11),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Availability badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: doctor.isAvailableToday
                            ? AppColors.success.withValues(alpha:0.1)
                            : AppColors.error.withValues(alpha:0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 2.5,
                            backgroundColor: doctor.isAvailableToday
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            doctor.isAvailableToday ? 'Available' : 'Busy',
                            style: TextStyle(
                              color: doctor.isAvailableToday
                                  ? AppColors.success
                                  : AppColors.error,
                              fontSize: context.sp(9.5),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.hp(0.8)),

                // Address row
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: context.r(12), color: AppColors.textHint),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        doctor.address,
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: context.sp(11)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.hp(0.8)),
                Container(height: 1, color: AppColors.border.withValues(alpha:0.4)),
                SizedBox(height: context.hp(0.8)),

                // Badges Wrap (Never overflows horizontally!)
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _InfoBadge(
                      icon: Icons.star_rounded,
                      label: '${doctor.rating}',
                      color: AppColors.gold,
                    ),
                    _InfoBadge(
                      icon: Icons.near_me_rounded,
                      label: doctor.distanceFormatted,
                      color: AppColors.primary,
                    ),
                    if (doctor.consultationFee > 0)
                      _InfoBadge(
                        icon: Icons.currency_rupee,
                        label: '₹${doctor.consultationFee.toInt()}',
                        color: AppColors.coral,
                      ),
                  ],
                ),

                SizedBox(height: context.hp(1.0)),

                // Action Row: Book Appointment / View Details + Directions button
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: context.hp(4.6).clamp(38.0, 44.0),
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? AppColors.primary
                                : (doctor.isDocTalkVerified ? AppColors.primaryLight : const Color(0xFFE8EEF5)),
                            foregroundColor: isSelected
                                ? Colors.white
                                : (doctor.isDocTalkVerified ? AppColors.primaryDark : const Color(0xFF1E3A8A)),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(context.r(8))),
                          ),
                          child: Text(
                            doctor.isDocTalkVerified ? 'Book Appointment' : 'View Clinic & Call',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: context.sp(12.5),
                              fontFamily: 'Lato',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Maps Direction button
                    InkWell(
                      onTap: onMaps,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: context.hp(4.6).clamp(38.0, 44.0),
                        width: context.hp(4.6).clamp(38.0, 44.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(context.r(8)),
                        ),
                        child: Center(
                          child: Icon(Icons.directions_rounded,
                              color: AppColors.primary, size: context.r(18)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: context.r(12), color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: context.sp(11),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
