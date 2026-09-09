"""
Serializers for Medical Image Analysis API.
Enforces strict client input validation, sanitization, and output transformation.
"""
from rest_framework import serializers
from .models import ImageAnalysis
from .validators import validate_medical_image
from core.utils.security import sanitize_text_input


class PossibleConditionSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=255)
    likelihood = serializers.CharField(max_length=64)


class ImageAnalysisCreateSerializer(serializers.Serializer):
    """
    Multipart upload serializer for /api/v1/image-analysis/analyze/
    """
    image = serializers.FileField(required=True)
    symptoms = serializers.CharField(required=False, allow_blank=True, max_length=1000, default="")
    age = serializers.IntegerField(required=False, min_value=0, max_value=130, allow_null=True)
    gender = serializers.CharField(required=False, allow_blank=True, max_length=32, default="")
    consent_given = serializers.BooleanField(required=True)
    device_info = serializers.CharField(required=False, allow_blank=True, max_length=255, default="")

    def validate_consent_given(self, value):
        if not value:
            raise serializers.ValidationError(
                "You must provide explicit consent for medical AI analysis of your image."
            )
        return value

    def validate_symptoms(self, value):
        return sanitize_text_input(value, max_length=1000)

    def validate_image(self, value):
        # Runs MIME, size, corruption, dimension, and malware validations
        meta = validate_medical_image(value)
        # Attach validated metadata to the file object for downstream service use
        value.validated_meta = meta
        return value


class ImageAnalysisResponseSerializer(serializers.ModelSerializer):
    """
    Full diagnostic evaluation response.
    """
    possible_conditions = serializers.ListField(child=serializers.DictField(), read_only=True)
    recommendations = serializers.ListField(child=serializers.CharField(), read_only=True)
    first_aid = serializers.ListField(child=serializers.CharField(), read_only=True)
    red_flags = serializers.ListField(child=serializers.CharField(), read_only=True)
    possible_causes = serializers.ListField(child=serializers.CharField(), read_only=True)

    class Meta:
        model = ImageAnalysis
        fields = [
            "id",
            "status",
            "image_url",
            "thumbnail_url",
            "possible_conditions",
            "confidence",
            "severity",
            "recommendations",
            "first_aid",
            "red_flags",
            "possible_causes",
            "when_to_visit_doctor",
            "doctor_speciality",
            "emergency_detected",
            "image_quality",
            "disclaimer",
            "error_message",
            "processing_time_ms",
            "ai_model_version",
            "prompt_version",
            "symptoms",
            "age",
            "gender",
            "created_at",
            "completed_at",
        ]
        read_only_fields = fields


class ImageAnalysisListSerializer(serializers.ModelSerializer):
    """
    Lightweight serializer for patient consultation history list.
    """
    class Meta:
        model = ImageAnalysis
        fields = [
            "id",
            "status",
            "image_url",
            "thumbnail_url",
            "confidence",
            "severity",
            "doctor_speciality",
            "emergency_detected",
            "symptoms",
            "created_at",
        ]
        read_only_fields = fields


class ImageAnalysisStatusSerializer(serializers.ModelSerializer):
    """
    Fast polling response for asynchronous processing jobs.
    """
    class Meta:
        model = ImageAnalysis
        fields = ["id", "status", "error_message", "processing_time_ms"]
        read_only_fields = fields
