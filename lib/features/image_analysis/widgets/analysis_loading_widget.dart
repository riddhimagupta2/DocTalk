import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:doctalk/resources/AppTheme.dart';
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
              Icon(Icons.cloud_upload_outlined, size: context.r(48), color: AppColors.primary),
              SizedBox(height: context.hp(2)),
              Text(
                '📤 Uploading Image...',
                style: TextStyle(fontSize: context.sp(16), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: context.hp(2)),
              LinearProgressIndicator(
                value: uploadProgress,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.circular(context.r(8)),
                minHeight: context.hp(1.0).clamp(6.0, 10.0),
              ),
              SizedBox(height: context.hp(1)),
              Text('%', style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(13))),
            ] else if (isAnalyzing) ...[
              Shimmer.fromColors(
                baseColor: AppColors.primary.withOpacity(0.5),
                highlightColor: AppColors.primary,
                child: Icon(Icons.science, size: context.r(48)),
              ),
              SizedBox(height: context.hp(2)),
              Text(
                '🔬 AI is analyzing your image...',
                style: TextStyle(fontSize: context.sp(16), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: context.hp(1)),
              Text(
                'This may take a few seconds',
                style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(14)),
              ),
              SizedBox(height: context.hp(2)),
              const CircularProgressIndicator(color: AppColors.primary),
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
