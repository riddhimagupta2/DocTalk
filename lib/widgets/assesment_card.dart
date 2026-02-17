import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';
import '../resources/AppTheme.dart';

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

  String get _severityEmoji {
    switch (assessment.severity) {
      case 'URGENT':
        return '🔴';
      case 'MEDIUM':
        return '🟡';
      default:
        return '🟢';
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _severityColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _severityColor.withOpacity(0.1),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _severityColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _severityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('📋', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Health Assessment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontFamily: 'Lato',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _severityEmoji,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _severityLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: _severityColor,
                              fontWeight: FontWeight.w600,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Likely Conditions
                _SectionLabel(label: 'Possible Conditions'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: assessment.likelyconditions
                      .map((c) => _ConditionChip(condition: c))
                      .toList(),
                ),

                const SizedBox(height: 16),

                // Severity reason
                _InfoRow(
                  icon: '💡',
                  label: 'Why this assessment',
                  value: assessment.severityReason,
                ),

                const SizedBox(height: 12),

                // Recommended specialist
                _InfoRow(
                  icon: '👨‍⚕️',
                  label: 'Consult',
                  value: assessment.recommendedSpecialist,
                  valueStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),

                if (assessment.homeCare.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionLabel(label: 'Home Care Tips'),
                  const SizedBox(height: 8),
                  ...assessment.homeCare
                      .take(3)
                      .map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('✅', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(
                                    fontSize: 13,
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
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.urgent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.urgent.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('🚨', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 6),
                            Text(
                              'Go to ER if you experience:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.urgent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...assessment.redFlags
                            .take(2)
                            .map(
                              (flag) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '• $flag',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.urgent.withOpacity(0.8),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Disclaimer
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '⚕️ ${assessment.disclaimer}',
                    style: const TextStyle(
                      fontSize: 11,
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
      style: const TextStyle(
        fontSize: 10,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Text(
        condition,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
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
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style:
                    valueStyle ??
                    const TextStyle(
                      fontSize: 13,
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
