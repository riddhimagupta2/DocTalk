import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/doctor_model.dart';
import '../../resources/AppRoutes.dart';
import '../../resources/AppTheme.dart';

class DoctorDetailsScreen extends StatelessWidget {
  const DoctorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Safe argument extraction ───────────────────────────────────────
    final args = Get.arguments;
    DoctorModel? doctor;

    if (args is Map) {
      doctor = args['doctor'] as DoctorModel?;
    }

    // Fallback — should never happen if navigation is correct
    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Doctor Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Doctor information not found',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.45), width: 2.5),
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 44),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Lato',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialization,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: doctor.isAvailableToday
                              ? Colors.green.withOpacity(0.25)
                              : Colors.red.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: doctor.isAvailableToday
                                ? Colors.greenAccent.withOpacity(0.5)
                                : Colors.redAccent.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          doctor.isAvailableToday
                              ? '✓  Available Today'
                              : '✗  Not Available Today',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats row ──────────────────────────────────────
                  _StatsRow(doctor: doctor),
                  const SizedBox(height: 16),

                  // ── Info card ──────────────────────────────────────
                  _InfoCard(children: [
                    _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: doctor.address),
                    const _Divider(),
                    _InfoRow(
                        icon: Icons.phone_outlined,
                        text: doctor.phone.isEmpty
                            ? 'Phone not available'
                            : doctor.phone),
                    const _Divider(),
                    _InfoRow(
                        icon: Icons.currency_rupee,
                        text:
                        'Consultation Fee: ₹${doctor.consultationFee.toInt()}'),
                    const _Divider(),
                    _InfoRow(
                        icon: Icons.workspace_premium_outlined,
                        text: 'Experience: ${doctor.experience}'),
                  ]),

                  // ── Available Slots ────────────────────────────────
                  if (doctor.availableSlots.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const _SectionTitle(
                      icon: Icons.access_time_rounded,
                      title: "Today's Available Slots",
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: doctor.availableSlots.map((slot) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            slot,
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              fontFamily: 'Lato',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ── Book button ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.booking,
                          arguments: {'doctor': doctor},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            fontFamily: 'Lato'),
                      ),
                      child: const Text('Book Appointment'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final DoctorModel doctor;
  const _StatsRow({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
              icon: Icons.star_rounded,
              value: '${doctor.rating}',
              label: 'Rating',
              color: AppColors.gold),
          _vDivider(),
          _StatItem(
              icon: Icons.reviews_outlined,
              value: '${doctor.reviewCount}',
              label: 'Reviews',
              color: AppColors.primary),
          _vDivider(),
          _StatItem(
              icon: Icons.near_me_rounded,
              value: '${doctor.distanceKm}km',
              label: 'Away',
              color: AppColors.coral),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 40, color: AppColors.border);
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatItem(
      {required this.icon,
        required this.value,
        required this.label,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              fontFamily: 'Lato')),
      Text(label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 11.5)),
    ]);
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 17, color: AppColors.primary),
      const SizedBox(width: 10),
      Expanded(
          child: Text(text,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  height: 1.4,
                  fontFamily: 'Lato'))),
    ]);
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1, color: AppColors.border),
      );
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.primary),
      const SizedBox(width: 7),
      Text(title,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              fontFamily: 'Lato')),
    ]);
  }
}