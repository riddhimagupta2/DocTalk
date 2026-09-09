"""
Custom exception handler and domain exceptions for DocTalk REST API.
Ensures standard, predictable error envelopes across all endpoints.
"""
from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status
from .logging import get_logger

logger = get_logger("core.exceptions")


class MedicalImageAnalysisError(Exception):
    """Base domain exception for medical image analysis failures."""
    def __init__(self, message: str, code: str = "IMAGE_ANALYSIS_ERROR"):
        super().__init__(message)
        self.message = message
        self.code = code


class ImageCorruptedError(MedicalImageAnalysisError):
    def __init__(self, message: str = "The uploaded image is corrupted or unreadable."):
        super().__init__(message, "IMAGE_CORRUPTED")


class UnsupportedFormatError(MedicalImageAnalysisError):
    def __init__(self, message: str = "Unsupported image format. Allowed formats: JPG, JPEG, PNG, WEBP."):
        super().__init__(message, "UNSUPPORTED_FORMAT")


class AIProviderTimeoutError(MedicalImageAnalysisError):
    def __init__(self, message: str = "The AI service timed out while analyzing the image. Please retry."):
        super().__init__(message, "AI_TIMEOUT")


class AIProviderUnavailableError(MedicalImageAnalysisError):
    def __init__(self, message: str = "AI service temporarily unavailable. Please try again later."):
        super().__init__(message, "AI_UNAVAILABLE")


def custom_exception_handler(exc, context):
    """
    Standard DRF exception handler returning consistent error schema:
    {
        "success": false,
        "error": {
            "code": "ERROR_CODE",
            "message": "Human readable message",
            "details": {}
        }
    }
    """
    response = exception_handler(exc, context)

    if response is not None:
        custom_data = {
            "success": False,
            "error": {
                "code": exc.__class__.__name__,
                "message": (
                    response.data.get("detail", "An error occurred.")
                    if isinstance(response.data, dict)
                    else str(response.data)
                ),
                "details": response.data,
            },
        }
        response.data = custom_data
        return response

    # Handle custom domain exceptions
    if isinstance(exc, MedicalImageAnalysisError):
        logger.warning("Domain exception handled: %s (code=%s)", exc.message, exc.code)
        return Response(
            {
                "success": False,
                "error": {
                    "code": exc.code,
                    "message": exc.message,
                    "details": {},
                },
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    # Unhandled 500 error
    logger.exception("Unhandled server exception: %s", str(exc))
    return Response(
        {
            "success": False,
            "error": {
                "code": "INTERNAL_SERVER_ERROR",
                "message": "An unexpected server error occurred. Our team has been notified.",
                "details": {},
            },
        },
        status=status.HTTP_500_INTERNAL_SERVER_ERROR,
    )
