from django.contrib import admin
from .models import ImageAnalysis


@admin.register(ImageAnalysis)
class ImageAnalysisAdmin(admin.ModelAdmin):
    list_display = [
        "id",
        "user_firebase_uid",
        "status",
        "severity",
        "confidence",
        "emergency_detected",
        "doctor_speciality",
        "created_at",
    ]
    list_filter = ["status", "severity", "confidence", "emergency_detected", "created_at"]
    search_fields = ["id", "user_firebase_uid", "symptoms", "doctor_speciality"]
    readonly_fields = [
        "id",
        "created_at",
        "updated_at",
        "completed_at",
        "processing_time_ms",
        "ai_model_version",
        "prompt_version",
    ]
