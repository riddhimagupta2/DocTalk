import 'package:flutter/material.dart';
import 'package:doctalk/resources/AppTheme.dart';
import 'package:doctalk/resources/responsive.dart';

class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({Key? key, required this.severity}) : super(key: key);

  String get _emoji {
    final s = severity.toLowerCase();
    if (s.contains('emergency')) return '🚨';
    if (s.contains('high')) return '⚠️';
    if (s.contains('medium')) return '⚠️';
    return '✅';
  }

  Color get _color {
    final s = severity.toLowerCase();
    if (s.contains('emergency') || s.contains('high')) return AppColors.error;
    if (s.contains('medium')) return AppColors.warning;
    return AppColors.success;
  }

  String get _label {
    final s = severity.toLowerCase();
    if (s.contains('emergency')) return 'EMERGENCY';
    return severity.toUpperCase();
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
        '$_emoji $_label',
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
