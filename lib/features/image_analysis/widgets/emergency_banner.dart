import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../resources/app_theme.dart';
import 'package:doctalk/resources/responsive.dart';

class EmergencyBanner extends StatelessWidget {
  final bool animate;
  const EmergencyBanner({super.key, this.animate = true});

  @override
  Widget build(BuildContext context) {
    final bannerContent = Container(
        padding: EdgeInsets.all(context.r(16)),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(context.r(16)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\u{26A0}\u{FE0F}', style: TextStyle(fontSize: context.sp(24))),
            SizedBox(width: context.wp(3).clamp(8.0, 14.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u{26A0}\u{FE0F} EMERGENCY',
                    style: TextStyle(color: Colors.white, fontSize: context.sp(18), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seek immediate medical attention',
                    style: TextStyle(color: Colors.white, fontSize: context.sp(14)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Call emergency services or visit the nearest hospital immediately.',
                    style: TextStyle(color: Colors.white, fontSize: context.sp(12)),
                  ),
                ],
              ),
            ),
          ],
        ),
    );

    if (!animate) return bannerContent;

    return Flash(
      duration: const Duration(seconds: 2),
      infinite: true,
      child: bannerContent,
    );
  }
}