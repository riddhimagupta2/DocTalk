import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctalk/features/image_analysis/models/image_analysis_model.dart';
import 'package:doctalk/features/image_analysis/widgets/severity_badge.dart';
import 'package:doctalk/features/image_analysis/widgets/confidence_badge.dart';
import 'package:doctalk/resources/AppTheme.dart';
import 'package:doctalk/resources/responsive.dart';

class AnalysisResultCard extends StatelessWidget {
  final ImageAnalysisResult result;

  const AnalysisResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      color: AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(20))),
      child: Padding(
        padding: EdgeInsets.all(context.r(20)),
        child: !result.isAnalyzable
            ? _buildUnanalyzableContent(context)
            : _buildAnalyzedContent(context),
      ),
    );
  }

  Widget _buildUnanalyzableContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📷 Image Could Not Be Analyzed',
          style: TextStyle(fontSize: context.sp(18), fontWeight: FontWeight.bold, color: AppColors.error),
        ),
        SizedBox(height: context.hp(2)),
        _buildSectionHeader(context, '📋 Recommendations'),
        ...result.recommendations.map((e) => _buildBulletPoint(context, e, icon: Icons.info_outline)),
        SizedBox(height: context.hp(2)),
        _buildDisclaimer(context),
      ],
    );
  }

  Widget _buildAnalyzedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SeverityBadge(severity: result.severity),
            ConfidenceBadge(confidence: result.confidence),
          ],
        ),
        SizedBox(height: context.hp(2)),
        const Divider(),
        SizedBox(height: context.hp(2)),
        
        _buildSectionHeader(context, '🩺 Possible Conditions'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: result.possibleConditions.map((e) => _buildConditionChip(context, e)).toList(),
        ),
        
        if (result.possibleCauses.isNotEmpty) ...[
          SizedBox(height: context.hp(2)),
          const Divider(),
          SizedBox(height: context.hp(2)),
          _buildSectionHeader(context, '🔍 Possible Causes'),
          ...result.possibleCauses.map((e) => _buildBulletPoint(context, e)),
        ],

        SizedBox(height: context.hp(2)),
        const Divider(),
        SizedBox(height: context.hp(2)),
        _buildSectionHeader(context, '📋 Recommendations'),
        ...result.recommendations.asMap().entries.map(
              (entry) => _buildBulletPoint(context, entry.value, icon: Icons.check_circle_outline, color: AppColors.primary),
            ),

        if (result.firstAid.isNotEmpty) ...[
          SizedBox(height: context.hp(2)),
          const Divider(),
          SizedBox(height: context.hp(2)),
          _buildSectionHeader(context, '🏥 First Aid'),
          ...result.firstAid.map((e) => _buildBulletPoint(context, e, icon: Icons.add_box, color: AppColors.coral)),
        ],

        if (result.redFlags.isNotEmpty) ...[
          SizedBox(height: context.hp(2)),
          Container(
            padding: EdgeInsets.all(context.r(12)),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.r(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, '⚠️ Red Flags - Watch For'),
                ...result.redFlags.map((e) => _buildBulletPoint(context, e, color: AppColors.error)),
              ],
            ),
          ),
        ],

        SizedBox(height: context.hp(2)),
        const Divider(),
        SizedBox(height: context.hp(2)),
        _buildSectionHeader(context, '👨‍⚕️ When to Visit Doctor'),
        Text(result.whenToVisitDoctor, style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(14))),

        if (result.doctorSpeciality.isNotEmpty) ...[
          SizedBox(height: context.hp(2)),
          const Divider(),
          SizedBox(height: context.hp(2)),
          _buildSectionHeader(context, '🏥 Recommended Specialist'),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(result.doctorSpeciality, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(13))),
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
              GestureDetector(
                onTap: () => Get.toNamed('/doctor-finder', arguments: {'specialist': result.doctorSpeciality}),
                child: Text(
                  'Find Nearby  →',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: context.sp(13)),
                ),
              ),
            ],
          ),
        ],

        SizedBox(height: context.hp(2.5)),
        _buildDisclaimer(context),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.hp(1.2)),
      child: Text(
        title,
        style: TextStyle(fontSize: context.sp(16), fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildConditionChip(BuildContext context, PossibleCondition condition) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.r(12), vertical: context.hp(0.9)),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: context.r(10), color: condition.likelihoodColor),
          SizedBox(width: context.r(8)),
          Text(condition.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(13))),
          SizedBox(width: context.r(8)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.r(6), vertical: 2),
            decoration: BoxDecoration(
              color: condition.likelihoodColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
            child: Text(
              condition.likelihood,
              style: TextStyle(fontSize: context.sp(10), color: condition.likelihoodColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text, {IconData? icon, Color? color}) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.hp(1.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? Icons.fiber_manual_record, size: icon != null ? context.r(18) : context.r(12), color: color ?? AppColors.textSecondary),
          SizedBox(width: context.r(8)),
          Expanded(child: Text(text, style: TextStyle(color: color ?? AppColors.textPrimary, fontSize: context.sp(14)))),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.r(12)),
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.5),
        borderRadius: BorderRadius.circular(context.r(12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚠️', style: TextStyle(fontSize: context.sp(16))),
          SizedBox(width: context.r(8)),
          Expanded(
            child: Text(
              result.disclaimer.isNotEmpty ? result.disclaimer : 'This AI analysis is not a substitute for professional medical advice, diagnosis, or treatment.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(12), fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
