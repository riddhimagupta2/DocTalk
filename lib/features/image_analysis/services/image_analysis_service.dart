import 'dart:io';
import '../models/image_analysis_model.dart';
import '../repositories/image_analysis_repository.dart';
import 'image_picker_service.dart';

class ImageAnalysisService {
  final ImageAnalysisRepository _repository = ImageAnalysisRepository();
  final ImagePickerService _pickerService = ImagePickerService();

  Future<File?> pickFromCamera() => _pickerService.pickFromCamera();

  Future<File?> pickFromGallery() => _pickerService.pickFromGallery();

  String? validateImage(File image) => _pickerService.getValidationError(image);

  Future<ImageAnalysisResult> analyzeImage({
    required File image,
    String? symptoms,
    int? age,
    String? gender,
    String? deviceInfo,
    Function(double)? onUploadProgress,
  }) async {
    return await _repository.analyzeImage(
      image: image,
      symptoms: symptoms,
      age: age,
      gender: gender,
      deviceInfo: deviceInfo,
      onProgress: onUploadProgress,
    );
  }

  Future<List<ImageAnalysisResult>> loadHistory({int page = 1}) =>
      _repository.getHistory(page: page);

  Future<void> deleteAnalysis(String analysisId) =>
      _repository.deleteAnalysis(analysisId);
}
