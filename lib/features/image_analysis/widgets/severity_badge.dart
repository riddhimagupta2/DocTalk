import 'package:flutter/material.dart';
import '../../../resources/app_theme.dart';
import 'package:doctalk/resources/responsive.dart';

class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({super.key, required this.severity});

  String get _emoji {
    final s = severity.toLowerCase();
    if (s.contains('emergency')) return '\u{1F6A8}';
    if (s.contains('high')) return '\u{26A0}\u{FE0F}';
    if (s.contains('medium')) return '\u{26A0}\u{FE0F}';
    return '\u{2705}';
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
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(
        "$_emoji $_label",
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