"""
Validation rules for medical image uploads.
Enforces strict MIME typing, dimensions, size limits, and corruption checks.
"""
import io
from PIL import Image
from rest_framework.exceptions import ValidationError
from core.utils.security import run_virus_scan_hook

ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "webp"}
ALLOWED_MIME_TYPES = {
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/webp",
}
MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024  # 10 MB
MIN_DIMENSION = 20
MAX_DIMENSION = 8192


def detect_mime_from_bytes(file_bytes: bytes) -> str:
    """Detects MIME type by inspecting leading magic numbers."""
    if file_bytes.startswith(b"\xff\xd8\xff"):
        return "image/jpeg"
    elif file_bytes.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png"
    elif file_bytes.startswith(b"RIFF") and b"WEBP" in file_bytes[:16]:
        return "image/webp"
    return "application/octet-stream"


def validate_medical_image(file_obj) -> dict:
    """
    Runs full verification suite against uploaded file:
    - Size check
    - Antivirus hook
    - Magic byte MIME check
    - Pillow structural decoding and integrity check
    - Dimension boundaries

    Returns dict of metadata: {mime_type, width, height, size_bytes}
    Raises ValidationError on failure.
    """
    # 1. Size check
    file_bytes = file_obj.read()
    size_bytes = len(file_bytes)

    if size_bytes == 0:
        raise ValidationError("Uploaded file is empty.")

    if size_bytes > MAX_FILE_SIZE_BYTES:
        raise ValidationError(
            f"Image size exceeds the 10 MB limit (Current: {size_bytes / (1024*1024):.2f} MB)."
        )

    # 2. Executable / Virus Scan Hook
    if not run_virus_scan_hook(file_bytes):
        raise ValidationError("Security check failed: File appears to contain malicious or executable code.")

    # 3. Magic MIME verification
    detected_mime = detect_mime_from_bytes(file_bytes)
    if detected_mime not in ALLOWED_MIME_TYPES:
        raise ValidationError(
            f"Invalid file format: Detected '{detected_mime}'. Only JPG, JPEG, PNG, and WEBP are accepted."
        )

    # 4. Pillow Decoding & Corruption Check
    try:
        image = Image.open(io.BytesIO(file_bytes))
        image.verify()  # Structural integrity
    except Exception as e:
        raise ValidationError(f"Corrupted or unreadable image file: {str(e)}")

    # Re-open to read dimensions (verify() closes the file)
    try:
        image = Image.open(io.BytesIO(file_bytes))
        width, height = image.size
    except Exception as e:
        raise ValidationError(f"Unable to read image dimensions: {str(e)}")

    # 5. Dimension boundaries
    if width < MIN_DIMENSION or height < MIN_DIMENSION:
        raise ValidationError(
            f"Image resolution too low ({width}x{height}px). Minimum {MIN_DIMENSION}x{MIN_DIMENSION}px required."
        )

    if width > MAX_DIMENSION or height > MAX_DIMENSION:
        raise ValidationError(
            f"Image resolution exceeds limits ({width}x{height}px). Maximum {MAX_DIMENSION}x{MAX_DIMENSION}px allowed."
        )

    # Reset pointer for subsequent processing
    file_obj.seek(0)

    return {
        "mime_type": detected_mime,
        "width": width,
        "height": height,
        "size_bytes": size_bytes,
        "file_bytes": file_bytes,
    }
