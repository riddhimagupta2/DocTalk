import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctalk/resources/AppTheme.dart';

class PossibleCondition {
  final String name;
  final String likelihood;

  PossibleCondition({
    required this.name,
    required this.likelihood,
  });

  factory PossibleCondition.fromJson(Map<String, dynamic> json) {
    return PossibleCondition(
      name: json['name'] as String? ?? '',
      likelihood: json['likelihood'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'likelihood': likelihood,
    };
  }

  Color get likelihoodColor {
    final lowerLikelihood = likelihood.toLowerCase();
    if (lowerLikelihood.contains('likely') && !lowerLikelihood.contains('less')) {
      return AppColors.error;
    } else if (lowerLikelihood.contains('possible')) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }
}

class ImageAnalysisResult {
  final String id;
  final String imageUrl;
  final String storagePath;
  final String status;
  final List<PossibleCondition> possibleConditions;
  final String confidence;
  final String severity;
  final List<String> recommendations;
  final List<String> firstAid;
  final List<String> redFlags;
  final String doctorSpeciality;
  final String disclaimer;
  final bool emergencyDetected;
  final String imageQuality;
  final String whenToVisitDoctor;
  final List<String> possibleCauses;
  final String? symptoms;
  final int? age;
  final String? gender;
  final String? errorMessage;
  final int processingTimeMs;
  final String aiModelVersion;
  final String promptVersion;
  final DateTime createdAt;

  ImageAnalysisResult({
    required this.id,
    required this.imageUrl,
    required this.storagePath,
    required this.status,
    required this.possibleConditions,
    required this.confidence,
    required this.severity,
    required this.recommendations,
    required this.firstAid,
    required this.redFlags,
    required this.doctorSpeciality,
    required this.disclaimer,
    required this.emergencyDetected,
    required this.imageQuality,
    required this.whenToVisitDoctor,
    required this.possibleCauses,
    this.symptoms,
    this.age,
    this.gender,
    this.errorMessage,
    required this.processingTimeMs,
    required this.aiModelVersion,
    required this.promptVersion,
    required this.createdAt,
  });

