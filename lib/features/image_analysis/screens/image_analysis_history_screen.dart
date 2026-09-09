import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctalk/features/image_analysis/controllers/image_analysis_controller.dart';
import 'package:doctalk/features/image_analysis/widgets/history_list_tile.dart';
import 'package:doctalk/features/image_analysis/widgets/analysis_result_card.dart';
import 'package:doctalk/features/image_analysis/models/image_analysis_model.dart';
import 'package:doctalk/resources/AppTheme.dart';
import 'package:doctalk/resources/responsive.dart';

class ImageAnalysisHistoryScreen extends StatelessWidget {
  const ImageAnalysisHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageAnalysisController>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadHistory();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Analysis History',
          style: TextStyle(
            color: Colors.black,
            fontSize: context.sp(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: context.r(24)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingHistory.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.history.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return RefreshIndicator(
          onRefresh: controller.loadHistory,
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: context.wp(5).clamp(16.0, 24.0),
              vertical: context.hp(2).clamp(12.0, 20.0),
            ),
            itemCount: controller.history.length,
            itemBuilder: (context, index) {
              final analysis = controller.history[index];
              return HistoryListTile(
                analysis: analysis,
                onTap: () => _showAnalysisDetail(context, analysis),
                onDelete: () => _confirmDelete(context, controller, analysis),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: context.r(80), color: AppColors.textHint.withOpacity(0.5)),
          SizedBox(height: context.hp(2)),
          Text(
            'No analyses yet',
            style: TextStyle(fontSize: context.sp(18), fontWeight: FontWeight.bold),
          ),
          SizedBox(height: context.hp(1)),
          Text(
            'Your past image analyses will appear here.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(14)),
          ),
        ],
      ),
    );
  }

  void _showAnalysisDetail(BuildContext context, ImageAnalysisResult analysis) {
    Get.bottomSheet(
      Container(
        color: AppColors.background,
        padding: EdgeInsets.only(top: context.hp(2)),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.r(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: context.wp(10).clamp(36.0, 48.0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: context.hp(2)),
              AnalysisResultCard(result: analysis),
              SizedBox(height: context.hp(4)),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _confirmDelete(BuildContext context, ImageAnalysisController controller, ImageAnalysisResult analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(16))),
        title: Text('Delete Analysis', style: TextStyle(fontSize: context.sp(17), fontWeight: FontWeight.bold)),
        content: Text('Delete this analysis? This will permanently remove the image and results.', style: TextStyle(fontSize: context.sp(14))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: context.sp(14))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteAnalysis(analysis);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(10))),
            ),
            child: Text('Delete', style: TextStyle(color: Colors.white, fontSize: context.sp(14))),
          ),
        ],
      ),
    );
  }
}
