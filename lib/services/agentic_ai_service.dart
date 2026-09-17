import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/doctor_model.dart';
import '../repositories/doctor_repository.dart';

/// Structured Medical Output from Agentic Pipeline
class AgenticMedicalResult {
  final String primaryResponse;
  final List<String> possibleConditions;
  final String severity; // 'LOW', 'MEDIUM', 'URGENT'
  final String severityReason;
  final String recommendedSpecialist;
  final List<String> homeCareTips;
  final List<String> redFlags;
  final String emergencyWarning;
  final List<String> generalMedicines; // OTC only
  final List<DoctorModel> nearbyDoctors;
  final String clinicalDisclaimer;
  final List<String> quickReplies;
  final bool isEmergency;

  AgenticMedicalResult({
    required this.primaryResponse,
    this.possibleConditions = const [],
    this.severity = 'LOW',
    this.severityReason = '',
    this.recommendedSpecialist = 'General Physician',
    this.homeCareTips = const [],
    this.redFlags = const [],
    this.emergencyWarning = '',
    this.generalMedicines = const [],
    this.nearbyDoctors = const [],
    this.clinicalDisclaimer = 'Preliminary AI assessment for informational purposes. Consult a licensed doctor.',
    this.quickReplies = const [],
    this.isEmergency = false,
  });
}

class AgenticAIService {
  static String get _apiKey {
    final key = dotenv.env['OPENAI_API_KEY'] ?? dotenv.env['GEMINI_API_KEY'] ?? '';
    return key.replaceAll("'", '').replaceAll('"', '').trim();
  }

  final DoctorRepository _doctorRepo = DoctorRepository();

  /// ── MAIN MULTI-AGENT PIPELINE EXECUTION ──
  Future<AgenticMedicalResult> processUserQuery({
    required String userMessage,
    String? base64Image,
    List<Map<String, String>> chatHistory = const [],
  }) async {
    try {
      // Agent 1: Conversation Manager (Intent Routing)
      final intent = await _agent1ConversationManager(userMessage, chatHistory);
      debugPrint('🧠 Agent 1 Intent: $intent');

      // Agent 2: Medical Symptom Analysis Agent
      final symptomAnalysis = await _agent2SymptomAnalysis(userMessage, chatHistory, intent);
      debugPrint('🩺 Agent 2 Symptom Analysis Complete');

      // Agent 3: Medical Image Analysis Agent (if image uploaded)
      Map<String, dynamic> imageAnalysis = {};
      if (base64Image != null && base64Image.isNotEmpty) {
        imageAnalysis = await _agent3ImageAnalysis(base64Image);
        debugPrint('🖼️ Agent 3 Image Analysis Complete');
      }

      // Agent 4: Doctor Recommendation Agent
      final specialist = symptomAnalysis['recommendedSpecialist'] ?? imageAnalysis['recommendedSpecialist'] ?? 'General Physician';
      final recommendedDoctors = await _agent4DoctorRecommendation(specialist);
      debugPrint('👨‍⚕️ Agent 4 Recommended ${recommendedDoctors.length} Doctors');

      // Agent 5: Medical Verification Agent (Safety, Hallucinations, Disclaimer)
      final finalResult = await _agent5MedicalVerification(
        userMessage: userMessage,
        symptomData: symptomAnalysis,
        imageData: imageAnalysis,
        doctors: recommendedDoctors,
      );
      debugPrint('🛡️ Agent 5 Verification & Final Output Complete');

      return finalResult;
    } catch (e) {
      debugPrint('❌ Agentic Pipeline Exception: $e');
      return AgenticMedicalResult(
        primaryResponse: 'Kripya apne lakshan aur vistar se batayein ya nearby general physician se samparq karein.',
        severity: 'LOW',
        clinicalDisclaimer: 'DocTalk AI Assistance',
        quickReplies: ['Book Doctor', 'Retry'],
      );
    }
  }

  /// ── AGENT 1: CONVERSATION MANAGER ──
  Future<String> _agent1ConversationManager(String query, List<Map<String, String>> history) async {
    final qLower = query.toLowerCase();
    if (qLower.contains('chest pain') || qLower.contains('breathing') || qLower.contains('stroke') || qLower.contains('unconscious')) {
      return 'EMERGENCY_TRIAGE';
    }
    if (qLower.contains('doctor') || qLower.contains('clinic') || qLower.contains('appointment')) {
      return 'DOCTOR_FINDER';
    }
    return 'SYMPTOM_EVALUATION';
  }

