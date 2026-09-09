"""
Shared abstract models for all DocTalk applications.
Provides standard timestamps, UUID primary keys, and soft deletion.
"""
import uuid
from django.db import models
from django.utils import timezone


class TimeStampedModel(models.Model):
    """Abstract model providing created_at and updated_at fields."""
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class UUIDModel(models.Model):
    """Abstract model using UUIDv4 as primary key."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    class Meta:
        abstract = True


class SoftDeletableModel(models.Model):
    """Abstract model enabling GDPR-compliant soft deletion."""
    is_deleted = models.BooleanField(default=False, db_index=True)
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        abstract = True

    def soft_delete(self):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.save(update_fields=["is_deleted", "deleted_at"])
