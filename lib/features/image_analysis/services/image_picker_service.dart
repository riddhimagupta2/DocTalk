import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  static const int _maxWidth = 1920;
  static const int _imageQuality = 85;
  static const int _maxSizeBytes = 10 * 1024 * 1024;

  Future<File?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: _maxWidth.toDouble(),
      imageQuality: _imageQuality,
    );
    if (image == null) return null;
    return _validateAndReturn(File(image.path));
  }

  Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxWidth.toDouble(),
      imageQuality: _imageQuality,
    );
    if (image == null) return null;
    return _validateAndReturn(File(image.path));
  }

  File? _validateAndReturn(File file) {
    try {
      if (!file.existsSync()) return null;
      if (file.lengthSync() > _maxSizeBytes) return null;
      return file;
    } catch (_) {
      return file;
    }
  }

  String? getValidationError(File file) {
    try {
      final sizeBytes = file.lengthSync();
      if (sizeBytes > _maxSizeBytes) {
        return 'Image is too large (${(sizeBytes / 1024 / 1024).toStringAsFixed(1)}MB). Maximum size is 10MB.';
      }
      if (sizeBytes == 0) {
        return 'The selected file appears to be empty.';
      }
    } catch (_) {}
    return null;
  }
}