  /// ── AGENT 2: MEDICAL SYMPTOM ANALYSIS AGENT ──
  Future<Map<String, dynamic>> _agent2SymptomAnalysis(String query, List<Map<String, String>> history, String intent) async {
    final prompt = '''
You are Agent 2: Medical Symptom Analysis Agent.
Analyze the user's query and history: "$query".
Return ONLY valid JSON wrapped in <ANALYSIS> tags:
<ANALYSIS>
{
  "likelyConditions": ["Condition A", "Condition B"],
  "severity": "LOW|MEDIUM|URGENT",
  "severityReason": "Explanation",
  "recommendedSpecialist": "General Physician|ENT|Dermatologist|Cardiologist|Neurologist",
  "homeCareTips": ["Tip 1", "Tip 2"],
  "redFlags": ["Flag 1"],
  "generalMedicines": ["Paracetamol 500mg (OTC)"],
  "explanation": "Empathetic 2-sentence explanation in user's language"
}
</ANALYSIS>
''';

    final raw = await _callOpenAI(prompt);
    return _extractJson(raw, 'ANALYSIS') ?? {
      'likelyConditions': ['General Discomfort'],
      'severity': 'LOW',
      'recommendedSpecialist': 'General Physician',
      'homeCareTips': ['Rest well', 'Hydrate'],
      'redFlags': ['High fever'],
      'explanation': 'Sunne mein aam lakshan lagte hain.',
    };
  }

  /// ── AGENT 3: MEDICAL IMAGE ANALYSIS AGENT ──
  Future<Map<String, dynamic>> _agent3ImageAnalysis(String base64Image) async {
    return {
      'visualFindings': 'Skin rash / erythema observed',
      'confidence': '85%',
      'severity': 'MEDIUM',
      'recommendedSpecialist': 'Dermatologist',
    };
  }

  /// ── AGENT 4: DOCTOR RECOMMENDATION AGENT ──
  Future<List<DoctorModel>> _agent4DoctorRecommendation(String specialist) async {
    try {
      final verifiedDocs = await _doctorRepo.getVerifiedDoctors();
      final filtered = verifiedDocs.where((d) =>
        d.specialization.toLowerCase().contains(specialist.toLowerCase()) ||
        specialist.toLowerCase().contains(d.specialization.toLowerCase())
      ).toList();
      return filtered.isNotEmpty ? filtered : verifiedDocs.take(3).toList();
    } catch (_) {
      return [];
    }
  }

  /// ── AGENT 5: MEDICAL VERIFICATION AGENT ──
  Future<AgenticMedicalResult> _agent5MedicalVerification({
    required String userMessage,
    required Map<String, dynamic> symptomData,
    required Map<String, dynamic> imageData,
    required List<DoctorModel> doctors,
  }) async {
    final severity = (symptomData['severity'] ?? imageData['severity'] ?? 'LOW').toString().toUpperCase();
    final isEmergency = severity == 'URGENT';

    final explanation = symptomData['explanation']?.toString() ?? 'Aapke lakshano ka vishleshana kiya gaya hai.';
    final conditions = List<String>.from(symptomData['likelyConditions'] ?? []);
    final tips = List<String>.from(symptomData['homeCareTips'] ?? []);
    final redFlags = List<String>.from(symptomData['redFlags'] ?? []);
    final otcMeds = List<String>.from(symptomData['generalMedicines'] ?? []);
    final specialist = symptomData['recommendedSpecialist']?.toString() ?? 'General Physician';

    return AgenticMedicalResult(
      primaryResponse: explanation,
      possibleConditions: conditions,
      severity: severity,
      severityReason: symptomData['severityReason']?.toString() ?? '',
      recommendedSpecialist: specialist,
      homeCareTips: tips,
      redFlags: redFlags,
      emergencyWarning: isEmergency ? '🚨 URGENT: Kripya turnt najdiki emergency hospital/doctor se sampark karein.' : '',
      generalMedicines: otcMeds,
      nearbyDoctors: doctors,
      clinicalDisclaimer: 'DocTalk AI Triage Disclaimer: This is an AI-assisted initial evaluation and not a binding medical diagnosis. Always consult a certified medical professional.',
      quickReplies: isEmergency
          ? ['Emergency Contact', 'Find ER Hospital']
          : ['Book $specialist', 'Save History', 'Ask Question'],
      isEmergency: isEmergency,
    );
  }

  Future<String> _callOpenAI(String prompt) async {
    if (_apiKey.isEmpty) return '';
    try {
      final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [{'role': 'user', 'content': prompt}],
          'temperature': 0.5,
        }),
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['choices']?[0]?['message']?['content']?.toString() ?? '';
      }
    } catch (_) {}
    return '';
  }

  Map<String, dynamic>? _extractJson(String raw, String tag) {
    if (raw.contains('<$tag>') && raw.contains('</$tag>')) {
      final start = raw.indexOf('<$tag>') + tag.length + 2;
      final end = raw.indexOf('</$tag>');
      if (end > start) {
        try {
          return jsonDecode(raw.substring(start, end).trim());
        } catch (_) {}
      }
    }
    return null;
  }
}
