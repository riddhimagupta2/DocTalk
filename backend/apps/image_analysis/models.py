"""
Models for Medical Image Analysis.
Encapsulates patient image submissions, AI diagnostic evaluations,
confidence metrics, and clinical triage recommendations.
"""
import uuid
from django.db import models
from django.utils import timezone
from apps.common.models import TimeStampedModel, UUIDModel, SoftDeletableModel

DEFAULT_DISCLAIMER = (
    "This analysis is AI generated and is not a medical diagnosis. "
    "Please consult a licensed doctor."
)


class ImageAnalysis(UUIDModel, TimeStampedModel, SoftDeletableModel):
    """
    Core record of a medical symptom image analysis session.
    """

    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        PROCESSING = "processing", "Processing"
        COMPLETED = "completed", "Completed"
        FAILED = "failed", "Failed"

    class Confidence(models.TextChoices):
        LOW = "Low", "Low"
        MEDIUM = "Medium", "Medium"
        HIGH = "High", "High"

    class Severity(models.TextChoices):
        LOW = "Low", "Low"
        MEDIUM = "Medium", "Medium"
        HIGH = "High", "High"
        EMERGENCY = "Emergency", "Emergency"

    # Patient / User association
    user_firebase_uid = models.CharField(max_length=128, db_index=True)

    # Input Image Metadata
    original_filename = models.CharField(max_length=255)
    storage_path = models.CharField(max_length=500)
    image_url = models.URLField(max_length=1000, blank=True)
    thumbnail_path = models.CharField(max_length=500, blank=True)
    thumbnail_url = models.URLField(max_length=1000, blank=True)
    image_size_bytes = models.PositiveIntegerField(default=0)
    image_width = models.PositiveIntegerField(null=True, blank=True)
    image_height = models.PositiveIntegerField(null=True, blank=True)
    mime_type = models.CharField(max_length=64, default="image/jpeg")

    # Patient Context (optional)
    symptoms = models.TextField(blank=True, default="")
    age = models.PositiveSmallIntegerField(null=True, blank=True)
    gender = models.CharField(max_length=32, blank=True, default="")
    device_info = models.CharField(max_length=255, blank=True, default="")

    # Processing & Lifecycle
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PENDING,
        db_index=True,
    )
    consent_given = models.BooleanField(default=False)

    # AI Evaluation Results
    possible_conditions = models.JSONField(default=list, blank=True)
    confidence = models.CharField(
        max_length=20,
        choices=Confidence.choices,
        default=Confidence.LOW,
    )
    severity = models.CharField(
        max_length=20,
        choices=Severity.choices,
        default=Severity.LOW,
    )
    possible_causes = models.JSONField(default=list, blank=True)
    recommendations = models.JSONField(default=list, blank=True)
    first_aid = models.JSONField(default=list, blank=True)
    red_flags = models.JSONField(default=list, blank=True)
    when_to_visit_doctor = models.TextField(blank=True, default="")
    doctor_speciality = models.CharField(max_length=128, blank=True, default="General Physician")
    emergency_detected = models.BooleanField(default=False, db_index=True)
    image_quality = models.CharField(max_length=32, default="good")

    disclaimer = models.TextField(default=DEFAULT_DISCLAIMER)
    error_message = models.TextField(blank=True, default="")

    # Performance & Observability
    processing_time_ms = models.PositiveIntegerField(default=0)
    ai_model_version = models.CharField(max_length=64, default="gpt-4o-mini")
    prompt_version = models.CharField(max_length=32, default="1.0.0")
    completed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        verbose_name = "Medical Image Analysis"
        verbose_name_plural = "Medical Image Analyses"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["user_firebase_uid", "-created_at"]),
            models.Index(fields=["status"]),
            models.Index(fields=["emergency_detected"]),
        ]

    def __str__(self):
        return f"Analysis {self.id} [{self.status}] ({self.user_firebase_uid})"

    def mark_processing(self):
        self.status = self.Status.PROCESSING
        self.save(update_fields=["status", "updated_at"])

    def mark_completed(self, ai_data: dict, processing_time_ms: int):
        self.status = self.Status.COMPLETED
        self.possible_conditions = ai_data.get("possible_conditions", [])
        self.confidence = ai_data.get("confidence", "Low")
        self.severity = ai_data.get("severity", "Low")
        self.possible_causes = ai_data.get("possible_causes", [])
        self.recommendations = ai_data.get("recommendations", [])
        self.first_aid = ai_data.get("first_aid", [])
        self.red_flags = ai_data.get("red_flags", [])
        self.when_to_visit_doctor = ai_data.get("when_to_visit_doctor", "")
        self.doctor_speciality = ai_data.get("doctor_speciality", "General Physician")
        self.emergency_detected = ai_data.get("emergency_detected", False)
        self.image_quality = ai_data.get("image_quality", "good")
        self.disclaimer = ai_data.get("disclaimer", DEFAULT_DISCLAIMER)
        self.processing_time_ms = processing_time_ms
        self.completed_at = timezone.now()
        self.save()

    def mark_failed(self, error_message: str):
        self.status = self.Status.FAILED
        self.error_message = error_message
        self.completed_at = timezone.now()
        self.save(update_fields=["status", "error_message", "completed_at", "updated_at"])
