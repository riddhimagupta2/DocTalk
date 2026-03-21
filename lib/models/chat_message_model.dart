import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MessageRole { user, ai }

enum MessageType { text, assessment, quickReply, typing }

class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final MessageType type;
  final DateTime timestamp;
  final AssessmentData? assessment;
  final List<String>? quickReplies;
  final bool isTyping;
  final bool showDoctorButton;
  final String? doctorSpecialist;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    this.type = MessageType.text,
    required this.timestamp,
    this.assessment,
    this.quickReplies,
    this.isTyping = false,
    this.showDoctorButton = false,
    this.doctorSpecialist,
  });

  factory ChatMessage.user(String content) => ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_user',
        content: content,
        role: MessageRole.user,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.ai(
    String content, {
    List<String>? quickReplies,
    bool showDoctorButton = false,
    String? doctorSpecialist,
  }) =>
      ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_ai',
        content: content,
        role: MessageRole.ai,
        type: quickReplies != null && quickReplies.isNotEmpty
            ? MessageType.quickReply
            : MessageType.text,
        timestamp: DateTime.now(),
        quickReplies: quickReplies,
        showDoctorButton: showDoctorButton,
        doctorSpecialist: doctorSpecialist,
      );

  factory ChatMessage.assessment(AssessmentData assessment) => ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_assessment',
        content: '',
        role: MessageRole.ai,
        type: MessageType.assessment,
        timestamp: DateTime.now(),
        assessment: assessment,
      );

  factory ChatMessage.typing() => ChatMessage(
        id: 'typing',
        content: '',
        role: MessageRole.ai,
        type: MessageType.typing,
        timestamp: DateTime.now(),
        isTyping: true,
      );

  Map<String, dynamic> toFirestore() => {
        'content': content,
        'role': role.name,
        'type': type.name,
        'timestamp': Timestamp.fromDate(timestamp),
      };
}

class AssessmentData {
  final List<String> likelyconditions;
  final String severity; // LOW | MEDIUM | URGENT
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

  factory AssessmentData.fromJson(Map<String, dynamic> json) => AssessmentData(
        likelyconditions: List<String>.from(json['likely_conditions'] ?? []),
        severity: (json['severity'] ?? 'MEDIUM').toString().toUpperCase(),
        severityReason: json['severity_reason'] ?? '',
        recommendedSpecialist:
            json['recommended_specialist'] ?? 'General Physician',
        homeCare: List<String>.from(json['home_care_tips'] ?? []),
        redFlags: List<String>.from(json['red_flags'] ?? []),
        disclaimer: json['disclaimer'] ??
            'Yeh ek preliminary assessment hai. Doctor se milna zaroori hai.',
      );

  Color get severityColor {
    switch (severity) {
      case 'URGENT':
        return const Color(0xFFE74C3C);
      case 'MEDIUM':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF2ECC71);
    }
  }

  String get severityLabel {
    switch (severity) {
      case 'URGENT':
        return 'Urgent';
      case 'MEDIUM':
        return 'Moderate';
      default:
        return 'Mild';
    }
  }

  String get severityEmoji {
    switch (severity) {
      case 'URGENT':
        return '🚨';
      case 'MEDIUM':
        return '⚠️';
      default:
        return '✅';
    }
  }
}


