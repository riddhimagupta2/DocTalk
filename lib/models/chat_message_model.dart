import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageRole { user, ai }
enum MessageType { text, assessment, quickReply, doctorList, typing }

class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final MessageType type;
  final DateTime timestamp;
  final AssessmentData? assessment;
  final List<String>? quickReplies;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    this.type = MessageType.text,
    required this.timestamp,
    this.assessment,
    this.quickReplies,
    this.isTyping = false,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.user,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.ai(String content, {List<String>? quickReplies}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.ai,
      type: quickReplies != null ? MessageType.quickReply : MessageType.text,
      timestamp: DateTime.now(),
      quickReplies: quickReplies,
    );
  }

  factory ChatMessage.assessment(AssessmentData assessment) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '',
      role: MessageRole.ai,
      type: MessageType.assessment,
      timestamp: DateTime.now(),
      assessment: assessment,
    );
  }

  factory ChatMessage.typing() {
    return ChatMessage(
      id: 'typing',
      content: '',
      role: MessageRole.ai,
      type: MessageType.typing,
      timestamp: DateTime.now(),
      isTyping: true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'role': role.name,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class AssessmentData {
  final List<String> likelyconditions;
  final String severity; // LOW, MEDIUM, URGENT
  final String severityReason;
  final String recommendedSpecialist;
  final List<String> homeCare;
  final List<String> redFlags;
  final String disclaimer;

  AssessmentData({
    required this.likelyconditions,
    required this.severity,
    required this.severityReason,
    required this.recommendedSpecialist,
    required this.homeCare,
    required this.redFlags,
    required this.disclaimer,
  });

  factory AssessmentData.fromJson(Map<String, dynamic> json) {
    return AssessmentData(
      likelyconditions: List<String>.from(json['likely_conditions'] ?? []),
      severity: json['severity'] ?? 'MEDIUM',
      severityReason: json['severity_reason'] ?? '',
      recommendedSpecialist: json['recommended_specialist'] ?? 'General Physician',
      homeCare: List<String>.from(json['home_care_tips'] ?? []),
      redFlags: List<String>.from(json['red_flags'] ?? []),
      disclaimer: json['disclaimer'] ?? 'This is a preliminary assessment. Please consult a doctor.',
    );
  }
}