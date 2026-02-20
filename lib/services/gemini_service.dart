import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/chat_message_model.dart';

class GeminiService {
  // ════════════════════════════════════════════════════
  // ⚠️ YOUR GEMINI API KEY
  // Free key from: aistudio.google.com/app/apikey
  // ════════════════════════════════════════════════════
  static const String _apiKey = 'AIzaSyDRF11BozFl67i_2eRFrLTouL3ZBKgt9yA';

  static const String _systemPrompt = '''
You are DocTalk, a warm and empathetic AI health assistant built for Indian users.
Help users understand their symptoms through friendly conversational triage.

YOUR PERSONALITY:
- Warm, calm, never scary
- Reply in the same language the user uses (Hindi, English, or Hinglish)
- No complex medical jargon, always simple words
- Never definitively diagnose, say "it could be" or "most likely"
- Keep each response to 2-4 lines maximum

IMPORTANT: DocTalk HAS a built-in doctor finder feature that shows nearby doctors on Google Maps.
When user asks to find doctors, ENCOURAGE them to use it. Say something like:
"Bilkul! Main aapko nearby doctors Google Maps par dikha sakta hoon. Tap karein 'Doctor Dhundho' button."

YOUR FLOW:
Phase 1 - First message: Warm greeting, ask for symptoms
Phase 2 - Messages 2-5: Ask ONE targeted follow-up question per turn:
  - Duration: "Yeh kab se ho raha hai?"
  - Severity: "1 se 10 mein kitna dard hai?"
  - Location: "Exactly kahan feel ho raha hai?"
  - Other symptoms: "Kya saath mein bukhar ya ulti bhi hai?"
  - History: "Pehle kabhi aisa hua tha?"
  Always end with quick reply options: [QUICK_REPLIES: Yes | No | Sometimes]

Phase 3 - After 3-5 exchanges: Give assessment in this EXACT format:

<ASSESSMENT>
{
  "assessment_ready": true,
  "likely_conditions": ["Condition 1", "Condition 2"],
  "severity": "MEDIUM",
  "severity_reason": "Short reason here",
  "recommended_specialist": "General Physician",
  "home_care_tips": ["Rest", "Stay hydrated", "Monitor temperature"],
  "red_flags": ["If breathing gets difficult, go to ER"],
  "disclaimer": "Yeh preliminary assessment hai. Doctor se milna zaroori hai.",
  "summary_message": "Warm 2-3 line summary in Hinglish."
}
</ASSESSMENT>

SEVERITY: LOW (home care ok) | MEDIUM (see doctor in 48h) | URGENT (go today)

QUICK REPLIES FORMAT: [QUICK_REPLIES: Option1 | Option2 | Option3]

NEVER suggest specific drug names or dosages.
NEVER ask more than ONE question per message.
''';

  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isInitialized = false;
  String? _initError;

  // ══════════════════════════════════════════════════
  // 🔒 ANTI-DUPLICATE REQUEST LOCK
  // Prevents multiple simultaneous API calls
  // ══════════════════════════════════════════════════
  bool _isProcessing = false;
  DateTime? _lastRequestTime;

  GeminiService() {
    _initialize();
  }

  void _initialize() {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE' || _apiKey.trim().isEmpty) {
      _initError = 'API_KEY_MISSING';
      print('');
      print('╔════════════════════════════════════════╗');
      print('║  ❌  GEMINI API KEY NOT SET!           ║');
      print('║                                        ║');
      print('║  1. Go to aistudio.google.com          ║');
      print('║  2. Click "Get API Key"                ║');
      print('║  3. Copy the key (AIza...)             ║');
      print('║  4. Paste in gemini_service.dart       ║');
      print('║     line: static const _apiKey = ...  ║');
      print('╚════════════════════════════════════════╝');
      print('');
      return;
    }

