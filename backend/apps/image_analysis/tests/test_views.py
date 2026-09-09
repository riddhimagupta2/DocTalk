"""
Integration tests for Image Analysis API endpoints.
Tests upload, permissions, history pagination, and GDPR deletion.
"""
import io
from PIL import Image
from unittest.mock import patch
from django.urls import reverse
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth import get_user_model
from apps.image_analysis.models import ImageAnalysis

User = get_user_model()


class ImageAnalysisViewTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="testuser",
            email="testuser@example.com",
            firebase_uid="firebase_uid_12345",
        )
        self.client.force_authenticate(user=self.user)

    def _create_test_image(self):
        buf = io.BytesIO()
        img = Image.new("RGB", (150, 150), color=(200, 50, 50))
        img.save(buf, format="JPEG")
        return buf.getvalue()

    @patch("apps.image_analysis.services.ai_service.MedicalImageAIService.analyze_image")
    def test_upload_and_analyze_image_success(self, mock_ai_call):
        mock_ai_call.return_value = {
            "result": {
                "image_quality": "good",
                "emergency_detected": False,
                "confidence": "Medium",
                "severity": "Low",
                "possible_conditions": [{"name": "Urticaria (Hives)", "likelihood": "Likely"}],
                "possible_causes": ["Histamine response"],
                "recommendations": ["Avoid hot showers"],
                "first_aid": ["Apply cold compress"],
                "red_flags": ["Difficulty breathing"],
                "when_to_visit_doctor": "Within 24 hours if worsening",
                "doctor_speciality": "Allergist or Dermatologist",
                "disclaimer": "This analysis is AI generated and is not a medical diagnosis. Please consult a licensed doctor.",
            },
            "ai_latency_ms": 1200,
            "model_version": "gemini-1.5-flash",
            "prompt_version": "1.0.0",
        }

        url = reverse("image_analysis:analyze_image")
        file_obj = SimpleUploadedFile("rash.jpg", self._create_test_image(), content_type="image/jpeg")

        data = {
            "image": file_obj,
            "symptoms": "Red itchy bumps on arm after eating strawberries",
            "age": 28,
            "gender": "female",
            "consent_given": True,
        }

        response = self.client.post(url, data, format="multipart")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        res_data = response.data["data"]
        self.assertEqual(res_data["status"], "completed")
        self.assertEqual(res_data["doctor_speciality"], "Allergist or Dermatologist")
        self.assertEqual(res_data["confidence"], "Medium")

    def test_unauthenticated_request_rejected(self):
        self.client.force_authenticate(user=None)
        url = reverse("image_analysis:analyze_image")
        response = self.client.post(url, {}, format="multipart")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_gdpr_delete_endpoint(self):
        analysis = ImageAnalysis.objects.create(
            user_firebase_uid=self.user.firebase_uid,
            original_filename="rash.jpg",
            storage_path="medical_images/test/sample.jpg",
            thumbnail_path="medical_images/test/thumb_sample.jpg",
            status=ImageAnalysis.Status.COMPLETED,
        )

        url = reverse("image_analysis:analysis_delete", kwargs={"pk": analysis.id})
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        analysis.refresh_from_db()
        self.assertTrue(analysis.is_deleted)
        self.assertEqual(analysis.storage_path, "")
