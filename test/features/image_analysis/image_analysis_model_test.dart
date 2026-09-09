import 'package:flutter_test/flutter_test.dart';
import 'package:doctalk/features/image_analysis/models/image_analysis_model.dart';

void main() {
  group('ImageAnalysisResult Model Tests', () {
    test('fromJson successfully parses complete Django REST API response', () {
      final json = {
        'id': '777e4567-e89b-12d3-a456-426614174000',
        'status': 'completed',
        'image_url': 'http://10.0.2.2:8000/media/medical_images/uid/sample.jpg',
        'thumbnail_url': 'http://10.0.2.2:8000/media/medical_images/uid/thumb_sample.jpg',
        'possible_conditions': [
          {'name': 'Atopic Dermatitis (Eczema)', 'likelihood': 'Likely'},
          {'name': 'Contact Dermatitis', 'likelihood': 'Possible'},
        ],
        'confidence': 'Medium',
        'severity': 'Low',
        'recommendations': ['Moisturize frequently', 'Avoid fragrance soaps'],
        'first_aid': ['Wash gently with lukewarm water'],
        'red_flags': ['Signs of secondary infection such as pus'],
        'doctor_speciality': 'Dermatologist',
        'emergency_detected': false,
        'image_quality': 'good',
        'disclaimer': 'This analysis is AI generated and is not a medical diagnosis. Please consult a licensed doctor.',
        'symptoms': 'Itchy redness on inner elbow',
        'age': 25,
        'gender': 'Female',
        'processing_time_ms': 1420,
        'ai_model_version': 'gemini-1.5-flash',
        'created_at': '2026-09-08T18:00:00Z',
      };

      final result = ImageAnalysisResult.fromJson(json);

      expect(result.id, '777e4567-e89b-12d3-a456-426614174000');
      expect(result.status, 'completed');
      expect(result.confidence, 'Medium');
      expect(result.severity, 'Low');
      expect(result.possibleConditions.length, 2);
      expect(result.possibleConditions.first.name, 'Atopic Dermatitis (Eczema)');
      expect(result.possibleConditions.first.likelihood, 'Likely');
      expect(result.doctorSpeciality, 'Dermatologist');
      expect(result.isEmergency, false);
      expect(result.disclaimer, contains('not a medical diagnosis'));
    });

    test('Emergency detection correctly flags severe conditions', () {
      final json = {
        'id': '999e4567-e89b-12d3-a456-426614174000',
        'status': 'completed',
        'severity': 'Emergency',
        'emergency_detected': true,
        'possible_conditions': [
          {'name': '3rd Degree Thermal Burn', 'likelihood': 'Likely'}
        ],
        'first_aid': ['Seek emergency medical care immediately.'],
      };

      final result = ImageAnalysisResult.fromJson(json);

      expect(result.isEmergency, true);
      expect(result.severityEmoji, '🚨');
      expect(result.severityLabel, 'EMERGENCY');
    });
  });
}
