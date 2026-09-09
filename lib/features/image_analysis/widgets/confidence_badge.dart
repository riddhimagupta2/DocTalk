import 'package:flutter/material.dart';
import 'package:doctalk/resources/AppTheme.dart';
import 'package:doctalk/resources/responsive.dart';

class ConfidenceBadge extends StatelessWidget {
  final String confidence;

  const ConfidenceBadge({Key? key, required this.confidence}) : super(key: key);

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
        color: _color.withOpacity(0.15),
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
