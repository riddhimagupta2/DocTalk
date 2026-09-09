import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/doctor_model.dart';
import '../../resources/AppRoutes.dart';
import '../../resources/AppTheme.dart';
import '../../resources/responsive.dart';

class DoctorDetailsScreen extends StatelessWidget {
  const DoctorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    DoctorModel? doctor;

    if (args is Map) {
      doctor = args['doctor'] as DoctorModel?;
    }

    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Doctor Details', style: TextStyle(fontSize: context.sp(18))),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: context.r(24)),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: context.r(60), color: AppColors.error),
              SizedBox(height: context.hp(2)),
              Text('Doctor information not found',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(14))),
              SizedBox(height: context.hp(2)),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                child: Text('Go Back', style: TextStyle(fontSize: context.sp(14))),
              ),
            ],
          ),
        ),
      );
    }

    final avatarSize = context.r(82).clamp(64.0, 100.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: context.hp(28).clamp(200.0, 280.0),
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(context.r(8)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: context.r(16)),
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
                      SizedBox(height: context.hp(3.5)),
                      Container(
                        width: avatarSize,
                        height: avatarSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.45), width: 2.5),
                        ),
                        child: Icon(Icons.person_rounded,
                            color: Colors.white, size: context.r(44)),
                      ),
                      SizedBox(height: context.hp(1.2)),
                      Text(
                        doctor.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(20),
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Lato',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialization,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: context.sp(14)),
                      ),
                      SizedBox(height: context.hp(1)),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: context.r(14), vertical: context.hp(0.6)),
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
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: context.sp(12),
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
              padding: EdgeInsets.symmetric(
                horizontal: context.wp(4).clamp(12.0, 20.0),
                vertical: context.hp(1.5).clamp(10.0, 18.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats row ──────────────────────────────────────
                  _StatsRow(doctor: doctor),
                  SizedBox(height: context.hp(2)),

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
                        'Consultation Fee: \₹${doctor.consultationFee.toInt()}'),
                    const _Divider(),
                    _InfoRow(
                        icon: Icons.workspace_premium_outlined,
                        text: 'Experience: ${doctor.experience}'),
                  ]),

                  // ── Available Slots ────────────────────────────────
                  if (doctor.availableSlots.isNotEmpty) ...[
                    SizedBox(height: context.hp(2.5)),
                    const _SectionTitle(
                      icon: Icons.access_time_rounded,
                      title: "Today's Available Slots",
                    ),
                    SizedBox(height: context.hp(1.2)),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: doctor.availableSlots.map((slot) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: context.r(14), vertical: context.hp(1)),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                              fontSize: context.sp(13),
                              fontFamily: 'Lato',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  SizedBox(height: context.hp(3.5)),

                  // ── Book button ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: context.hp(6.5).clamp(48.0, 56.0),
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
                            borderRadius: BorderRadius.circular(context.r(14))),
                      ),
                      child: Text(
                        'Book Appointment',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: context.sp(16),
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.hp(2.5)),
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
      padding: EdgeInsets.symmetric(vertical: context.hp(1.8).clamp(12.0, 20.0)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(context.r(16)),
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
              value: '',
              label: 'Rating',
              color: AppColors.gold),
          _vDivider(),
          _StatItem(
              icon: Icons.reviews_outlined,
              value: '',
              label: 'Reviews',
              color: AppColors.primary),
          _vDivider(),
          _StatItem(
              icon: Icons.near_me_rounded,
              value: 'km',
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
      Icon(icon, color: color, size: context.r(20)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: context.sp(15),
              fontFamily: 'Lato')),
      Text(label,
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: context.sp(11.5))),
    ]);
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.r(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(context.r(16)),
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
      Icon(icon, size: context.r(17), color: AppColors.primary),
      SizedBox(width: context.wp(2.5).clamp(8.0, 14.0)),
      Expanded(
          child: Text(text,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: context.sp(13.5),
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
      Icon(icon, size: context.r(16), color: AppColors.primary),
      const SizedBox(width: 7),
      Text(title,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: context.sp(14.5),
              fontFamily: 'Lato')),
    ]);
  }
}