  factory ImageAnalysisResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ImageAnalysisResult(
      id: doc.id,
      imageUrl: data['imageUrl'] as String? ?? '',
      storagePath: data['storagePath'] as String? ?? '',
      status: data['status'] as String? ?? '',
      possibleConditions: (data['possibleConditions'] as List<dynamic>?)
              ?.map((e) => PossibleCondition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      confidence: data['confidence'] as String? ?? 'Low',
      severity: data['severity'] as String? ?? 'Low',
      recommendations: List<String>.from(data['recommendations'] ?? []),
      firstAid: List<String>.from(data['firstAid'] ?? []),
      redFlags: List<String>.from(data['redFlags'] ?? []),
      doctorSpeciality: data['doctorSpeciality'] as String? ?? '',
      disclaimer: data['disclaimer'] as String? ?? '',
      emergencyDetected: data['emergencyDetected'] as bool? ?? false,
      imageQuality: data['imageQuality'] as String? ?? '',
      whenToVisitDoctor: data['whenToVisitDoctor'] as String? ?? '',
      possibleCauses: List<String>.from(data['possibleCauses'] ?? []),
      symptoms: data['symptoms'] as String?,
      age: data['age'] as int?,
      gender: data['gender'] as String?,
      errorMessage: data['errorMessage'] as String?,
      processingTimeMs: data['processingTimeMs'] as int? ?? 0,
      aiModelVersion: data['aiModelVersion'] as String? ?? '',
      promptVersion: data['promptVersion'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ImageAnalysisResult.fromJson(Map<String, dynamic> data) {
    // Handle data wrapped in { "data": {...} } envelope if present
    final map = data.containsKey('data') && data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;

    final rawConditions = map['possible_conditions'] ?? map['possibleConditions'];
    final conditions = (rawConditions is List)
        ? rawConditions
            .map((e) => PossibleCondition.fromJson(e as Map<String, dynamic>))
            .toList()
        : <PossibleCondition>[];

    return ImageAnalysisResult(
      id: map['id']?.toString() ?? '',
      imageUrl: (map['image_url'] ?? map['imageUrl'])?.toString() ?? '',
      storagePath: (map['storage_path'] ?? map['storagePath'])?.toString() ?? '',
      status: (map['status'] ?? 'completed').toString(),
      possibleConditions: conditions,
      confidence: (map['confidence'] ?? 'Low').toString(),
      severity: (map['severity'] ?? 'Low').toString(),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      firstAid: List<String>.from(map['first_aid'] ?? map['firstAid'] ?? []),
      redFlags: List<String>.from(map['red_flags'] ?? map['redFlags'] ?? []),
      doctorSpeciality: (map['doctor_speciality'] ?? map['doctorSpeciality'])?.toString() ?? 'General Physician',
      disclaimer: (map['disclaimer'] ??
              'This analysis is AI generated and is not a medical diagnosis. Please consult a licensed doctor.')
          .toString(),
      emergencyDetected: map['emergency_detected'] == true ||
          map['emergencyDetected'] == true ||
          (map['severity']?.toString().toLowerCase() == 'emergency'),
      imageQuality: (map['image_quality'] ?? map['imageQuality'])?.toString() ?? 'good',
      whenToVisitDoctor: (map['when_to_visit_doctor'] ?? map['whenToVisitDoctor'])?.toString() ?? '',
      possibleCauses: List<String>.from(map['possible_causes'] ?? map['possibleCauses'] ?? []),
      symptoms: map['symptoms']?.toString(),
      age: map['age'] is int ? map['age'] as int : int.tryParse(map['age']?.toString() ?? ''),
      gender: map['gender']?.toString(),
      errorMessage: (map['error_message'] ?? map['errorMessage'])?.toString(),
      processingTimeMs: map['processing_time_ms'] is int
          ? map['processing_time_ms'] as int
          : (map['processingTimeMs'] is int ? map['processingTimeMs'] as int : 0),
      aiModelVersion: (map['ai_model_version'] ?? map['aiModelVersion'])?.toString() ?? 'gpt-4o-mini',
      promptVersion: (map['prompt_version'] ?? map['promptVersion'])?.toString() ?? '1.0.0',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  factory ImageAnalysisResult.fromCallableResponse(Map<String, dynamic> data) =>
      ImageAnalysisResult.fromJson(data);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'storage_path': storagePath,
      'status': status,
      'possible_conditions': possibleConditions.map((e) => e.toJson()).toList(),
      'confidence': confidence,
      'severity': severity,
      'recommendations': recommendations,
      'first_aid': firstAid,
      'red_flags': redFlags,
      'doctor_speciality': doctorSpeciality,
      'disclaimer': disclaimer,
      'emergency_detected': emergencyDetected,
      'image_quality': imageQuality,
      'when_to_visit_doctor': whenToVisitDoctor,
      'possible_causes': possibleCauses,
      'symptoms': symptoms,
      'age': age,
      'gender': gender,
      'error_message': errorMessage,
      'processing_time_ms': processingTimeMs,
      'ai_model_version': aiModelVersion,
      'prompt_version': promptVersion,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'status': status,
      'possibleConditions': possibleConditions.map((e) => e.toJson()).toList(),
      'confidence': confidence,
      'severity': severity,
      'recommendations': recommendations,
      'firstAid': firstAid,
      'redFlags': redFlags,
      'doctorSpeciality': doctorSpeciality,
      'disclaimer': disclaimer,
      'emergencyDetected': emergencyDetected,
      'imageQuality': imageQuality,
      'whenToVisitDoctor': whenToVisitDoctor,
      'possibleCauses': possibleCauses,
      'symptoms': symptoms,
      'age': age,
      'gender': gender,
      'errorMessage': errorMessage,
      'processingTimeMs': processingTimeMs,
      'aiModelVersion': aiModelVersion,
      'promptVersion': promptVersion,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Color get severityColor {
    final s = severity.toLowerCase();
    if (s.contains('emergency') || s.contains('high')) return AppColors.error;
    if (s.contains('medium')) return AppColors.warning;
    return AppColors.success;
  }

  String get severityLabel {
    if (severity.toLowerCase().contains('emergency')) return 'EMERGENCY';
    return severity.toUpperCase();
  }

  String get severityEmoji {
    final s = severity.toLowerCase();
    if (s.contains('emergency')) return '🚨';
    if (s.contains('high')) return '⚠️';
    if (s.contains('medium')) return '⚠️';
    return '✅';
  }

  Color get confidenceColor {
    final c = confidence.toLowerCase();
    if (c.contains('high')) return AppColors.success;
    if (c.contains('medium')) return AppColors.warning;
    return AppColors.error;
  }

  String get confidenceLabel => confidence.toUpperCase();

  bool get isAnalyzable => imageQuality.toLowerCase() == 'good';
  
  bool get isEmergency => emergencyDetected || severity.toLowerCase() == 'emergency';

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 365) return '${(difference.inDays / 365).floor()}y ago';
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()}mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}
