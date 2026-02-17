import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message_model.dart';

class GeminiService {
  // ⚠️ REPLACE WITH YOUR GEMINI API KEY
  // Get free key at: https://aistudio.google.com/app/apikey
  static const String _apiKey = 'AIzaSyCb1OUAb0PwaV5X8ZYiib2ENEZnFCGshtY';

  static const String _systemPrompt = '''
You are MediSaathi, a warm, empathetic AI health assistant built specifically for Indian users.
Your role is to help users understand their symptoms through a conversational triage process — like a caring friend who happens to know a lot about medicine.

YOUR PERSONALITY:
- Warm, calm, never scary or alarming
- Speak in the same language the user writes in (Hindi, English, or Hinglish naturally)
- Never use complex medical jargon — explain everything in simple words
- Never definitively diagnose — always say "it could be" or "most likely"
- Be empathetic: "Main samajh sakta hoon yeh uncomfortable hai"
- Keep responses concise — max 3-4 lines per message

YOUR CONVERSATION FLOW:
Phase 1 — Initial Greeting (first message only):
- Greet warmly with a namaste, introduce yourself briefly
- Ask them to describe how they're feeling

Phase 2 — Symptom Collection (messages 2-4):
- After user describes symptoms, ask ONE targeted follow-up question per message
- Good follow-up questions:
  * Duration: "Yeh kab se ho raha hai? Kitne din se?"
  * Severity: "1 se 10 mein kitna dard/takleef hai?"
  * Location: "Exactly kahan feel ho raha hai?"
  * Associated symptoms: "Kya saath mein bukhar, ulti, ya chakkar bhi aa raha hai?"
  * History: "Pehle kabhi aisa hua tha? Ya family mein kisi ko aise symptoms hain?"
  * Triggers: "Kya khane ke baad ya koi kaam karne ke baad zyada hota hai?"
- ONLY ask ONE question at a time
- After the question, add a short quick reply suggestion hint like: [Reply with: Yes/No/Sometimes]

Phase 3 — Assessment (after 3-5 follow-up exchanges):
When you have enough information (at least 3 exchanges), give your assessment.
IMPORTANT: Return your assessment in this EXACT JSON format wrapped in <ASSESSMENT> tags:

<ASSESSMENT>
{
  "assessment_ready": true,
  "likely_conditions": ["Most likely condition", "Second possibility", "Third possibility"],
  "severity": "LOW",
  "severity_reason": "Why this severity level in 1-2 sentences",
  "recommended_specialist": "General Physician",
  "home_care_tips": ["Rest properly", "Stay hydrated", "Tip 3"],
  "red_flags": ["If you experience X, go to ER immediately"],
  "disclaimer": "Yeh ek preliminary assessment hai. Sahi diagnosis ke liye doctor se milna zaroori hai.",
  "summary_message": "A warm 2-3 sentence summary in user's language about what you think is happening"
}
</ASSESSMENT>

SEVERITY RULES (follow strictly):
- LOW: Can manage at home, see doctor if persists > 3 days
- MEDIUM: Should see a doctor within 24-48 hours  
- URGENT: Go to doctor/emergency room TODAY — show red alert

SPECIALIST TYPES TO USE:
"General Physician", "ENT Specialist", "Cardiologist", "Neurologist", 
"Dermatologist", "Gastroenterologist", "Orthopedic", "Pulmonologist",
"Psychiatrist", "Gynecologist", "Urologist", "Ophthalmologist"

NEVER DO:
- Suggest specific drug names or exact dosages
- Say "I cannot help with medical questions" — you CAN help, you just clarify you're not a replacement for a doctor
- Ask more than ONE question per message
- Be robotic or use bullet points in normal conversation messages
- Ignore or dismiss any symptom, no matter how minor it seems

QUICK REPLIES FORMAT:
When you want the user to pick from options, end your message with:
[QUICK_REPLIES: Option1 | Option2 | Option3]

Example: "Sar dard kahan feel ho raha hai?
[QUICK_REPLIES: Puri head mein | Ek side mein | Peche ki taraf | Aankhon ke paas]"
''';

  late final GenerativeModel _model;
  late ChatSession _chatSession;
  bool _isInitialized = false;

  GeminiService() {
    _initialize();
  }

  void _initialize() {
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(_systemPrompt),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 1024,
        ),
      );
      _startNewSession();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Gemini initialization error: $e');
    }
  }

  void _startNewSession() {
    _chatSession = _model.startChat();
  }

  void resetSession() {
    _startNewSession();
  }

  Future<GeminiResponse> sendMessage(String userMessage) async {
    if (!_isInitialized) {
      return GeminiResponse(
        text: 'Sorry, AI service is not available right now. Please check your API key.',
        quickReplies: [],
        assessment: null,
      );
    }

    try {
      final response = await _chatSession.sendMessage(
        Content.text(userMessage),
      );

      final rawText = response.text ?? '';
      return _parseResponse(rawText);
    } catch (e) {
      debugPrint('Gemini API error: $e');
      return GeminiResponse(
        text: 'Maafi chahta hoon, thoda technical problem aa gaya. Kya aap dobara try karenge? 🙏',
        quickReplies: [],
        assessment: null,
      );
    }
  }

  GeminiResponse _parseResponse(String rawText) {
    AssessmentData? assessment;
    List<String> quickReplies = [];
    String cleanText = rawText;

    // Check for assessment JSON
    if (rawText.contains('<ASSESSMENT>') && rawText.contains('</ASSESSMENT>')) {
      final start = rawText.indexOf('<ASSESSMENT>') + '<ASSESSMENT>'.length;
      final end = rawText.indexOf('</ASSESSMENT>');
      final jsonStr = rawText.substring(start, end).trim();

      try {
        final jsonData = jsonDecode(jsonStr);
        if (jsonData['assessment_ready'] == true) {
          assessment = AssessmentData.fromJson(jsonData);
          cleanText = jsonData['summary_message'] ?? 'Aapki assessment tayaar hai. Please neeche dekho.';
        }
      } catch (e) {
        debugPrint('Assessment parse error: $e');
      }

      // Remove the JSON block from display text
      cleanText = cleanText
          .replaceAll(RegExp(r'<ASSESSMENT>.*?</ASSESSMENT>', dotAll: true), '')
          .trim();
    }

    // Check for quick replies
    if (rawText.contains('[QUICK_REPLIES:')) {
      final qrStart = rawText.indexOf('[QUICK_REPLIES:');
      final qrEnd = rawText.indexOf(']', qrStart);
      if (qrEnd != -1) {
        final qrContent = rawText.substring(
          qrStart + '[QUICK_REPLIES:'.length,
          qrEnd,
        );
        quickReplies = qrContent.split('|').map((s) => s.trim()).toList();
        cleanText = cleanText
            .replaceAll(RegExp(r'\[QUICK_REPLIES:.*?\]'), '')
            .trim();
      }
    }

    return GeminiResponse(
      text: cleanText.isNotEmpty ? cleanText : 'Kya aap aur details bata sakte hain?',
      quickReplies: quickReplies,
      assessment: assessment,
    );
  }
}

class GeminiResponse {
  final String text;
  final List<String> quickReplies;
  final AssessmentData? assessment;

  GeminiResponse({
    required this.text,
    required this.quickReplies,
    this.assessment,
  });

  bool get hasAssessment => assessment != null;
  bool get hasQuickReplies => quickReplies.isNotEmpty;
}

// ignore: non_constant_identifier_names
void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}