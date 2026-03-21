import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';
import '../../resources/AppTheme.dart';

class DoctorMapView extends StatefulWidget {
  final List<DoctorModel> doctors;
  final double userLat;
  final double userLng;
  final int selectedIndex;
  final ValueChanged<int> onDoctorTap; // -1 = open all in Maps
  final VoidCallback onOpenMaps;

  const DoctorMapView({
    super.key,
    required this.doctors,
    required this.userLat,
    required this.userLng,
    required this.selectedIndex,
    required this.onDoctorTap,
    required this.onOpenMaps,
  });

  @override
  State<DoctorMapView> createState() => _DoctorMapViewState();
}

class _DoctorMapViewState extends State<DoctorMapView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _ring = Tween<double>(begin: 0.7, end: 1.3)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const h = 240.0;

    return Container(
      height: h,
      width: w,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5F4), Color(0xFFDCEFF8), Color(0xFFE8F5F4)],
        ),
      ),
      child: Stack(
        children: [

          CustomPaint(
            size: Size(w, h),
            painter: _CityGridPainter(),
          ),


          ..._buildPins(w, h),


          _buildUserDot(w, h),

          Positioned(
            bottom: 10,
            right: 12,
            child: _MapsPill(onTap: widget.onOpenMaps),
          ),


          Positioned(
            top: 10,
            left: 12,
            child: _LocationLabel(),
          ),
        ],
      ),
    );
  }

   Widget _buildUserDot(double w, double h) {
    return Positioned(
      left: w * 0.5 - 14,
      top: h * 0.5 - 14,
      child: AnimatedBuilder(
        animation: _ring,
        builder: (_, __) => SizedBox(
          width: 28,
          height: 28,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 28 * _ring.value,
                height: 28 * _ring.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.18),
                ),
              ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.45),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

   List<Widget> _buildPins(double w, double h) {
    const cx = 0.5;
    const cy = 0.5;
     final angles = [
      -55.0,
      25.0,
      105.0,
      -130.0,
      55.0,
      -20.0,
      155.0,
      -95.0,
      75.0,
      -160.0,
    ];

    return widget.doctors.asMap().entries.map((entry) {
      final i = entry.key;
      final doc = entry.value;
      final rad = angles[i % angles.length] * math.pi / 180;
      final distFactor = (doc.distanceKm / 8.0).clamp(0.2, 0.9);
      final rx = 0.38 * distFactor;
      final ry = 0.32 * distFactor;

      final px = w * (cx + rx * math.cos(rad));
      final py = h * (cy + ry * math.sin(rad));
      final isSelected = widget.selectedIndex == i;

      return Positioned(
        left: px - 28,
        top: py - 36,
        child: GestureDetector(
          onTap: () => widget.onDoctorTap(i),
          child: AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pin bubble
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(isSelected ? 0.18 : 0.08),
                        blurRadius: isSelected ? 12 : 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_hospital_rounded,
                        size: 11,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${doc.distanceKm}km',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Triangle tail
                CustomPaint(
                  size: const Size(10, 6),
                  painter: _PinTail(
                      color: isSelected ? AppColors.primary : Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}


class _CityGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    final block = Paint()
      ..color = const Color(0xFFC8E6C9).withOpacity(0.45)
      ..style = PaintingStyle.fill;


    final rects = [
      Rect.fromLTWH(18, 22, 95, 62),
      Rect.fromLTWH(145, 15, 105, 52),
      Rect.fromLTWH(278, 28, 85, 58),
      Rect.fromLTWH(18, 128, 72, 78),
      Rect.fromLTWH(130, 118, 102, 72),
      Rect.fromLTWH(258, 122, 92, 68),
      Rect.fromLTWH(55, 195, 85, 40),
      Rect.fromLTWH(195, 190, 108, 44),
    ];
    for (final r in rects) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(r, const Radius.circular(5)), block);
    }


    for (final y in [92.0, 182.0]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }

    for (final x in [118.0, 248.0, 358.0]) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }

    final diag = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.height * 0.28),
      Offset(size.width * 0.42, size.height * 0.78),
      diag,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PinTail extends CustomPainter {
  final Color color;
  const _PinTail({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MapsPill extends StatelessWidget {
  final VoidCallback onTap;
  const _MapsPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.open_in_new_rounded,
                size: 13, color: AppColors.primary),
            const SizedBox(width: 5),
            const Text(
              'Open Google Maps',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 6,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.my_location_rounded, size: 13, color: AppColors.primary),
          SizedBox(width: 4),
          Text(
            'Your Location',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
