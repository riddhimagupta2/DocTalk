import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';
import '../resources/app_theme.dart';
import '../resources/responsive.dart';

class AssessmentCard extends StatelessWidget {
  final AssessmentData assessment;

  const AssessmentCard({super.key, required this.assessment});

  Color get _severityColor {
    switch (assessment.severity) {
      case 'URGENT':
        return AppColors.urgent;
      case 'MEDIUM':
        return AppColors.medium;
      default:
        return AppColors.low;
    }
  }

  IconData get _severityIcon {
    switch (assessment.severity) {
      case 'URGENT':
        return Icons.warning_rounded;
      case 'MEDIUM':
        return Icons.warning_amber_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  String get _severityLabel {
    switch (assessment.severity) {
      case 'URGENT':
        return 'Urgent — See Doctor Today';
      case 'MEDIUM':
        return 'See Doctor in 24-48 Hours';
      default:
        return 'Low Risk — Monitor at Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: context.hp(1.0).clamp(6.0, 12.0)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: _severityColor.withValues(alpha:0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _severityColor.withValues(alpha:0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(context.r(16)),
            decoration: BoxDecoration(
              color: _severityColor.withValues(alpha:0.08),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(context.r(18)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.r(8)),
                  decoration: BoxDecoration(
                    color: _severityColor.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(context.r(10)),
                  ),
                  child: Icon(_severityIcon, size: context.r(22), color: _severityColor),
                ),
                SizedBox(width: context.wp(3).clamp(8.0, 16.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Assessment',
                        style: TextStyle(
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontFamily: 'Lato',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(_severityIcon, size: context.r(14), color: _severityColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _severityLabel,
                              style: TextStyle(
                                fontSize: context.sp(12),
                                color: _severityColor,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: EdgeInsets.all(context.r(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Likely Conditions
                _SectionLabel(label: 'Possible Conditions'),
                SizedBox(height: context.hp(1)),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: assessment.likelyconditions
                      .map((c) => _ConditionChip(condition: c))
                      .toList(),
                ),

                SizedBox(height: context.hp(2)),

                // Severity reason
                _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Why this assessment',
                  value: assessment.severityReason,
                ),

                SizedBox(height: context.hp(1.5)),

                // Recommended specialist
                _InfoRow(
                  icon: Icons.medical_services_outlined,
                  label: 'Consult',
                  value: assessment.recommendedSpecialist,
                  valueStyle: TextStyle(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),

                if (assessment.homeCare.isNotEmpty) ...[
                  SizedBox(height: context.hp(2)),
                  _SectionLabel(label: 'Home Care Tips'),
                  SizedBox(height: context.hp(1)),
                  ...assessment.homeCare
                      .take(3)
                      .map(
                        (tip) => Padding(
                          padding: EdgeInsets.only(bottom: context.hp(0.8)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: context.r(15),
                                color: AppColors.primary,
                              ),
                              SizedBox(width: context.wp(2).clamp(6.0, 10.0)),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    fontSize: context.sp(13),
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],

                if (assessment.redFlags.isNotEmpty &&
                    assessment.severity != 'LOW') ...[
                  SizedBox(height: context.hp(2)),
                  Container(
                    padding: EdgeInsets.all(context.r(12)),
                    decoration: BoxDecoration(
                      color: AppColors.urgent.withValues(alpha:0.05),
                      borderRadius: BorderRadius.circular(context.r(10)),
                      border: Border.all(
                        color: AppColors.urgent.withValues(alpha:0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: context.r(16),
                              color: AppColors.urgent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Go to ER if you experience:',
                              style: TextStyle(
                                fontSize: context.sp(13),
                                fontWeight: FontWeight.w700,
                                color: AppColors.urgent,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.hp(0.8)),
                        ...assessment.redFlags
                            .take(2)
                            .map(
                              (flag) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '• $flag',
                                  style: TextStyle(
                                    fontSize: context.sp(12),
                                    color: AppColors.urgent.withValues(alpha:0.8),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: context.hp(2)),

                // Disclaimer
                Container(
                  padding: EdgeInsets.all(context.r(10)),
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha:0.5),
                    borderRadius: BorderRadius.circular(context.r(8)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: context.r(14),
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'DocTalk provides preliminary AI guidance for informational purposes only. Always consult a qualified doctor for diagnosis and clinical care.',
                          style: TextStyle(
                            fontSize: context.sp(11),
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: context.sp(10),
        fontWeight: FontWeight.w700,
        color: AppColors.textHint,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  final String condition;

  const _ConditionChip({required this.condition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.r(10), vertical: context.hp(0.6)),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(context.r(6)),
        border: Border.all(color: AppColors.primary.withValues(alpha:0.2)),
      ),
      child: Text(
        condition,
        style: TextStyle(
          fontSize: context.sp(12),
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: context.r(16), color: AppColors.primary),
        SizedBox(width: context.wp(2).clamp(6.0, 10.0)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: context.sp(11),
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: valueStyle ??
                    TextStyle(
                      fontSize: context.sp(13),
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



