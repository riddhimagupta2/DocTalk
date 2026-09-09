"""
Local Filesystem Storage Implementation.
Used for local development and offline environments.
"""
import os
from pathlib import Path
from django.conf import settings
from .base import BaseStorageService
from ..utils.logging import get_logger

logger = get_logger("core.storage.local")


class LocalStorageService(BaseStorageService):
    """Stores files in Django's MEDIA_ROOT."""

    def __init__(self):
        self.media_root = Path(settings.MEDIA_ROOT)
        self.media_url = settings.MEDIA_URL
        self.media_root.mkdir(parents=True, exist_ok=True)

    def save(
        self,
        file_bytes: bytes,
        path: str,
        content_type: str = "image/jpeg",
    ) -> str:
        clean_path = path.lstrip("/\\")
        target_file = self.media_root / clean_path
        target_file.parent.mkdir(parents=True, exist_ok=True)

        with open(target_file, "wb") as f:
            f.write(file_bytes)

        logger.info("Saved file locally at %s (%d bytes)", clean_path, len(file_bytes))
        return clean_path

    def read(self, path: str) -> bytes:
        clean_path = path.lstrip("/\\")
        target_file = self.media_root / clean_path
        if not target_file.exists():
            raise FileNotFoundError(f"File not found: {clean_path}")

        with open(target_file, "rb") as f:
            return f.read()

    def delete(self, path: str) -> bool:
        clean_path = path.lstrip("/\\")
        target_file = self.media_root / clean_path
        if target_file.exists():
            target_file.unlink()
            logger.info("Deleted local file at %s", clean_path)
            return True
        return False

    def get_url(self, path: str) -> str:
        clean_path = path.lstrip("/\\").replace("\\", "/")
        return f"{self.media_url.rstrip('/')}/{clean_path}"
