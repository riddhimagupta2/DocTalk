"""
API Views for Medical Image Analysis.
Endpoints:
- POST   /api/v1/image-analysis/analyze/   - Upload & analyze symptom image
- GET    /api/v1/image-analysis/<id>/      - Get specific analysis result
- GET    /api/v1/image-analysis/<id>/status/ - Poll background task status
- GET    /api/v1/image-analysis/history/   - List user's consultation history
- DELETE /api/v1/image-analysis/<id>/      - GDPR-compliant permanent delete
"""
import time
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.pagination import PageNumberPagination
from rest_framework.exceptions import NotFound, PermissionDenied
from django.shortcuts import get_object_or_404
from django.utils import timezone

from core.permissions.firebase import (
    IsFirebaseAuthenticated,
    IsAnalysisOwner,
    ImageAnalysisRateThrottle,
)
from core.utils.responses import success_response, error_response
from core.utils.logging import get_logger

from .models import ImageAnalysis
from .serializers import (
    ImageAnalysisCreateSerializer,
    ImageAnalysisResponseSerializer,
    ImageAnalysisListSerializer,
    ImageAnalysisStatusSerializer,
)
from .services.image_service import ImageProcessingService
from .services.ai_service import MedicalImageAIService
from .tasks import process_image_analysis_async

logger = get_logger("apps.image_analysis.views")


class ImageAnalysisPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = "page_size"
    max_page_size = 50


class ImageAnalysisUploadView(APIView):
    """
    POST /api/v1/image-analysis/analyze/
    Primary endpoint for patient medical symptom image submission.
    """
    permission_classes = [IsFirebaseAuthenticated]
    throttle_classes = [ImageAnalysisRateThrottle]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        serializer = ImageAnalysisCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user_uid = getattr(request.user, "firebase_uid", str(request.user.pk))
        validated_data = serializer.validated_data
        image_file = validated_data["image"]
        meta = getattr(image_file, "validated_meta", {})
        raw_bytes = meta.get("file_bytes") or image_file.read()

        # 1. Preprocess & Store image (EXIF scrub, resize, thumbnail, storage)
        image_service = ImageProcessingService()
        storage_meta = image_service.process_and_store_image(
            raw_bytes=raw_bytes,
            original_filename=image_file.name,
            user_uid=user_uid,
        )

        # 2. Create ImageAnalysis DB Record
        analysis = ImageAnalysis.objects.create(
            user_firebase_uid=user_uid,
            original_filename=image_file.name,
            storage_path=storage_meta["storage_path"],
            image_url=storage_meta["image_url"],
            thumbnail_path=storage_meta["thumbnail_path"],
            thumbnail_url=storage_meta["thumbnail_url"],
            image_width=storage_meta["image_width"],
            image_height=storage_meta["image_height"],
            image_size_bytes=storage_meta["image_size_bytes"],
            mime_type=meta.get("mime_type", "image/jpeg"),
            symptoms=validated_data.get("symptoms", ""),
            age=validated_data.get("age"),
            gender=validated_data.get("gender", ""),
            device_info=validated_data.get("device_info", ""),
            consent_given=validated_data.get("consent_given", True),
            status=ImageAnalysis.Status.PROCESSING,
        )

        # 3. Check for async preference
        is_async = request.headers.get("X-Async-Processing", "").lower() in ("true", "1")

        if is_async:
            # Trigger background Celery task
            process_image_analysis_async.delay(str(analysis.id))
            return success_response(
                data=ImageAnalysisStatusSerializer(analysis).data,
                message="Image uploaded successfully. Analysis is processing in the background.",
                status_code=status.HTTP_202_ACCEPTED,
            )

        # 4. Synchronous Processing
        start_time = time.time()
        try:
            ai_service = MedicalImageAIService()
            ai_output = ai_service.analyze_image(
                image_bytes=storage_meta["processed_bytes"],
                mime_type="image/jpeg",
                symptoms=analysis.symptoms,
                age=analysis.age,
                gender=analysis.gender,
            )

            total_latency_ms = int((time.time() - start_time) * 1000)
            analysis.mark_completed(
                ai_data=ai_output["result"],
                processing_time_ms=total_latency_ms,
            )

            response_serializer = ImageAnalysisResponseSerializer(analysis)
            return success_response(
                data=response_serializer.data,
                message="Medical image analysis completed successfully.",
                status_code=status.HTTP_201_CREATED,
            )

        except Exception as exc:
            logger.exception("Synchronous AI analysis failed for %s: %s", analysis.id, str(exc))
            analysis.mark_failed(f"Unable to complete AI evaluation: {str(exc)}")
            return error_response(
                message=f"Analysis failed: {str(exc)}",
                code="ANALYSIS_PROCESSING_FAILED",
                details={"analysis_id": str(analysis.id), "status": "failed"},
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class ImageAnalysisDetailView(APIView):
    """
    GET /api/v1/image-analysis/<id>/
    Retrieves full evaluation report for an existing analysis.
    """
    permission_classes = [IsFirebaseAuthenticated, IsAnalysisOwner]

    def get(self, request, pk):
        user_uid = getattr(request.user, "firebase_uid", str(request.user.pk))
        analysis = get_object_or_404(
            ImageAnalysis,
            id=pk,
            user_firebase_uid=user_uid,
            is_deleted=False,
        )
        self.check_object_permissions(request, analysis)

        serializer = ImageAnalysisResponseSerializer(analysis)
        return success_response(serializer.data)


class ImageAnalysisStatusView(APIView):
    """
    GET /api/v1/image-analysis/<id>/status/
    Polls task status (pending, processing, completed, failed).
    """
    permission_classes = [IsFirebaseAuthenticated, IsAnalysisOwner]

    def get(self, request, pk):
        user_uid = getattr(request.user, "firebase_uid", str(request.user.pk))
        analysis = get_object_or_404(
            ImageAnalysis,
            id=pk,
            user_firebase_uid=user_uid,
            is_deleted=False,
        )
        self.check_object_permissions(request, analysis)

        serializer = ImageAnalysisStatusSerializer(analysis)
        return success_response(serializer.data)


class ImageAnalysisHistoryView(APIView):
    """
    GET /api/v1/image-analysis/history/
    Retrieves paginated consultation history for current patient.
    """
    permission_classes = [IsFirebaseAuthenticated]
    pagination_class = ImageAnalysisPagination

    def get(self, request):
        user_uid = getattr(request.user, "firebase_uid", str(request.user.pk))
        queryset = ImageAnalysis.objects.filter(
            user_firebase_uid=user_uid,
            is_deleted=False,
        ).order_by("-created_at")

        paginator = self.pagination_class()
        page = paginator.paginate_queryset(queryset, request)
        serializer = ImageAnalysisListSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)


