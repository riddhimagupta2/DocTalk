import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message_model.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

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

  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isInitialized = false;
  String? _initError;
  int _messageCount = 0;

  bool _isProcessing = false;
  DateTime? _lastRequestTime;

  GeminiService() {
    _initialize();
  }

  void _initialize() {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE' || _apiKey.trim().isEmpty) {
      _initError = 'API_KEY_MISSING';
      print('GEMINI API KEY NOT SET!');
      return;
    }

    try {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(_systemPrompt),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 2048,
          topP: 0.95,
          topK: 40,
        ),
      );
      _startNewSession();
      _isInitialized = true;
      print('✅ DocTalk: Gemini AI ready!');
    } catch (e) {
      _initError = e.toString();
      print('Gemini init error: $e');
    }
  }

  void _startNewSession() {
    _chatSession = _model!.startChat();
    _messageCount = 0;
  }

  void resetSession() {
    if (_isInitialized) {
      _startNewSession();
      _isProcessing = false;
      _lastRequestTime = null;
    }
  }

  Future<GeminiResponse> sendMessage(String userMessage) async {
    if (_isProcessing) {
      print('⚠️ Blocked duplicate request');
      return GeminiResponse(
        text: '⏳ Please wait, processing...',
        quickReplies: [],
        isError: false,
      );
    }

    if (_lastRequestTime != null) {
      final gap = DateTime.now().difference(_lastRequestTime!);
      if (gap.inMilliseconds < 1000) {
        print('⚠️ Blocked rapid request (${gap.inMilliseconds}ms)');
        return GeminiResponse(
          text: '⏳ Ek second ruko...',
          quickReplies: [],
          isError: false,
        );
      }
    }

    _isProcessing = true;
    _lastRequestTime = DateTime.now();

    try {
      if (_initError == 'API_KEY_MISSING') {
        return GeminiResponse(
          text:
              '🔑 Gemini API Key Missing!\n\nSet your key in gemini_service.dart',
          quickReplies: [],
          isError: true,
        );
      }

      if (!_isInitialized || _chatSession == null) {
        return GeminiResponse(
          text: 'AI service not available. Error: $_initError',
          quickReplies: [],
          isError: true,
        );
      }

      _messageCount++;
      print('📤 Message #$_messageCount: "$userMessage"');

      String promptMessage = userMessage;
      if (_messageCount >= 4) {
        promptMessage =
            '$userMessage\n\n[SYSTEM: You now have enough information. Provide the assessment in <ASSESSMENT> JSON format.]';
        print('🎯 Forcing assessment generation (message #$_messageCount)');
      }

      final response =
          await _chatSession!.sendMessage(Content.text(promptMessage));
      final rawText = response.text ?? '';

      print('📥 Response received: ${rawText.length} chars');

      if (rawText.isEmpty) {
        return GeminiResponse(
          text: 'Empty response. Please try again.',
          quickReplies: [],
        );
      }

      return _parseResponse(rawText);
    } on GenerativeAIException catch (e) {
      print('Gemini API error: ${e.message}');

      if (e.message.contains('API key not valid') ||
          e.message.contains('API_KEY_INVALID')) {
        return GeminiResponse(
          text: 'Invalid API Key!\n\nYour key is wrong or expired.',
          quickReplies: [],
          isError: true,
        );
      }

      if (e.message.toLowerCase().contains('quota') ||
          e.message.toLowerCase().contains('resource_exhausted')) {
        return GeminiResponse(
          text: '⏰ Rate limit reached! Wait 60 seconds.',
          quickReplies: [],
          isError: true,
        );
      }

      if (e.message.toLowerCase().contains('not found')) {
        return GeminiResponse(
          text: 'Model not found. Try gemini-1.5-flash instead.',
          quickReplies: [],
          isError: true,
        );
      }

      return GeminiResponse(
        text: 'Connection error: ${e.message}',
        quickReplies: [],
        isError: true,
      );
    } on FormatException catch (e) {
      print('Format error: $e');
      return GeminiResponse(
        text: 'Response format error. Please try again.',
        quickReplies: [],
        isError: false,
      );
    } catch (e) {
      print('Unexpected error: $e');
      return GeminiResponse(
        text: 'Unexpected error: $e',
        quickReplies: [],
        isError: true,
      );
    } finally {
      _isProcessing = false;
    }
  }

  GeminiResponse _parseResponse(String rawText) {
    AssessmentData? assessment;
    List<String> quickReplies = [];
    String cleanText = rawText;

    if (rawText.contains('<ASSESSMENT>') && rawText.contains('</ASSESSMENT>')) {
      final start = rawText.indexOf('<ASSESSMENT>') + '<ASSESSMENT>'.length;
      final end = rawText.indexOf('</ASSESSMENT>');

      if (end > start) {
        final jsonStr = rawText.substring(start, end).trim();
        print('📋 Found assessment JSON: ${jsonStr.substring(0, 100)}...');

        try {
          final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;

          if (jsonData['assessment_ready'] == true) {
            assessment = AssessmentData.fromJson(jsonData);
            cleanText = jsonData['summary_message']?.toString() ??
                'Aapka health assessment ready hai. Neeche dekho.';
            print('✅ Assessment parsed successfully!');
          }
        } catch (e) {
          print('Assessment parse error: $e');
          print('JSON was: $jsonStr');
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

    return GeminiResponse(
      text: cleanText.isNotEmpty
          ? cleanText
          : 'Kya aap aur details bata sakte hain?',
      quickReplies: quickReplies,
      assessment: assessment,
    );
  }

  Future<GeminiResponse> sendAnonymousMessage(String userMessage) async {
    return sendMessage('[ANONYMOUS MODE] $userMessage');
  }
}

class GeminiResponse {
  final String text;
  final List<String> quickReplies;
  final AssessmentData? assessment;
  final bool isError;

  GeminiResponse({
    required this.text,
    required this.quickReplies,
    this.assessment,
    this.isError = false,
  });

  bool get hasAssessment => assessment != null;

  bool get hasQuickReplies => quickReplies.isNotEmpty;
}
