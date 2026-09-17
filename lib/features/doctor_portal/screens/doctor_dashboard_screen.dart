import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/appointment_model.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/responsive.dart';
import '../../../resources/app_routes.dart';
import '../controllers/doctor_portal_controller.dart';
import '../controllers/doctor_appointment_controller.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final portalController = Get.find<DoctorPortalController>();
    final appointmentController = Get.put(DoctorAppointmentController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, portalController),
      body: RefreshIndicator(
        onRefresh: () async {
          await portalController.fetchProfile();
          await appointmentController.fetchAppointments();
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(4).clamp(14.0, 24.0),
            vertical: context.hp(1.5).clamp(10.0, 20.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Header Card
              _buildDoctorHeaderCard(context, portalController),

              SizedBox(height: context.hp(2)),

              // Emergency Mode Banner
              _buildEmergencyBanner(context, portalController),

              SizedBox(height: context.hp(2)),

              // Key Clinical Metrics Grid
              _buildMetricsGrid(context, portalController, appointmentController),

              SizedBox(height: context.hp(2.5)),

              // Quick Action Shortcuts
              _buildQuickActions(context),

              SizedBox(height: context.hp(2.5)),

              // Appointments Section Header + Filter Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Appointments & Consultations',
                    style: TextStyle(
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  Obx(() => Text(
                        '${appointmentController.appointments.length} Total',
                        style: TextStyle(
                          fontSize: context.sp(12),
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                ],
              ),

              SizedBox(height: context.hp(1.2)),

              // Filter Chips
              _buildFilterChips(context, appointmentController),

              SizedBox(height: context.hp(1.5)),

              // Appointment List
              _buildAppointmentsList(context, appointmentController),

              SizedBox(height: context.hp(4)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, DoctorPortalController controller) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'Doctor Workspace',
            style: TextStyle(
              fontSize: context.sp(17),
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.schedule_rounded, color: AppColors.navy),
          tooltip: 'Clinic Hours',
          onPressed: () => Get.toNamed(AppRoutes.doctorSchedule),
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.textSecondary),
          tooltip: 'Return to Patient View',
          onPressed: () => Get.offAllNamed(AppRoutes.home),
        ),
      ],
    );
  }

  Widget _buildDoctorHeaderCard(BuildContext context, DoctorPortalController controller) {
    return Obx(() {
      final doc = controller.profile.value;
      if (doc == null) {
        return const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Container(
        padding: EdgeInsets.all(context.r(16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navy, const Color(0xFF1E3A5F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: context.r(28),
              backgroundColor: AppColors.primary,
              child: Text(
                doc.name.isNotEmpty ? doc.name.replaceAll('Dr. ', '').substring(0, 1) : 'D',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: context.wp(3.5)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          doc.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(16),
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: Color(0xFF60A5FA), size: 18),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${doc.specialization} • ${doc.city}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: context.sp(12),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${doc.rating} (${doc.reviewCount})',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.sp(11),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Fee: ₹${doc.consultationFee.toInt()}',
                        style: TextStyle(
                          color: const Color(0xFF34D399),
                          fontSize: context.sp(12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmergencyBanner(BuildContext context, DoctorPortalController controller) {
    return Obx(() {
      final isEmergency = controller.emergencyMode.value;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: context.r(16), vertical: context.r(12)),
        decoration: BoxDecoration(
          color: isEmergency ? const Color(0xFFFEE2E2) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isEmergency ? const Color(0xFFEF4444) : AppColors.border,
            width: isEmergency ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isEmergency ? const Color(0xFFDC2626) : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emergency_rounded,
                color: isEmergency ? Colors.white : AppColors.navy,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEmergency ? 'Urgent SOS Duty Active' : 'Normal Consultation Mode',
                    style: TextStyle(
                      fontSize: context.sp(13.5),
                      fontWeight: FontWeight.bold,
                      color: isEmergency ? const Color(0xFFB91C1C) : AppColors.navy,
                    ),
                  ),
                  Text(
                    isEmergency
                        ? 'Prioritizing critical triage & SOS requests.'
                        : 'Toggle on to accept urgent on-call emergencies.',
                    style: TextStyle(
                      fontSize: context.sp(11),
                      color: isEmergency ? const Color(0xFF991B1B) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isEmergency,
              onChanged: (v) => controller.toggleEmergencyMode(v),
              activeThumbColor: const Color(0xFFEF4444),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    DoctorPortalController portalCtrl,
    DoctorAppointmentController apptCtrl,
  ) {
    return Obx(() {
      final doc = portalCtrl.profile.value;
      final pendingCount = apptCtrl.pendingCount;
      final completedCount = apptCtrl.completedCount;
      final earnings = doc != null ? doc.weeklyEarnings : 18500.0;

      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          _buildMetricTile(
            context,
            title: 'Pending Requests',
            value: '$pendingCount',
            icon: Icons.pending_actions_rounded,
            color: const Color(0xFFF59E0B),
            bg: const Color(0xFFFEF3C7),
          ),
          _buildMetricTile(
            context,
            title: 'Completed Cases',
            value: '$completedCount',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF10B981),
            bg: const Color(0xFFD1FAE5),
          ),
          _buildMetricTile(
            context,
            title: 'Weekly Earnings',
            value: '₹${earnings.toInt()}',
            icon: Icons.currency_rupee_rounded,
            color: const Color(0xFF3B82F6),
            bg: const Color(0xFFDBEAFE),
          ),
          _buildMetricTile(
            context,
            title: 'Patient Trust',
            value: '${doc?.rating ?? 4.9} ★',
            icon: Icons.favorite_rounded,
            color: const Color(0xFFEC4899),
            bg: const Color(0xFFFCE7F3),
          ),
        ],
      );
    });
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: EdgeInsets.all(context.r(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: context.sp(11),
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: context.sp(18),
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionBtn(
            context,
            label: 'Clinic Hours',
            icon: Icons.access_time_filled_rounded,
            color: AppColors.primary,
            onTap: () => Get.toNamed(AppRoutes.doctorSchedule),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionBtn(
            context,
            label: 'New Rx',
            icon: Icons.post_add_rounded,
            color: const Color(0xFF8B5CF6),
            onTap: () => Get.toNamed(AppRoutes.doctorPrescription),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.hp(1.2).clamp(8.0, 14.0)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: context.sp(13),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, DoctorAppointmentController controller) {
    final filters = [
      {'label': 'All', 'key': 'all'},
      {'label': 'Pending', 'key': 'pending'},
      {'label': 'Confirmed', 'key': 'confirmed'},
      {'label': 'Completed', 'key': 'completed'},
    ];

    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((f) {
              final isSelected = controller.selectedFilter.value == f['key'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f['label']!),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.navy,
                    fontWeight: FontWeight.w600,
                    fontSize: context.sp(12),
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (_) => controller.selectedFilter.value = f['key']!,
                ),
              );
            }).toList(),
          ),
        ));
  }

  Widget _buildAppointmentsList(BuildContext context, DoctorAppointmentController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final list = controller.filteredAppointments;
      if (list.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No appointments in this category',
                style: TextStyle(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final apt = list[index];
          return _buildAppointmentCard(context, apt, controller);
        },
      );
    });
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    AppointmentModel apt,
    DoctorAppointmentController controller,
  ) {
    Color statusColor;
    Color statusBg;
    final statusStr = apt.status.value.toLowerCase();
    if (statusStr == 'accepted' || statusStr == 'confirmed') {
      statusColor = const Color(0xFF10B981);
      statusBg = const Color(0xFFD1FAE5);
    } else if (statusStr == 'completed') {
      statusColor = const Color(0xFF6B7280);
      statusBg = const Color(0xFFF3F4F6);
    } else if (statusStr == 'rejected' || statusStr == 'cancelled') {
      statusColor = const Color(0xFFEF4444);
      statusBg = const Color(0xFFFEE2E2);
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusBg = const Color(0xFFFEF3C7);
    }

    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.doctorPatientDetail, arguments: apt),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(context.r(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    apt.patientName.isNotEmpty ? apt.patientName[0] : 'P',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apt.patientName,
                        style: TextStyle(
                          fontSize: context.sp(14.5),
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        apt.patientPhone.isNotEmpty ? apt.patientPhone : 'Patient',
                        style: TextStyle(
                          fontSize: context.sp(12),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    apt.status.value.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: context.sp(10.5),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Symptoms: ${apt.symptoms.isNotEmpty ? apt.symptoms : "General Consultation"}',
                      style: TextStyle(
                        fontSize: context.sp(11.5),
                        color: AppColors.navy,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${apt.date} • ${apt.time}',
                      style: TextStyle(
                        fontSize: context.sp(12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (apt.status == AppointmentStatus.pending) ...[
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _showRejectDialog(context, apt, controller),
                        child: Text(
                          'Decline',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => controller.acceptAppointment(apt.appointmentId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(70, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Accept',
                          style: TextStyle(fontSize: context.sp(12), color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ] else if (apt.status == AppointmentStatus.accepted) ...[
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.doctorPrescription, arguments: apt),
                    icon: const Icon(Icons.note_alt_outlined, size: 14),
                    label: const Text('Consult & Rx'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    AppointmentModel apt,
    DoctorAppointmentController controller,
  ) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Decline Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to decline consultation for ${apt.patientName}?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason (e.g. In Surgery, Unavailable)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.rejectAppointment(
                apt.appointmentId,
                reasonController.text.trim().isEmpty ? 'Doctor unavailable' : reasonController.text.trim(),
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Decline', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

