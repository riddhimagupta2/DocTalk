"""
Celery asynchronous tasks for background medical image analysis.
Enables reliable execution, automatic retries for transient AI provider hiccups,
and background status transitions.
"""
import time
from celery import shared_task
from core.storage import get_storage_service
from core.utils.logging import get_logger
from .models import ImageAnalysis
from .services.ai_service import MedicalImageAIService

logger = get_logger("apps.image_analysis.tasks")


@shared_task(
    bind=True,
    max_retries=3,
    default_retry_delay=5,
    time_limit=120,
    name="apps.image_analysis.tasks.process_image_analysis_async",
)
def process_image_analysis_async(self, analysis_id: str):
    """
    Executes background AI vision inference for an existing ImageAnalysis record.
    """
    try:
        analysis = ImageAnalysis.objects.get(id=analysis_id)
    except ImageAnalysis.DoesNotExist:
        logger.error("ImageAnalysis ID %s does not exist. Aborting task.", analysis_id)
        return

    # Update status to processing
    analysis.mark_processing()

    start_time = time.time()
    storage = get_storage_service()

    try:
        # Read saved image bytes from storage
        image_bytes = storage.read(analysis.storage_path)

        # Call Gemini Vision Service
        ai_service = MedicalImageAIService()
        ai_output = ai_service.analyze_image(
            image_bytes=image_bytes,
            mime_type=analysis.mime_type,
            symptoms=analysis.symptoms,
            age=analysis.age,
            gender=analysis.gender,
        )

        total_latency_ms = int((time.time() - start_time) * 1000)

        # Mark analysis completed
        analysis.mark_completed(
            ai_data=ai_output["result"],
            processing_time_ms=total_latency_ms,
        )

        logger.info(
            "Async ImageAnalysis %s completed in %dms.",
            analysis_id,
            total_latency_ms,
            extra={
                "analysis_id": analysis_id,
                "user_id": analysis.user_firebase_uid,
                "total_latency_ms": total_latency_ms,
                "status": "completed",
            },
        )

    except Exception as exc:
        logger.exception("Error processing async image analysis %s: %s", analysis_id, str(exc))
        try:
            # Retry if transient error and retries remaining
            raise self.retry(exc=exc, countdown=5 * (2 ** self.request.retries))
        except self.MaxRetriesExceededError:
            analysis.mark_failed(f"AI analysis failed after multiple attempts: {str(exc)}")
            logger.error("Async ImageAnalysis %s failed permanently after max retries.", analysis_id)
