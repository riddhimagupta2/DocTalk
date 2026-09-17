import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/doctor_model.dart';
import '../../resources/app_colors.dart';
import '../../resources/app_routes.dart';
import '../../resources/responsive.dart';

class DoctorDetailsScreen extends StatefulWidget {
  const DoctorDetailsScreen({super.key});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  bool _isFavorite = false;

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

    final doc = doctor;
    final avatarSize = context.r(82).clamp(64.0, 100.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ─────────────────────────────────────────
          SliverAppBar(
            expandedHeight: context.hp(28).clamp(200.0, 280.0),
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(context.r(8)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: context.r(16)),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(context.r(8)),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _isFavorite ? Colors.redAccent : Colors.white,
                    size: context.r(18),
                  ),
                ),
                onPressed: () {
                  setState(() => _isFavorite = !_isFavorite);
                  Get.snackbar(
                    _isFavorite ? 'Saved to Favorites' : 'Removed from Favorites',
                    _isFavorite ? '${doc.name} saved to your favorite doctors.' : '',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
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
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45), width: 2.5),
                        ),
                        child: Icon(Icons.person_rounded,
                            color: Colors.white, size: context.r(44)),
                      ),
                      SizedBox(height: context.hp(1.2)),
                      Text(
                        doc.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(20),
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc.specialization,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: context.sp(14),
                            fontFamily: 'Poppins'),
                      ),
                      SizedBox(height: context.hp(1)),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: context.r(14), vertical: context.hp(0.6)),
                        decoration: BoxDecoration(
                          color: doc.isDocTalkVerified
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.blueGrey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: doc.isDocTalkVerified
                                ? Colors.greenAccent
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              doc.isDocTalkVerified ? Icons.verified_rounded : Icons.map_rounded,
                              color: Colors.white,
                              size: context.sp(14),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              doc.isDocTalkVerified
                                  ? 'Verified by DocTalk'
                                  : 'Google Maps Doctor',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.sp(12),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
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
                  // If NOT verified: Show exact requirement banner
                  if (!doc.isDocTalkVerified) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(context.r(14)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(context.r(14)),
                        border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: const Color(0xFFF57F17), size: context.r(24)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Online appointment is available only for DocTalk Verified Doctors.',
                                  style: TextStyle(
                                    color: const Color(0xFF5D4037),
                                    fontSize: context.sp(13.5),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'You can view profile, call clinic directly, message via WhatsApp, or navigate using Google Maps.',
                                  style: TextStyle(
                                    color: const Color(0xFF795548),
                                    fontSize: context.sp(12),
                                    height: 1.35,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.hp(1.8)),
                  ],

                  // Stats row
                  _StatsRow(doctor: doc),
                  SizedBox(height: context.hp(2)),

                  // Primary Info Card
                  _InfoCard(children: [
                    _InfoRow(icon: Icons.location_on_outlined, text: doc.address),
                    const _Divider(),
                    _InfoRow(
                        icon: Icons.phone_outlined,
                        text: doc.phone.isEmpty ? 'Phone not listed on Maps' : doc.phone),
                    if (doc.website.isNotEmpty) ...[
                      const _Divider(),
                      _InfoRow(icon: Icons.language_rounded, text: doc.website),
                    ],
                    const _Divider(),
                    _InfoRow(
                        icon: Icons.access_time_rounded,
                        text: 'Hours: ${doc.openingHours}'),
                    const _Divider(),
                    _InfoRow(
                        icon: Icons.currency_rupee,
                        text: 'Consultation Fee: ₹${doc.consultationFee.toInt()}'),
                  ]),

                  // Verified Doctor Credentials
                  if (doc.isDocTalkVerified && doc.certificates.isNotEmpty) ...[
                    SizedBox(height: context.hp(2.5)),
                    const _SectionTitle(
                      icon: Icons.verified_user_outlined,
                      title: 'Doctor Credentials & Verification',
                    ),
                    SizedBox(height: context.hp(1.0)),
                    ...doc.certificates.map((cert) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: AppColors.success, size: context.r(16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cert,
                                  style: TextStyle(
                                    fontSize: context.sp(12.5),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],

                  // Available Slots (ONLY for DocTalk Verified Partners)
                  if (doc.isDocTalkVerified && doc.availableSlots.isNotEmpty) ...[
                    SizedBox(height: context.hp(2.5)),
                    const _SectionTitle(
                      icon: Icons.access_time_rounded,
                      title: "Today's Available Slots",
                    ),
                    SizedBox(height: context.hp(1.2)),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: doc.availableSlots.map((slot) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: context.r(14), vertical: context.hp(1)),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                              fontSize: context.sp(13),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  SizedBox(height: context.hp(3.0)),

                  // ── Action Buttons for Google Maps Only Clinics ──
                  if (!doc.isDocTalkVerified) ...[
                    Row(
                      children: [
                        // Call Doctor
                        Expanded(
                          child: SizedBox(
                            height: context.hp(5.8).clamp(44.0, 52.0),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final phone = doc.phone.replaceAll(RegExp(r'[^0-9+]'), '');
                                if (phone.isNotEmpty) {
                                  final uri = Uri.parse('tel:$phone');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                } else {
                                  Get.snackbar('Contact', 'Phone number not available for this listing.',
                                      snackPosition: SnackPosition.BOTTOM);
                                }
                              },
                              icon: Icon(Icons.phone_in_talk_rounded, size: context.r(18)),
                              label: Text('Call Doctor',
                                  style: TextStyle(fontSize: context.sp(13), fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // WhatsApp button
                        Expanded(
                          child: SizedBox(
                            height: context.hp(5.8).clamp(44.0, 52.0),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final raw = doc.whatsapp.isNotEmpty ? doc.whatsapp : doc.phone;
                                final phone = raw.replaceAll(RegExp(r'[^0-9]'), '');
                                if (phone.isNotEmpty) {
                                  final uri = Uri.parse('https://wa.me/$phone');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                } else {
                                  Get.snackbar('WhatsApp', 'WhatsApp contact not available for this clinic.',
                                      snackPosition: SnackPosition.BOTTOM);
                                }
                              },
                              icon: Icon(Icons.chat_bubble_outline_rounded, size: context.r(18)),
                              label: Text('WhatsApp',
                                  style: TextStyle(fontSize: context.sp(13), fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.hp(1.2)),

                    // Navigate using Google Maps
                    SizedBox(
                      width: double.infinity,
                      height: context.hp(5.8).clamp(44.0, 52.0),
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=${doc.latitude},${doc.longitude}&query_place_id=${doc.placeId}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: Icon(Icons.directions_rounded, size: context.r(18)),
                        label: Text(
                          'Navigate with Google Maps',
                          style: TextStyle(fontSize: context.sp(13), fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1565C0),
                          side: const BorderSide(color: Color(0xFF1565C0), width: 1.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ] else ...[
                    // ── Action Buttons for DocTalk Verified Doctors ──
                    SizedBox(
                      width: double.infinity,
                      height: context.hp(6.2).clamp(48.0, 56.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(
                            AppRoutes.booking,
                            arguments: {'doctor': doc},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.r(14))),
                        ),
                        child: Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: context.sp(15),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
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

// Sub-widgets
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
              icon: Icons.star_rounded,
              value: doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : '4.5',
              label: 'Rating',
              color: AppColors.gold),
          _vDivider(),
          _StatItem(
              icon: Icons.reviews_outlined,
              value: doctor.reviewCount > 0 ? '${doctor.reviewCount}' : '25+',
              label: 'Reviews',
              color: AppColors.primary),
          _vDivider(),
          _StatItem(
              icon: Icons.near_me_rounded,
              value: doctor.distanceKm > 0 ? '${doctor.distanceKm.toStringAsFixed(1)} km' : 'Nearby',
              label: 'Away',
              color: AppColors.coral),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 40, color: AppColors.border);
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatItem(
      {required this.icon, required this.value, required this.label, required this.color});

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
              fontFamily: 'Poppins')),
      Text(label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(11.5), fontFamily: 'Poppins')),
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
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
                  fontFamily: 'Poppins'))),
    ]);
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Padding(
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
              fontFamily: 'Poppins')),
    ]);
  }
}
