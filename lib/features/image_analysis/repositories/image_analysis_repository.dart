import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/image_analysis_model.dart';
import '../services/direct_openai_vision_service.dart';

class ImageAnalysisRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DirectOpenAIVisionService _directAiService = DirectOpenAIVisionService();

  static const String _localHistoryKey = 'doctalk_image_analysis_history';

  String get _baseUrl {
    final envUrl = dotenv.env['BACKEND_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl.replaceAll(RegExp(r'/$'), '');
    }
    // Default emulator/device routing
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  Future<String?> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (kDebugMode) return 'test_token_anonymous_dev';
      return null;
    }
    return await user.getIdToken();
  }

  /// Primary analysis method.
  /// Tries the Django backend with a 6-second connection timeout.
  /// If the backend is unreachable (e.g. phone on 4G cellular, backend offline,
  /// or 10.0.2.2 loopback timeout on real hardware), it seamlessly falls back
  /// to the direct OpenAI Vision AI pipeline so the user NEVER experiences a crash.
  Future<ImageAnalysisResult> analyzeImage({
    required File image,
    String? symptoms,
    int? age,
    String? gender,
    String? deviceInfo,
    Function(double)? onProgress,
  }) async {
    try {
      debugPrint('Attempting backend analysis via $_baseUrl...');
      final backendResult = await _callBackendAnalyze(
        image: image,
        symptoms: symptoms,
        age: age,
        gender: gender,
        deviceInfo: deviceInfo,
        onProgress: onProgress,
      ).timeout(const Duration(milliseconds: 2500));

      await _saveLocalHistory(backendResult);
      return backendResult;
    } catch (e) {
      debugPrint('Backend unavailable or failed ($e). Seamlessly falling back to Direct OpenAI Vision AI...');
      return await _fallbackDirectAI(
        image: image,
        symptoms: symptoms,
        age: age,
        gender: gender,
        onProgress: onProgress,
      );
    }
  }

  Future<ImageAnalysisResult> _fallbackDirectAI({
    required File image,
    String? symptoms,
    int? age,
    String? gender,
    Function(double)? onProgress,
  }) async {
    final result = await _directAiService.analyzeImage(
      image: image,
      symptoms: symptoms,
      age: age,
      gender: gender,
      onProgress: onProgress,
    );
    await _saveLocalHistory(result);
    return result;
  }

  Future<ImageAnalysisResult> _callBackendAnalyze({
    required File image,
    String? symptoms,
    int? age,
    String? gender,
    String? deviceInfo,
    Function(double)? onProgress,
  }) async {
    final idToken = await _getIdToken();
    final uri = Uri.parse('$_baseUrl/api/v1/image-analysis/analyze/');

    final request = http.MultipartRequest('POST', uri);
    if (idToken != null) {
      request.headers['Authorization'] = 'Bearer $idToken';
    }
    request.headers['Accept'] = 'application/json';
    request.fields['consent_given'] = 'true';

    if (symptoms != null && symptoms.trim().isNotEmpty) {
      request.fields['symptoms'] = symptoms.trim();
    }
    if (age != null) {
      request.fields['age'] = age.toString();
    }
    if (gender != null && gender.trim().isNotEmpty) {
      request.fields['gender'] = gender.trim();
    }
    if (deviceInfo != null && deviceInfo.trim().isNotEmpty) {
      request.fields['device_info'] = deviceInfo.trim();
    }

    final multipartFile = await http.MultipartFile.fromPath('image', image.path);
    request.files.add(multipartFile);

    onProgress?.call(0.2);
    final streamedResponse = await request.send();
    onProgress?.call(0.6);

    final response = await http.Response.fromStream(streamedResponse);
    onProgress?.call(1.0);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return ImageAnalysisResult.fromJson(jsonMap);
    } else if (response.statusCode == 202) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      final analysisId = jsonMap['data']?['id'] ?? jsonMap['id'];
      return await pollAnalysisResult(analysisId);
    } else {
      String errMsg = 'Server error (${response.statusCode})';
      try {
        final errJson = jsonDecode(response.body);
        if (errJson is Map && errJson['error'] != null) {
          errMsg = errJson['error']['message'] ?? errMsg;
        }
      } catch (_) {}
      throw Exception(errMsg);
    }
  }

  Future<ImageAnalysisResult> pollAnalysisResult(
    String id, {
    int maxAttempts = 20,
    Duration interval = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(interval);
      final result = await getAnalysisResult(id);
      if (result.status.toLowerCase() == 'completed') {
        return result;
      } else if (result.status.toLowerCase() == 'failed') {
        throw Exception(result.errorMessage ?? 'AI Analysis processing failed.');
      }
    }
    throw TimeoutException('Medical image analysis timed out. Please try again.');
  }

  Future<ImageAnalysisResult> getAnalysisResult(String id) async {
    final idToken = await _getIdToken();
    final uri = Uri.parse('$_baseUrl/api/v1/image-analysis/$id/');

    final response = await http.get(
      uri,
      headers: {
        if (idToken != null) 'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return ImageAnalysisResult.fromJson(jsonMap);
    } else {
      throw Exception('Failed to fetch analysis result: ${response.statusCode}');
    }
  }

  Future<List<ImageAnalysisResult>> getHistory({int page = 1}) async {
    try {
      final idToken = await _getIdToken();
      final uri = Uri.parse('$_baseUrl/api/v1/image-analysis/history/?page=$page');

      final response = await http.get(
        uri,
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        final results = jsonMap['results'] ?? jsonMap['data'] ?? [];
        if (results is List) {
          return results
              .map((item) => ImageAnalysisResult.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fallback to local history
    }

    return await _getLocalHistory();
  }

  Future<void> deleteAnalysis(String id) async {
    try {
      final idToken = await _getIdToken();
      final uri = Uri.parse('$_baseUrl/api/v1/image-analysis/$id/delete/');

      await http.delete(
        uri,
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}

    await _deleteLocalHistory(id);
  }

  // Local persistence helpers for offline resilience
  Future<void> _saveLocalHistory(ImageAnalysisResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = prefs.getStringList(_localHistoryKey) ?? [];
      final jsonStr = jsonEncode(result.toJson());
      historyList.insert(0, jsonStr);
      if (historyList.length > 30) historyList.removeLast();
      await prefs.setStringList(_localHistoryKey, historyList);
    } catch (e) {
      debugPrint('Failed to save local history: $e');
    }
  }

  Future<List<ImageAnalysisResult>> _getLocalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_localHistoryKey) ?? [];
      return list.map((str) {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return ImageAnalysisResult.fromJson(map);
      }).toList();
    } catch (e) {
      debugPrint('Failed to load local history: $e');
      return [];
    }
  }

  Future<void> _deleteLocalHistory(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_localHistoryKey) ?? [];
      list.removeWhere((str) {
        try {
          final map = jsonDecode(str) as Map<String, dynamic>;
          return map['id'] == id;
        } catch (_) {
          return false;
        }
      });
      await prefs.setStringList(_localHistoryKey, list);
    } catch (_) {}
  }
}
