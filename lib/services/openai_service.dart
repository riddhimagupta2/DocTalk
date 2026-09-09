import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message_model.dart';

class OpenAIService {
  static String get _apiKey {
    final key = dotenv.env['OPENAI_API_KEY'] ?? dotenv.env['GEMINI_API_KEY'] ?? '';
    return key.replaceAll("'", '').replaceAll('"', '').trim();
  }

  static const String _systemPrompt = '''
You are DocTalk, a warm and empathetic AI health assistant for Indian users.

YOUR CRITICAL TASK: After 3-5 exchanges, you MUST provide a health assessment in JSON format.

CONVERSATION FLOW:

Phase 1 (Message 1): 
- Warm greeting, ask for symptoms

Phase 2 (Messages 2-4): 
- Ask ONE follow-up question per message:
  * Duration: "Yeh kab se ho raha hai?"
  * Severity: "1 se 10 mein kitna dard hai?"
  * Location: "Exactly kahan feel ho raha hai?"
  * Associated symptoms: "Kya saath mein bukhar bhi hai?"
  * History: "Pehle kabhi aisa hua tha?"
- End each question with quick replies: [QUICK_REPLIES: Option1 | Option2 | Option3]

Phase 3 (After 3-5 exchanges):
YOU MUST RETURN THIS EXACT JSON FORMAT WRAPPED IN <ASSESSMENT> TAGS:

<ASSESSMENT>
{
  "assessment_ready": true,
  "likely_conditions": ["Primary condition", "Alternative possibility"],
  "severity": "MEDIUM",
  "severity_reason": "Brief explanation of why this severity level",
  "recommended_specialist": "General Physician",
  "home_care_tips": ["Rest properly", "Stay hydrated", "Monitor symptoms"],
  "red_flags": ["If symptom X worsens, seek emergency care"],
  "disclaimer": "Yeh preliminary assessment hai. Doctor se milna zaroori hai.",
  "summary_message": "Warm 2-3 sentence summary in Hinglish about likely condition"
}
</ASSESSMENT>

SEVERITY RULES (CRITICAL):
- LOW: Manageable at home, see doctor if persists 3+ days
- MEDIUM: Should see doctor within 24-48 hours
- URGENT: Go to doctor/ER today - immediate attention needed

SPECIALIST OPTIONS:
"General Physician", "ENT Specialist", "Cardiologist", "Neurologist", "Dermatologist", "Gastroenterologist", "Orthopedic", "Pulmonologist", "Psychiatrist", "Gynecologist", "Pediatrician"

PERSONALITY:
- Warm, empathetic, never scary
- Speak in user's language (Hindi/English/Hinglish naturally)
- Simple words, no medical jargon
- Say "it could be" or "most likely", never definitively diagnose
- Keep responses 2-4 lines max

QUICK REPLIES FORMAT:
[QUICK_REPLIES: Option1 | Option2 | Option3]

NEVER:
- Suggest specific drug names or exact dosages
- Ask more than ONE question per message
- Skip the assessment after sufficient information
''';

  static const List<String> fallbackModels = [
    'gpt-4.1-mini',
    'gpt-4o-mini',
    'gpt-4o',
    'gpt-4.1',
  ];

  int _currentModelIndex = 0;
  String get activeModelName {
    final envModel = dotenv.env['OPENAI_MODEL'];
    if (envModel != null && envModel.isNotEmpty) {
      return envModel;
    }
    return fallbackModels[_currentModelIndex];
  }

  final List<Map<String, String>> _messagesHistory = [];
  int _messageCount = 0;
  bool _isProcessing = false;
  DateTime? _lastRequestTime;

  OpenAIService() {
    resetSession();
  }

  void resetSession() {
    _messagesHistory.clear();
    _messagesHistory.add({'role': 'system', 'content': _systemPrompt});
    _messageCount = 0;
    _currentModelIndex = 0;
  }