class ImageAnalysisDeleteView(APIView):
    """
    DELETE /api/v1/image-analysis/<id>/
    GDPR Right-to-be-Forgotten: Permanently deletes image from storage
    and marks analysis record deleted.
    """
    permission_classes = [IsFirebaseAuthenticated, IsAnalysisOwner]

    def delete(self, request, pk):
        user_uid = getattr(request.user, "firebase_uid", str(request.user.pk))
        analysis = get_object_or_404(
            ImageAnalysis,
            id=pk,
            user_firebase_uid=user_uid,
            is_deleted=False,
        )
        self.check_object_permissions(request, analysis)

        # 1. Permanently delete image files from storage
        image_service = ImageProcessingService()
        image_service.delete_analysis_images(
            storage_path=analysis.storage_path,
            thumbnail_path=analysis.thumbnail_path,
        )

        # 2. Soft-delete DB record and wipe URLs & metadata
        analysis.soft_delete()
        analysis.image_url = ""
        analysis.thumbnail_url = ""
        analysis.storage_path = ""
        analysis.thumbnail_path = ""
        analysis.save(update_fields=["image_url", "thumbnail_url", "storage_path", "thumbnail_path"])

        logger.info("GDPR deletion executed for ImageAnalysis %s by user %s", pk, user_uid)

        return success_response(
            data={"id": str(pk), "deleted": True},
            message="Analysis and associated medical image permanently deleted.",
            status_code=status.HTTP_200_OK,
        )
