import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctalk/features/image_analysis/models/image_analysis_model.dart';
import 'package:doctalk/features/image_analysis/services/image_analysis_service.dart';
import 'package:doctalk/resources/AppTheme.dart';

class ImageAnalysisController extends GetxController {
  final ImageAnalysisService _service = ImageAnalysisService();

  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isUploading = false.obs;
  final RxBool isAnalyzing = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final Rx<ImageAnalysisResult?> currentResult = Rx<ImageAnalysisResult?>(null);
  final RxList<ImageAnalysisResult> history = <ImageAnalysisResult>[].obs;
  final RxString errorMessage = ''.obs;
  final RxBool consentGiven = true.obs;
  final RxBool isLoadingHistory = false.obs;
  final RxBool hasError = false.obs;

  final RxString symptoms = ''.obs;
  final Rx<int?> age = Rx<int?>(null);
  final RxString gender = ''.obs;

  bool _isProcessing = false;

  Future<void> pickFromCamera() async {
    try {
      final file = await _service.pickFromCamera();
      if (file != null) {
        final error = _service.validateImage(file);
        if (error != null) {
          Get.snackbar('Invalid Image', error, snackPosition: SnackPosition.BOTTOM);
          return;
        }
        selectedImage.value = file;
        errorMessage.value = '';
        hasError.value = false;
      }
    } catch (e) {
      Get.snackbar('Camera', 'Could not capture photo: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final file = await _service.pickFromGallery();
      if (file != null) {
        final error = _service.validateImage(file);
        if (error != null) {
          Get.snackbar('Invalid Image', error, snackPosition: SnackPosition.BOTTOM);
          return;
        }
        selectedImage.value = file;
        errorMessage.value = '';
        hasError.value = false;
      }
    } catch (e) {
      Get.snackbar('Gallery', 'Could not select photo: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void removeImage() {
    selectedImage.value = null;
    currentResult.value = null;
    errorMessage.value = '';
    hasError.value = false;
  }

  Future<void> submitAnalysis() async {
    if (_isProcessing) return;
    if (selectedImage.value == null) return;
    if (!consentGiven.value) {
      Get.snackbar(
        'Consent Required',
        'Please agree to AI processing before submitting.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }

    _isProcessing = true;
    isUploading.value = true;
    isAnalyzing.value = false;
    hasError.value = false;
    errorMessage.value = '';
    uploadProgress.value = 0.1;
    currentResult.value = null;

    try {
      final result = await _service.analyzeImage(
        image: selectedImage.value!,
        symptoms: symptoms.value.isEmpty ? null : symptoms.value,
        age: age.value,
        gender: gender.value.isEmpty ? null : gender.value,
        onUploadProgress: (progress) {
          uploadProgress.value = progress;
          if (progress >= 0.7) {
            isUploading.value = false;
            isAnalyzing.value = true;
          }
        },
      );

      currentResult.value = result;
      isAnalyzing.value = false;

      if (result.isEmergency) {
        Get.snackbar(
          '🚨 Emergency Detected',
          'Please seek immediate medical attention!',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      hasError.value = true;
      final msg = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = msg;
      Get.snackbar(
        'Analysis Failed',
        msg,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isUploading.value = false;
      isAnalyzing.value = false;
      _isProcessing = false;
    }
  }

  Future<void> loadHistory() async {
    try {
      isLoadingHistory.value = true;
      final results = await _service.loadHistory();
      history.value = results;
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('History', msg, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> deleteAnalysis(ImageAnalysisResult analysis) async {
    try {
      await _service.deleteAnalysis(analysis.id);
      history.removeWhere((item) => item.id == analysis.id);
      Get.snackbar(
        'Deleted',
        'Analysis and medical image permanently deleted.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Delete Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  void reset() {
    selectedImage.value = null;
    isUploading.value = false;
    isAnalyzing.value = false;
    uploadProgress.value = 0.0;
    currentResult.value = null;
    errorMessage.value = '';
    consentGiven.value = false;
    hasError.value = false;
    symptoms.value = '';
    age.value = null;
    gender.value = '';
    _isProcessing = false;
  }
}
