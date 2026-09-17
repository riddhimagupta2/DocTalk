import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../resources/app_theme.dart';
import 'package:doctalk/resources/responsive.dart';

class AnalysisLoadingWidget extends StatelessWidget {
  final bool isUploading;
  final bool isAnalyzing;
  final double uploadProgress;

  const AnalysisLoadingWidget({
    super.key,
    required this.isUploading,
    required this.isAnalyzing,
    required this.uploadProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(20))),
      color: AppColors.cardBg,
      child: Padding(
        padding: EdgeInsets.all(context.r(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUploading) ...[
              Icon(Icons.cloud_upload_rounded, size: context.r(48), color: AppColors.primary),
              SizedBox(height: context.hp(2)),
              Text(
                'Uploading Image...',
                style: TextStyle(fontSize: context.sp(16), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: context.hp(2)),
              LinearProgressIndicator(
                value: uploadProgress.clamp(0.0, 1.0),
                backgroundColor: AppColors.primary.withValues(alpha:0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.circular(context.r(8)),
                minHeight: context.hp(1.0).clamp(6.0, 10.0),
              ),
              SizedBox(height: context.hp(1)),
              Text('${(uploadProgress * 100).toInt()}%', style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(13), fontWeight: FontWeight.w600)),
            ] else if (isAnalyzing) ...[
              Shimmer.fromColors(
                baseColor: AppColors.primaryDark,
                highlightColor: AppColors.primaryLight,
                child: Icon(Icons.psychology_rounded, size: context.r(52), color: AppColors.primary),
              ),
              SizedBox(height: context.hp(2)),
              Text(
                'AI Clinical Vision Analyzing...',
                style: TextStyle(fontSize: context.sp(16), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: context.hp(1)),
              Text(
                'Detecting visual patterns and conditions',
                style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(13)),
              ),
              SizedBox(height: context.hp(2)),
              const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
            ],
            SizedBox(height: context.hp(3)),
            Text(
              'Your image is being securely processed',
              style: TextStyle(color: AppColors.textHint, fontSize: context.sp(12)),
            ),
          ],
        ),
      ),
    );
  }
}


