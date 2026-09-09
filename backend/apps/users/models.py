"""
Custom User Model for DocTalk.
Tied directly to Firebase Authentication UID, supporting cross-platform profiles.
"""
import uuid
from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    """
    Central User model authenticated via Firebase.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    firebase_uid = models.CharField(max_length=128, unique=True, db_index=True)
    display_name = models.CharField(max_length=255, blank=True)
    phone_number = models.CharField(max_length=32, blank=True)
    avatar_url = models.URLField(max_length=500, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "User"
        verbose_name_plural = "Users"
        indexes = [
            models.Index(fields=["firebase_uid"]),
            models.Index(fields=["email"]),
        ]

    def __str__(self):
        return f"{self.display_name or self.email or self.firebase_uid} ({self.firebase_uid})"
