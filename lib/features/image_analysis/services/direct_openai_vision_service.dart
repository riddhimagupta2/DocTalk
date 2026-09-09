import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/image_analysis_model.dart';

class DirectOpenAIVisionService {
  static String get _apiKey {
    final key = dotenv.env['OPENAI_API_KEY'] ?? dotenv.env['GEMINI_API_KEY'] ?? '';
    return key.replaceAll("'", '').replaceAll('"', '').trim();
  }

  // Multi-model fallback pool for automatic failover when rate limits are hit
  static const List<String> fallbackVisionModels = [
    'gpt-4.1-mini',
    'gpt-4o-mini',
    'gpt-4o',
    'gpt-4.1',
  ];

  static int _activeModelIndex = 0;
  static String get activeModelName {
    final envModel = dotenv.env['OPENAI_MODEL'];
    if (envModel != null && envModel.isNotEmpty) {
      return envModel;
    }
    return fallbackVisionModels[_activeModelIndex];
  }

  static const String _systemPrompt = '''You are DocTalk Vision, an AI clinical decision-support and educational assistant specializing in visual symptom triage.

STRICT MEDICAL & SAFETY DIRECTIVES:
1. YOU DO NOT DIAGNOSE DISEASES. You provide only preliminary educational evaluations.
2. NEVER claim certainty. Use language like "appear consistent with", "may indicate", or "possible consideration".
3. NEVER output 100% confidence. Allowed confidence levels: "Low", "Medium", "High".
4. If the image is blurry, out of focus, or does not show an anatomical surface clearly:
   - Set "image_quality": "poor"
   - Set "recommendations": ["Unable to analyze image clearly. Please retake the photo in good lighting with sharp focus."]
5. EMERGENCY PROTOCOL:
   If the image presents signs of:
   - Severe burns (2nd/3rd degree, extensive blistering, charred skin)
   - Heavy/pulsatile arterial bleeding
   - Necrotic or blackened tissue (gangrene, severe frostbite)
   - Extensive systemic infection (spreading erythema with lymphangitis streaking)
   - Deep penetrating lacerations / exposed bone or tendon
   - Severe eye trauma or chemical burns
   THEN:
   - Set "severity": "Emergency"
   - Set "emergency_detected": true
   - In "red_flags" and "first_aid", prioritize immediate emergency room (ER) directives.

MANDATORY DISCLAIMER:
Every response must include this exact statement:
"This analysis is AI generated and is not a medical diagnosis. Please consult a licensed doctor."

YOU MUST ALWAYS RESPOND WITH A SINGLE VALID JSON OBJECT MATCHING THIS EXACT SCHEMA:
{
  "image_quality": "good",
  "emergency_detected": false,
  "confidence": "Low" | "Medium" | "High",
  "severity": "Low" | "Medium" | "High" | "Emergency",
  "possible_conditions": [
    {
      "name": "Condition Name",
      "likelihood": "Possible" | "Likely" | "Less Likely"
    }
  ],
  "possible_causes": ["Cause 1", "Cause 2"],
  "recommendations": ["Recommendation 1", "Recommendation 2"],
  "first_aid": ["First aid step 1", "First aid step 2"],
  "red_flags": ["Warning sign 1", "Warning sign 2"],
  "when_to_visit_doctor": "Guidance on clinical consultation timeframe",
  "doctor_speciality": "e.g. Dermatologist, General Physician, Ophthalmologist, ER Physician",
  "disclaimer": "This analysis is AI generated and is not a medical diagnosis. Please consult a licensed doctor."
}

Do NOT output markdown code fences outside JSON. Return only pure JSON.''';

