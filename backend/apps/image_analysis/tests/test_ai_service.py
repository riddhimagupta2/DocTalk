"""
Unit tests for MedicalImageAIService.
Mocks Gemini Vision calls, verifies JSON parsing, safety guardrails, and emergency escalation.
"""
from unittest.mock import patch, MagicMock
from django.test import SimpleTestCase
from apps.image_analysis.services.ai_service import MedicalImageAIService


class AIServiceTests(SimpleTestCase):
    def setUp(self):
        self.service = MedicalImageAIService()

    def test_enforce_safety_rules_normalizes_confidence_and_disclaimer(self):
        raw_output = {
            "confidence": "100%",  # Forbidden
            "severity": "mild",
            "possible_conditions": [{"name": "Eczema", "likelihood": "Possible"}],
            "disclaimer": "Custom wrong text",
        }
        safe_output = self.service._enforce_safety_rules(raw_output)
        self.assertIn(safe_output["confidence"], ("Low", "Medium", "High"))
        self.assertNotEqual(safe_output["confidence"], "100%")
        self.assertIn("Please consult a licensed doctor", safe_output["disclaimer"])

    def test_emergency_detection_triggers_escalation(self):
        raw_output = {
            "confidence": "High",
            "severity": "Emergency",
            "emergency_detected": False,
            "possible_conditions": [{"name": "Severe 3rd Degree Chemical Burn", "likelihood": "Likely"}],
            "first_aid": ["Cover with sterile dressing"],
        }
        safe_output = self.service._enforce_safety_rules(raw_output)
        self.assertTrue(safe_output["emergency_detected"])
        self.assertEqual(safe_output["severity"], "Emergency")
        self.assertTrue(any("emergency" in step.lower() for step in safe_output["first_aid"]))

    @patch("requests.post")
    def test_mocked_openai_vision_flow(self, mock_post):
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "choices": [
                {
                    "message": {
                        "content": '''
                        {
                            "image_quality": "good",
                            "emergency_detected": false,
                            "confidence": "Medium",
                            "severity": "Low",
                            "possible_conditions": [{"name": "Contact Dermatitis", "likelihood": "Likely"}],
                            "possible_causes": ["Allergen exposure"],
                            "recommendations": ["Avoid irritant"],
                            "first_aid": ["Rinse with cool water"],
                            "red_flags": ["Swelling spreading to airway"],
                            "when_to_visit_doctor": "If not better in 3 days",
                            "doctor_speciality": "Dermatologist",
                            "disclaimer": "This analysis is AI generated and is not a medical diagnosis. Please consult a licensed doctor."
                        }
                        '''
                    }
                }
            ],
            "usage": {"prompt_tokens": 120, "completion_tokens": 85},
        }
        mock_post.return_value = mock_response

        service = MedicalImageAIService()
        service.api_key = "fake_key_for_test"

        result_dict = service.analyze_image(
            image_bytes=b"fake_image_bytes",
            mime_type="image/jpeg",
            symptoms="Mild itching on arm",
        )

        res = result_dict["result"]
        self.assertEqual(res["doctor_speciality"], "Dermatologist")
        self.assertEqual(res["confidence"], "Medium")
        self.assertEqual(res["severity"], "Low")
        self.assertEqual(len(res["possible_conditions"]), 1)