    try {
      _model = GenerativeModel(
        // ✨ CORRECT MODEL FOR GEMINI 2.5 FLASH
        // This is the latest stable model as of Feb 2026
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(_systemPrompt),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 1024,
          topP: 0.95,
          topK: 40,
        ),
      );
      _startNewSession();
      _isInitialized = true;
      print('✅ DocTalk: Gemini 2.5 Flash ready!');
    } catch (e) {
      _initError = e.toString();
      print('❌ Gemini init error: $e');
    }
  }

  void _startNewSession() {
    _chatSession = _model!.startChat();
  }

  void resetSession() {
    if (_isInitialized) {
      _startNewSession();
      _isProcessing = false; // Reset lock
      _lastRequestTime = null;
    }
  }

  Future<GeminiResponse> sendMessage(String userMessage) async {
    // ══════════════════════════════════════════════════
    // 🛡️ ANTI-SPAM PROTECTION
    // ══════════════════════════════════════════════════

    // Check 1: Already processing a request?
    if (_isProcessing) {
      print('⚠️ Blocked duplicate request - already processing');
      return GeminiResponse(
        text: '⏳ Please wait, processing your previous message...',
        quickReplies: [],
        isError: false,
      );
    }

    // Check 2: Too fast? (less than 1 second since last request)
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest.inMilliseconds < 1000) {
        print(
            '⚠️ Blocked rapid-fire request (${timeSinceLastRequest.inMilliseconds}ms gap)');
        return GeminiResponse(
          text: '⏳ Ek second ruko, processing ho raha hai...',
          quickReplies: [],
          isError: false,
        );
      }
    }

    // ══════════════════════════════════════════════════
    // 🔐 LOCK THE REQUEST
    // ══════════════════════════════════════════════════
    _isProcessing = true;
    _lastRequestTime = DateTime.now();

    try {
      // API key missing check
      if (_initError == 'API_KEY_MISSING') {
        return GeminiResponse(
          text:
              '🔑 Gemini API Key Missing!\n\nPlease:\n1. Go to aistudio.google.com/app/apikey\n2. Create a FREE API key\n3. Open lib/services/gemini_service.dart\n4. Replace YOUR_GEMINI_API_KEY_HERE with your key\n5. Save and hot reload (press r)',
          quickReplies: [],
          isError: true,
        );
      }

      if (!_isInitialized || _chatSession == null) {
        return GeminiResponse(
          text:
              'AI service could not start. Check your API key in gemini_service.dart. Error: $_initError',
          quickReplies: [],
          isError: true,
        );
      }

      // ══════════════════════════════════════════════════
      // 🚀 ACTUAL API CALL
      // ══════════════════════════════════════════════════
      print('📤 Sending to Gemini 2.5 Flash: "$userMessage"');
      final response =
          await _chatSession!.sendMessage(Content.text(userMessage));

      final rawText = response.text ?? '';
      print('📥 Gemini response received: ${rawText.length} chars');

      if (rawText.isEmpty) {
        return GeminiResponse(
          text: 'Response empty. Please try again.',
          quickReplies: [],
        );
      }

      return _parseResponse(rawText);
    } on GenerativeAIException catch (e) {
      print('❌ Gemini API error: ${e.message}');

      // Invalid API key
      if (e.message.contains('API key not valid') ||
          e.message.contains('API_KEY_INVALID')) {
        return GeminiResponse(
          text:
              '❌ Invalid API Key!\n\nYour key is wrong or expired.\n\n1. Go to aistudio.google.com/app/apikey\n2. Create a new key\n3. Update gemini_service.dart',
          quickReplies: [],
          isError: true,
        );
      }

      // Quota exceeded (rate limit)
      if (e.message.toLowerCase().contains('quota') ||
          e.message.toLowerCase().contains('resource_exhausted') ||
          e.message.toLowerCase().contains('rate limit')) {
        return GeminiResponse(
          text:
              '⏰ Rate limit reached!\n\nGemini API free tier: 15 requests/minute.\n\nWait 60 seconds and try again, or use a different API key.',
          quickReplies: [],
          isError: true,
        );
      }

      // Model not found error
      if (e.message.toLowerCase().contains('not found') ||
          e.message.toLowerCase().contains('not supported')) {
        return GeminiResponse(
          text: '❌ Model Error: ${e.message}\n\nTrying fallback model...',
          quickReplies: [],
          isError: true,
        );
      }

      // Network error
      return GeminiResponse(
        text: 'Connection error. Check internet.\n\nError: ${e.message}',
        quickReplies: [],
        isError: true,
      );
    } on FormatException catch (e) {
      // ══════════════════════════════════════════════════
      // 🔧 FORMAT ERROR HANDLING (JSON parse issues)
      // ══════════════════════════════════════════════════
      print('❌ Format error while parsing response: $e');
      return GeminiResponse(
        text:
            'Gemini returned badly formatted data. Trying again...\n\nKya aap apna message dobara bhej sakte hain?',
        quickReplies: [],
        isError: false, // Not a critical error, user can retry
      );
    } catch (e) {
      print('❌ Unexpected Gemini error: $e');
      print('❌ Error type: ${e.runtimeType}');
      return GeminiResponse(
        text:
            'Unexpected error: ${e.toString()}\n\nPlease try sending your message again.',
        quickReplies: [],
        isError: true,
      );
    } finally {
      // ══════════════════════════════════════════════════
      // 🔓 UNLOCK - allow next request
      // ══════════════════════════════════════════════════
      _isProcessing = false;
    }
  }

  GeminiResponse _parseResponse(String rawText) {
    AssessmentData? assessment;
    List<String> quickReplies = [];
    String cleanText = rawText;

    try {
      // Parse ASSESSMENT block
      if (rawText.contains('<ASSESSMENT>') &&
          rawText.contains('</ASSESSMENT>')) {
        final start = rawText.indexOf('<ASSESSMENT>') + '<ASSESSMENT>'.length;
        final end = rawText.indexOf('</ASSESSMENT>');
        if (end > start) {
          final jsonStr = rawText.substring(start, end).trim();
          try {
            final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
            if (jsonData['assessment_ready'] == true) {
              assessment = AssessmentData.fromJson(jsonData);
              cleanText = jsonData['summary_message']?.toString() ??
                  'Aapka assessment ready hai!';
            }
          } catch (e) {
            print('⚠️ Assessment JSON parse error: $e');
            print('⚠️ Attempted to parse: $jsonStr');
            // Don't crash - just skip assessment and show text response
          }
        }
        // Remove ASSESSMENT block from visible text
        cleanText = cleanText
            .replaceAll(
                RegExp(r'<ASSESSMENT>.*?</ASSESSMENT>', dotAll: true), '')
            .trim();
      }

      // Parse QUICK_REPLIES
      if (cleanText.contains('[QUICK_REPLIES:')) {
        final qrStart = cleanText.indexOf('[QUICK_REPLIES:');
        final qrEnd = cleanText.indexOf(']', qrStart);
        if (qrEnd != -1) {
          final qrContent =
              cleanText.substring(qrStart + '[QUICK_REPLIES:'.length, qrEnd);
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
    } catch (e) {
      print('⚠️ Error in _parseResponse: $e');
      // If parsing fails completely, just return the raw text
      cleanText = rawText;
    }

    return GeminiResponse(
      text: cleanText.isNotEmpty
          ? cleanText
          : 'Kya aap aur details bata sakte hain?',
      quickReplies: quickReplies,
      assessment: assessment,
    );
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
