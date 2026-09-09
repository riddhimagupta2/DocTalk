"""
Abstract Storage Interface for DocTalk.
Defines contracts for saving, retrieving, and permanently deleting medical images.
"""
from abc import ABC, abstractmethod
from typing import Tuple


class BaseStorageService(ABC):
    """Abstract storage provider contract."""

    @abstractmethod
    def save(
        self,
        file_bytes: bytes,
        path: str,
        content_type: str = "image/jpeg",
    ) -> str:
        """
        Saves raw bytes to designated path.
        Returns: accessible URL or relative media path.
        """
        pass

    @abstractmethod
    def read(self, path: str) -> bytes:
        """Reads raw bytes from storage path."""
        pass

    @abstractmethod
    def delete(self, path: str) -> bool:
        """Permanently deletes file (for GDPR compliance)."""
        pass

    @abstractmethod
    def get_url(self, path: str) -> str:
        """Returns signed or public URL for client display."""
        pass