  Future<ImageAnalysisResult> analyzeImage({
    required File image,
    String? symptoms,
    int? age,
    String? gender,
    Function(double)? onProgress,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_OPENAI_API_KEY_HERE') {
      throw Exception('OpenAI API Key is not configured. Please check your .env file.');
    }

    onProgress?.call(0.2);

    final imageBytes = await image.readAsBytes();
    onProgress?.call(0.4);

    final ext = image.path.split('.').last.toLowerCase();
    String mimeType = 'image/jpeg';
    if (ext == 'png') {
      mimeType = 'image/png';
    } else if (ext == 'webp') {
      mimeType = 'image/webp';
    }

    final base64Image = base64Encode(imageBytes);
    final imageUrl = 'data:$mimeType;base64,$base64Image';

    final promptText = _buildPrompt(symptoms: symptoms, age: age, gender: gender);

    String rawJson = '';
    String? lastError;
    String winningModel = activeModelName;

    final configuredModel = (dotenv.env['OPENAI_MODEL'] ?? '').trim();
    final candidateModels = <String>[];
    if (configuredModel.isNotEmpty && !candidateModels.contains(configuredModel)) {
      candidateModels.add(configuredModel);
    }
    for (final m in fallbackVisionModels) {
      if (!candidateModels.contains(m)) {
        candidateModels.add(m);
      }
    }

    // Loop through candidate models if rate limits or errors are hit
    for (int i = 0; i < candidateModels.length; i++) {
      final currentModel = candidateModels[i];

      try {
        debugPrint('🔬 Querying OpenAI Vision model: $currentModel (${i + 1}/${candidateModels.length})...');
        onProgress?.call(0.5 + (i * 0.1));

        final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
        final payload = {
          'model': currentModel,
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': promptText},
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': imageUrl,
                    'detail': 'high',
                  },
                },
              ],
            },
          ],
          'response_format': {'type': 'json_object'},
          'temperature': 0.2,
          'max_tokens': 1500,
        };

        final response = await http
            .post(
              uri,
              headers: {
                'Authorization': 'Bearer $_apiKey',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 40));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final text = choices[0]['message']?['content']?.toString() ?? '';
            if (text.isNotEmpty) {
              rawJson = text;
              winningModel = currentModel;
              _activeModelIndex = i;
              debugPrint('✅ Analysis succeeded with OpenAI model: $currentModel');
              break;
            }
          }
        } else if (response.statusCode == 429) {
          lastError = 'Rate limit (429): ${response.body}';
          debugPrint('⚠️ Model $currentModel hit rate limit. Auto-shifting...');
          continue;
        } else {
          lastError = 'OpenAI API error (${response.statusCode}): ${response.body}';
          debugPrint('⚠️ Model $currentModel error: $lastError');
          continue;
        }
      } catch (e) {
        lastError = e.toString();
        debugPrint('⚠️ Model $currentModel exception: $lastError. Auto-shifting to next model...');
        continue;
      }
    }

    onProgress?.call(1.0);

    if (rawJson.isEmpty) {
      throw Exception('OpenAI Vision analysis unavailable. Last error: $lastError');
    }

    try {
      String cleanJson = rawJson.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      } else if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      final firstBrace = cleanJson.indexOf('{');
      final lastBrace = cleanJson.lastIndexOf('}');
      if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
        cleanJson = cleanJson.substring(firstBrace, lastBrace + 1);
      }

      final jsonMap = jsonDecode(cleanJson) as Map<String, dynamic>;
      jsonMap['id'] = 'local_${DateTime.now().millisecondsSinceEpoch}';
      jsonMap['status'] = 'completed';
      jsonMap['image_url'] = '';
      jsonMap['storage_path'] = image.path;
      jsonMap['symptoms'] = symptoms;
      jsonMap['age'] = age;
      jsonMap['gender'] = gender;
      jsonMap['ai_model_version'] = winningModel;
      jsonMap['created_at'] = DateTime.now().toIso8601String();
      return ImageAnalysisResult.fromJson(jsonMap);
    } catch (e) {
      debugPrint('JSON parse error: $e, raw: $rawJson');
      throw Exception('Failed to parse AI medical evaluation result: $e');
    }
  }

  String _buildPrompt({String? symptoms, int? age, String? gender}) {
    final buffer = StringBuffer();
    buffer.writeln('Please analyze this patient medical symptom image and provide a preliminary educational assessment according to the system instructions.');

    final details = <String>[];
    if (age != null) details.add('Age: $age');
    if (gender != null && gender.isNotEmpty) details.add('Gender: $gender');
    if (details.isNotEmpty) {
      buffer.writeln('Patient Demographics: ${details.join(', ')}');
    }

    if (symptoms != null && symptoms.trim().isNotEmpty) {
      buffer.writeln('Patient Reported Symptoms: "${symptoms.trim()}"');
    } else {
      buffer.writeln('Patient Reported Symptoms: None provided.');
    }

    buffer.writeln('Remember to return ONLY the requested JSON schema.');
    return buffer.toString();
  }
}

// Backwards compatibility alias
typedef DirectGeminiVisionService = DirectOpenAIVisionService;
