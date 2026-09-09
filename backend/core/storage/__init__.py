"""
Pluggable storage module for DocTalk.
Supports Local Filesystem, Firebase Storage, and AWS S3 without changing business logic.
"""
from django.conf import settings
from .base import BaseStorageService
from .local_storage import LocalStorageService
from .firebase_storage import FirebaseStorageService
from .s3_storage import S3StorageService


def get_storage_service() -> BaseStorageService:
    """Factory function returning configured storage service."""
    backend = getattr(settings, "STORAGE_BACKEND", "local").lower()
    if backend == "firebase":
        return FirebaseStorageService()
    elif backend == "s3":
        return S3StorageService()
    return LocalStorageService()


__all__ = ["get_storage_service", "BaseStorageService"]
