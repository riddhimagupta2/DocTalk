"""
Firebase Storage Service implementation.
Leverages existing project's Firebase Storage bucket (doctalk-e60b5.firebasestorage.app)
via firebase-admin SDK.
"""
from datetime import timedelta
from django.conf import settings
from .base import BaseStorageService
from ..utils.logging import get_logger

logger = get_logger("core.storage.firebase")


class FirebaseStorageService(BaseStorageService):
    """Integrates with Cloud Storage for Firebase."""

    def __init__(self):
        try:
            import firebase_admin
            from firebase_admin import storage

            bucket_name = getattr(
                settings,
                "FIREBASE_STORAGE_BUCKET",
                "doctalk-e60b5.firebasestorage.app",
            )
            self.bucket = storage.bucket(bucket_name)
            self._initialized = True
        except Exception as e:
            logger.warning("Firebase storage initialization error: %s. Fallback to dummy.", str(e))
            self.bucket = None
            self._initialized = False

    def save(
        self,
        file_bytes: bytes,
        path: str,
        content_type: str = "image/jpeg",
    ) -> str:
        if not self._initialized or self.bucket is None:
            raise RuntimeError("Firebase storage is not initialized.")

        blob = self.bucket.blob(path)
        blob.upload_from_string(file_bytes, content_type=content_type)
        logger.info("Uploaded to Firebase Storage: %s (%d bytes)", path, len(file_bytes))
        return path

    def read(self, path: str) -> bytes:
        if not self._initialized or self.bucket is None:
            raise RuntimeError("Firebase storage is not initialized.")

        blob = self.bucket.blob(path)
        return blob.download_as_bytes()

    def delete(self, path: str) -> bool:
        if not self._initialized or self.bucket is None:
            return False

        blob = self.bucket.blob(path)
        if blob.exists():
            blob.delete()
            logger.info("Deleted from Firebase Storage: %s", path)
            return True
        return False

    def get_url(self, path: str) -> str:
        if not self._initialized or self.bucket is None:
            return f"https://storage.googleapis.com/{settings.FIREBASE_STORAGE_BUCKET}/{path}"

        blob = self.bucket.blob(path)
        try:
            # Generate signed URL valid for 24 hours
            return blob.generate_signed_url(expiration=timedelta(hours=24), method="GET")
        except Exception:
            return f"https://storage.googleapis.com/{settings.FIREBASE_STORAGE_BUCKET}/{path}"
