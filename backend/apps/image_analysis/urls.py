"""
URL routing for Image Analysis API.
Mounted at /api/v1/image-analysis/
"""
from django.urls import path
from .views import (
    ImageAnalysisUploadView,
    ImageAnalysisDetailView,
    ImageAnalysisStatusView,
    ImageAnalysisHistoryView,
    ImageAnalysisDeleteView,
)

app_name = "image_analysis"

urlpatterns = [
    path("analyze/", ImageAnalysisUploadView.as_view(), name="analyze_image"),
    path("<uuid:pk>/", ImageAnalysisDetailView.as_view(), name="analysis_detail"),
    path("<uuid:pk>/status/", ImageAnalysisStatusView.as_view(), name="analysis_status"),
    path("history/", ImageAnalysisHistoryView.as_view(), name="analysis_history"),
    path("<uuid:pk>/delete/", ImageAnalysisDeleteView.as_view(), name="analysis_delete"),
    # Also support direct DELETE on <uuid:pk>/
    path("<uuid:pk>/", ImageAnalysisDeleteView.as_view(), name="analysis_delete_direct"),
]
