"""
Image Preprocessing and Storage Service.
Prepares images for Vision LLM: strips privacy EXIF metadata, resizes,
compresses without diagnostic degradation, and generates thumbnails.
"""
import io
import time
from typing import Tuple, Dict, Any
from PIL import Image, ImageOps
from core.storage import get_storage_service
from core.utils.security import generate_secure_filename
from core.utils.logging import get_logger

logger = get_logger("apps.image_analysis.image_service")

MAX_PREVIEW_DIMENSION = 1920
THUMBNAIL_DIMENSION = 300
JPEG_COMPRESSION_QUALITY = 85


class ImageProcessingService:
    """Handles image transformation and cloud/local persistence."""

    def __init__(self):
        self.storage = get_storage_service()

    def process_and_store_image(
        self,
        raw_bytes: bytes,
        original_filename: str,
        user_uid: str,
    ) -> Dict[str, Any]:
        """
        Executes full preprocessing pipeline:
        1. Strips EXIF metadata to protect patient location/camera privacy.
        2. Fixes EXIF rotation orientation.
        3. Constrains max dimensions (preserving aspect ratio).
        4. Compresses to progressive JPEG / PNG.
        5. Generates high-resolution thumbnail.
        6. Persists both files to storage provider.

        Returns metadata dictionary.
        """
        start_time = time.time()
        
        # Open with Pillow
        image = Image.open(io.BytesIO(raw_bytes))

        # Normalize orientation using EXIF before stripping it
        try:
            image = ImageOps.exif_transpose(image)
        except Exception:
            pass

        # Convert palette/RGBA modes if converting to JPEG
        if image.mode in ("RGBA", "P"):
            image = image.convert("RGB")
        elif image.mode != "RGB":
            image = image.convert("RGB")

        orig_w, orig_h = image.size

        # 1. Resize main image if larger than MAX_PREVIEW_DIMENSION
        if orig_w > MAX_PREVIEW_DIMENSION or orig_h > MAX_PREVIEW_DIMENSION:
            image.thumbnail((MAX_PREVIEW_DIMENSION, MAX_PREVIEW_DIMENSION), Image.Resampling.LANCZOS)
            logger.info("Resized image from %dx%d to %dx%d", orig_w, orig_h, image.size[0], image.size[1])

        current_w, current_h = image.size

        # 2. Export clean image (no EXIF metadata saved)
        clean_buf = io.BytesIO()
        image.save(clean_buf, format="JPEG", quality=JPEG_COMPRESSION_QUALITY, optimize=True)
        processed_bytes = clean_buf.getvalue()

        # 3. Generate Thumbnail
        thumb_image = image.copy()
        thumb_image.thumbnail((THUMBNAIL_DIMENSION, THUMBNAIL_DIMENSION), Image.Resampling.LANCZOS)
        thumb_buf = io.BytesIO()
        thumb_image.save(thumb_buf, format="JPEG", quality=80, optimize=True)
        thumbnail_bytes = thumb_buf.getvalue()

        # 4. Generate secure filenames & storage paths
        secure_name, _ = generate_secure_filename(original_filename)
        storage_rel_path = f"medical_images/{user_uid}/{secure_name}"
        thumb_rel_path = f"medical_images/{user_uid}/thumb_{secure_name}"

        # 5. Persist to storage
        image_path = self.storage.save(processed_bytes, storage_rel_path, content_type="image/jpeg")
        thumb_path = self.storage.save(thumbnail_bytes, thumb_rel_path, content_type="image/jpeg")

        image_url = self.storage.get_url(image_path)
        thumb_url = self.storage.get_url(thumb_path)

        storage_latency_ms = int((time.time() - start_time) * 1000)
        logger.info(
            "Image processed and stored: %s (latency: %dms)",
            image_path,
            storage_latency_ms,
            extra={"storage_latency_ms": storage_latency_ms},
        )

        return {
            "storage_path": image_path,
            "image_url": image_url,
            "thumbnail_path": thumb_path,
            "thumbnail_url": thumb_url,
            "image_width": current_w,
            "image_height": current_h,
            "image_size_bytes": len(processed_bytes),
            "processed_bytes": processed_bytes,
            "storage_latency_ms": storage_latency_ms,
        }

    def delete_analysis_images(self, storage_path: str, thumbnail_path: str = "") -> bool:
        """Removes image files from storage (GDPR compliance)."""
        deleted = False
        if storage_path:
            deleted = self.storage.delete(storage_path)
        if thumbnail_path:
            self.storage.delete(thumbnail_path)
        return deleted
