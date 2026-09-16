import 'package:flutter/material.dart';

import 'package:doctalk/resources/responsive.dart';
import '../../../resources/app_theme.dart';

class ConfidenceBadge extends StatelessWidget {
  final String confidence;

  const ConfidenceBadge({super.key, required this.confidence});

  Color get _color {
    final c = confidence.toLowerCase();
    if (c.contains('high')) return AppColors.success;
    if (c.contains('medium')) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.r(12), vertical: context.hp(0.7).clamp(4.0, 8.0)),
      decoration: BoxDecoration(
        color: _color.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(
        'Confidence: $confidence',
        style: TextStyle(
          color: _color,
          fontSize: context.sp(12),
          fontWeight: FontWeight.bold,
          fontFamily: 'Lato',
        ),
      ),
    );
  }
}


