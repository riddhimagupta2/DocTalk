import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctalk/features/image_analysis/models/image_analysis_model.dart';
import 'package:doctalk/features/image_analysis/widgets/severity_badge.dart';
import 'package:doctalk/features/image_analysis/widgets/confidence_badge.dart';
import 'package:doctalk/resources/AppTheme.dart';

class HistoryListTile extends StatelessWidget {
  final ImageAnalysisResult analysis;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HistoryListTile({
    Key? key,
    required this.analysis,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: analysis.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: analysis.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: AppColors.border),
                      errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      color: AppColors.border,
                      child: const Icon(Icons.image, color: Colors.white),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analysis.possibleConditions.isNotEmpty
                        ? analysis.possibleConditions.first.name
                        : 'Analysis',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SeverityBadge(severity: analysis.severity),
                      const SizedBox(width: 4),
                      ConfidenceBadge(confidence: analysis.confidence),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    analysis.timeAgo,
                    style: TextStyle(color: AppColors.textHint, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.textHint),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
