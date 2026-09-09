"""
Standard API response helpers for consistent envelope structures.
"""
from typing import Any, Optional
from rest_framework.response import Response
from rest_framework import status


def success_response(
    data: Any,
    message: str = "Operation completed successfully.",
    status_code: int = status.HTTP_200_OK,
    metadata: Optional[dict] = None,
) -> Response:
    """Standard success envelope."""
    payload = {
        "success": True,
        "message": message,
        "data": data,
    }
    if metadata:
        payload["metadata"] = metadata
    return Response(payload, status=status_code)


def error_response(
    message: str,
    code: str = "BAD_REQUEST",
    details: Optional[Any] = None,
    status_code: int = status.HTTP_400_BAD_REQUEST,
) -> Response:
    """Standard error envelope."""
    return Response(
        {
            "success": False,
            "error": {
                "code": code,
                "message": message,
                "details": details or {},
            },
        },
        status=status_code,
    )
