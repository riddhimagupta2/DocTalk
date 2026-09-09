import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctalk/features/image_analysis/controllers/image_analysis_controller.dart';
import 'package:doctalk/features/image_analysis/widgets/image_source_picker.dart';
import 'package:doctalk/features/image_analysis/widgets/image_preview_widget.dart';
import 'package:doctalk/features/image_analysis/widgets/analysis_loading_widget.dart';
import 'package:doctalk/features/image_analysis/widgets/emergency_banner.dart';
import 'package:doctalk/features/image_analysis/widgets/consent_dialog.dart';
import 'package:doctalk/features/image_analysis/widgets/analysis_result_card.dart';
import 'package:doctalk/resources/AppTheme.dart';
import 'package:doctalk/resources/AppRoutes.dart';
import 'package:doctalk/resources/responsive.dart';

class ImageAnalysisScreen extends StatelessWidget {
  const ImageAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ImageAnalysisController>()) {
      Get.put(ImageAnalysisController());
    }
    final controller = Get.find<ImageAnalysisController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Image Analysis',
          style: TextStyle(
            color: Colors.black,
            fontSize: context.sp(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.black, size: context.r(24)),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: Colors.black, size: context.r(24)),
            onPressed: () => Get.toNamed(AppRoutes.imageAnalysisHistory),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() => SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.wp(5).clamp(16.0, 32.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.hp(2).clamp(12.0, 20.0)),
                  if (controller.isUploading.value || controller.isAnalyzing.value)
                    AnalysisLoadingWidget(
                      isUploading: controller.isUploading.value,
                      isAnalyzing: controller.isAnalyzing.value,
                      uploadProgress: controller.uploadProgress.value,
                    )
                  else if (controller.hasError.value)
                    _buildErrorState(controller, context)
                  else if (controller.currentResult.value != null)
                    _buildResultState(controller, context)
                  else
                    _buildSelectionState(controller, context),
                  SizedBox(height: context.hp(4).clamp(24.0, 48.0)),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildSelectionState(ImageAnalysisController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.selectedImage.value == null)
          GestureDetector(
            onTap: () => ImageSourcePicker.show(
              context,
              onCamera: controller.pickFromCamera,
              onGallery: controller.pickFromGallery,
            ),
            child: Container(
              height: context.hp(26).clamp(180.0, 300.0),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, style: BorderStyle.solid, width: 2),
                borderRadius: BorderRadius.circular(context.r(20)),
                color: AppColors.cardBg,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: context.r(44), color: AppColors.textHint),
                  SizedBox(height: context.hp(1.5).clamp(8.0, 16.0)),
                  Text(
                    'Tap to add photo',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(16)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG, WebP • Max 10MB',
                    style: TextStyle(color: AppColors.textHint, fontSize: context.sp(12)),
                  ),
                ],
              ),
            ),
          )
        else
          ImagePreviewWidget(
            imageFile: controller.selectedImage.value!,
            onRemove: controller.removeImage,
            onRetake: () => ImageSourcePicker.show(
              context,
              onCamera: controller.pickFromCamera,
              onGallery: controller.pickFromGallery,
            ),
          ),
        
        SizedBox(height: context.hp(2).clamp(14.0, 20.0)),
        if (controller.selectedImage.value != null) ...[
          Text(
            'Additional Information (Optional)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(16)),
          ),
          SizedBox(height: context.hp(1)),
          TextField(
            onChanged: (val) => controller.symptoms.value = val,
            maxLines: 3,
            maxLength: 1000,
            style: TextStyle(fontSize: context.sp(14)),
            decoration: InputDecoration(
              hintText: 'Describe your symptoms...',
              hintStyle: TextStyle(fontSize: context.sp(14)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.r(14))),
              filled: true,
              fillColor: AppColors.cardBg,
            ),
          ),
          SizedBox(height: context.hp(1.2)),
          Row(
            children: [
              SizedBox(
                width: context.wp(28).clamp(90.0, 140.0),
                child: TextField(
                  onChanged: (val) => controller.age.value = int.tryParse(val),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: context.sp(14)),
                  decoration: InputDecoration(
                    hintText: 'Age',
                    hintStyle: TextStyle(fontSize: context.sp(14)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.r(14))),
                    filled: true,
                    fillColor: AppColors.cardBg,
                  ),
                ),
              ),
              SizedBox(width: context.wp(3).clamp(10.0, 18.0)),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: context.r(12)),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(context.r(14)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text('Gender', style: TextStyle(fontSize: context.sp(14))),
                      value: controller.gender.value.isEmpty ? null : controller.gender.value,
                      items: ['Male', 'Female', 'Other'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: context.sp(14))),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.gender.value = val;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.hp(1.5)),
          Row(
            children: [
              Checkbox(
                value: controller.consentGiven.value,
                onChanged: (val) => controller.consentGiven.value = val ?? false,
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: Text(
                  'I consent to AI processing of this medical image',
                  style: TextStyle(fontSize: context.sp(13)),
                ),
              ),
            ],
          ),
          SizedBox(height: context.hp(2)),
          SizedBox(
            width: double.infinity,
            height: context.hp(6.5).clamp(48.0, 56.0),
            child: ElevatedButton(
              onPressed: () async {
                if (!controller.consentGiven.value) {
                  final agreed = await ConsentDialog.show(context);
                  if (agreed) {
                    controller.consentGiven.value = true;
                    controller.submitAnalysis();
                  }
                } else {
                  controller.submitAnalysis();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
              ),
              child: Text(
                'Analyze Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: context.hp(1.5)),
          Text(
            'Your image will be securely processed by AI. Please do not use this for medical emergencies.',
            style: TextStyle(color: AppColors.textHint, fontSize: context.sp(12)),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildResultState(ImageAnalysisController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.currentResult.value!.isEmergency) ...[
          const EmergencyBanner(),
          SizedBox(height: context.hp(2)),
        ],
        AnalysisResultCard(result: controller.currentResult.value!),
        SizedBox(height: context.hp(2)),
        SizedBox(
          width: double.infinity,
          height: context.hp(6.2).clamp(46.0, 54.0),
          child: OutlinedButton(
            onPressed: controller.reset,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
            ),
            child: Text(
              'Analyze Another Image',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: context.sp(15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(ImageAnalysisController controller, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(20))),
      color: AppColors.cardBg,
      child: Padding(
        padding: EdgeInsets.all(context.r(24)),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: context.r(48), color: AppColors.error),
            SizedBox(height: context.hp(2)),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: context.sp(15)),
            ),
            SizedBox(height: context.hp(3)),
            SizedBox(
              width: double.infinity,
              height: context.hp(6).clamp(46.0, 52.0),
              child: ElevatedButton(
                onPressed: () {
                  if (controller.selectedImage.value != null) {
                    controller.submitAnalysis();
                  } else {
                    controller.reset();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white, fontSize: context.sp(15), fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
