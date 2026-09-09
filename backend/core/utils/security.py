"""
Security utilities for input sanitization, safe file path generation,
prompt injection defense, and virus scan hooks.
"""
import re
import uuid
import html
from pathlib import Path
from typing import Tuple


def generate_secure_filename(original_filename: str) -> Tuple[str, str]:
    """
    Generates a secure UUIDv4-based filename while retaining verified extension.
    Prevents path traversal, special characters, and shell injection.
    Returns: (uuid_filename, sanitized_extension)
    """
    # Extract extension safely
    clean_name = Path(original_filename).name
    ext = Path(clean_name).suffix.lower()
    
    # Strip any non-alphanumeric characters from extension
    ext = re.sub(r"[^a-z0-9.]", "", ext)
    if not ext:
        ext = ".jpg"

    secure_id = str(uuid.uuid4())
    secure_filename = f"{secure_id}{ext}"
    return secure_filename, ext


def sanitize_text_input(text: str, max_length: int = 1000) -> str:
    """
    Escapes HTML, strips prompt injection control sequences,
    and limits text length.
    """
    if not text:
        return ""

    # Truncate
    trimmed = text[:max_length].strip()

    # Escape HTML entities
    escaped = html.escape(trimmed)

    # Defend against prompt injection delimiters and jailbreaks
    # Neutralize markdown system overrides and XML/HTML block delimiters
    neutralized = re.sub(
        r"(?i)(system\s*:|instructions\s*:|<\|im_start\|>|<\|im_end\|>|\[SYSTEM\]|\[INST\])",
        "[filtered]",
        escaped,
    )

    return neutralized


def run_virus_scan_hook(file_bytes: bytes) -> bool:
    """
    Pluggable antivirus hook for uploaded medical images.
    In production: Connects to ClamAV / VirusTotal / AWS GuardDuty.
    Returns True if clean, raises ValueError or returns False if infected.
    """
    # Check for known malicious signatures / EICAR test string
    eicar = b"X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*"
    if eicar in file_bytes:
        return False

    # Check for embedded executable headers (MZ, ELF, Mach-O)
    if file_bytes.startswith(b"MZ") or file_bytes.startswith(b"\x7fELF") or file_bytes.startswith(b"\xfe\xed\xfa"):
        return False

    return True