  Future<AIResponse> sendMessage(String userMessage) async {
    final now = DateTime.now();

    if (_isProcessing) {
      return AIResponse(
        text: 'Pichle message ka response aa raha hai, kripya thoda wait karein...',
        quickReplies: [],
        isError: true,
      );
    }

    if (_lastRequestTime != null) {
      final gap = now.difference(_lastRequestTime!).inMilliseconds;
      if (gap < 1500) {
        return AIResponse(
          text: 'Thoda dheere type karein...',
          quickReplies: [],
          isError: true,
        );
      }
    }

    if (_apiKey.isEmpty || _apiKey == 'YOUR_OPENAI_API_KEY_HERE') {
      return AIResponse(
        text: '🔑 OpenAI API Key Missing!\n\nPlease add your OPENAI_API_KEY in the .env file.',
        quickReplies: [],
        isError: true,
      );
    }

    _isProcessing = true;
    _lastRequestTime = now;
    _messageCount++;

    _messagesHistory.add({'role': 'user', 'content': userMessage});

    final configuredModel = (dotenv.env['OPENAI_MODEL'] ?? '').trim();
    final candidateModels = <String>[];
    if (configuredModel.isNotEmpty && !candidateModels.contains(configuredModel)) {
      candidateModels.add(configuredModel);
    }
    for (final m in fallbackModels) {
      if (!candidateModels.contains(m)) {
        candidateModels.add(m);
      }
    }

    for (int attempt = 0; attempt < candidateModels.length; attempt++) {
      final modelToUse = candidateModels[attempt];

      try {
        debugPrint('🤖 Sending prompt to OpenAI: $modelToUse (msg #$_messageCount)...');

        final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
        final response = await http
            .post(
              uri,
              headers: {
                'Authorization': 'Bearer $_apiKey',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': modelToUse,
                'messages': _messagesHistory,
                'temperature': 0.7,
                'max_tokens': 1200,
              }),
            )
            .timeout(const Duration(seconds: 35));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final rawText = choices[0]['message']?['content']?.toString() ?? '';
            _currentModelIndex = attempt;

            _messagesHistory.add({'role': 'assistant', 'content': rawText});
            final parsed = _parseResponse(rawText);
            _isProcessing = false;
            return parsed;
          }
        } else if (response.statusCode == 429) {
          debugPrint('⚠️ Model $modelToUse hit rate limit. Switching to next model...');
          continue;
        } else {
          debugPrint('⚠️ Model $modelToUse returned error status: ${response.statusCode}');
          continue;
        }
      } catch (e) {
        debugPrint('⚠️ OpenAI exception on $modelToUse: $e');
        continue;
      }
    }

    _isProcessing = false;
    return AIResponse(
      text: 'Maaf kijiye, server se connect nahi ho pa raha hai. Kripya check karein ki aapka OpenAI API key valid hai.',
      quickReplies: ['Try Again', 'Doctor Dhundho'],
      isError: true,
    );
  }

  AIResponse _parseResponse(String rawText) {
    AssessmentData? assessment;
    List<String> quickReplies = [];
    String cleanText = rawText;

    if (rawText.contains('<ASSESSMENT>') && rawText.contains('</ASSESSMENT>')) {
      final start = rawText.indexOf('<ASSESSMENT>') + '<ASSESSMENT>'.length;
      final end = rawText.indexOf('</ASSESSMENT>');

      if (end > start) {
        final jsonStr = rawText.substring(start, end).trim();
        try {
          final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
          if (jsonData['assessment_ready'] == true) {
            assessment = AssessmentData.fromJson(jsonData);
            cleanText = jsonData['summary_message']?.toString() ??
                'Aapka health assessment ready hai. Neeche dekho.';
          }
        } catch (e) {
          debugPrint('❌ Assessment parse error: $e');
        }
      }

      cleanText = cleanText
          .replaceAll(RegExp(r'<ASSESSMENT>.*?</ASSESSMENT>', dotAll: true), '')
          .trim();
    }

    if (cleanText.contains('[QUICK_REPLIES:')) {
      final qrStart = cleanText.indexOf('[QUICK_REPLIES:');
      final qrEnd = cleanText.indexOf(']', qrStart);

      if (qrEnd != -1) {
        final qrContent = cleanText.substring(
          qrStart + '[QUICK_REPLIES:'.length,
          qrEnd,
        );
        quickReplies = qrContent
            .split('|')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        cleanText = cleanText
            .replaceAll(RegExp(r'\[QUICK_REPLIES:[^\]]*\]'), '')
            .trim();
      }
    }

    return AIResponse(
      text: cleanText.isNotEmpty
          ? cleanText
          : 'Kya aap aur details bata sakte hain?',
      quickReplies: quickReplies,
      assessment: assessment,
    );
  }

  Future<AIResponse> sendAnonymousMessage(String userMessage) async {
    return sendMessage('[ANONYMOUS MODE] $userMessage');
  }
}

class AIResponse {
  final String text;
  final List<String> quickReplies;
  final AssessmentData? assessment;
  final bool isError;

  AIResponse({
    required this.text,
    required this.quickReplies,
    this.assessment,
    this.isError = false,
  });

  bool get hasAssessment => assessment != null;
  bool get hasQuickReplies => quickReplies.isNotEmpty;
}

// Aliases for seamless backwards compatibility
typedef GeminiResponse = AIResponse;
typedef GeminiService = OpenAIService;
