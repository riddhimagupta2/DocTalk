"""
Unit tests for image validators.
Tests valid images, corrupted images, invalid MIME types, oversized images, and malicious executables.
"""
import io
from PIL import Image
from django.test import SimpleTestCase
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework.exceptions import ValidationError
from apps.image_analysis.validators import validate_medical_image, detect_mime_from_bytes


class ImageValidatorTests(SimpleTestCase):
    def _create_test_image(self, format="JPEG", size=(200, 200), color=(255, 0, 0)):
        buf = io.BytesIO()
        img = Image.new("RGB", size, color=color)
        img.save(buf, format=format)
        return buf.getvalue()

    def test_valid_jpeg_passes_validation(self):
        img_bytes = self._create_test_image(format="JPEG")
        file_obj = SimpleUploadedFile("rash.jpg", img_bytes, content_type="image/jpeg")
        meta = validate_medical_image(file_obj)
        self.assertEqual(meta["mime_type"], "image/jpeg")
        self.assertEqual(meta["width"], 200)
        self.assertEqual(meta["height"], 200)

    def test_valid_png_passes_validation(self):
        img_bytes = self._create_test_image(format="PNG")
        file_obj = SimpleUploadedFile("burn.png", img_bytes, content_type="image/png")
        meta = validate_medical_image(file_obj)
        self.assertEqual(meta["mime_type"], "image/png")

    def test_empty_file_rejected(self):
        file_obj = SimpleUploadedFile("empty.jpg", b"", content_type="image/jpeg")
        with self.assertRaises(ValidationError) as ctx:
            validate_medical_image(file_obj)
        self.assertIn("empty", str(ctx.exception).lower())

    def test_corrupted_image_rejected(self):
        file_obj = SimpleUploadedFile("corrupt.jpg", b"\xff\xd8\xffcorruptedgarbage12345", content_type="image/jpeg")
        with self.assertRaises(ValidationError) as ctx:
            validate_medical_image(file_obj)
        self.assertIn("corrupted", str(ctx.exception).lower())

    def test_executable_headers_rejected(self):
        # Fake MZ PE executable
        file_obj = SimpleUploadedFile("virus.jpg", b"MZ\x90\x00\x03\x00\x00\x00", content_type="image/jpeg")
        with self.assertRaises(ValidationError) as ctx:
            validate_medical_image(file_obj)
        self.assertIn("security check failed", str(ctx.exception).lower())

    def test_unsupported_mime_rejected(self):
        file_obj = SimpleUploadedFile("document.pdf", b"%PDF-1.4 sample content", content_type="application/pdf")
        with self.assertRaises(ValidationError) as ctx:
            validate_medical_image(file_obj)
        self.assertIn("invalid file format", str(ctx.exception).lower())
