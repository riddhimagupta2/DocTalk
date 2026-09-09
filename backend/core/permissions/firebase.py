"""
Permission classes and throttling for Firebase authenticated endpoints.
Enforces ownership isolation and rate limits per user.
"""
from rest_framework.permissions import BasePermission
from rest_framework.throttling import UserRateThrottle
from django.conf import settings


class IsFirebaseAuthenticated(BasePermission):
    """Allows access only to authenticated Firebase users."""

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated)


class IsAnalysisOwner(BasePermission):
    """Ensures a user can only access or delete their own medical analyses."""

    def has_object_permission(self, request, view, obj):
        user_uid = getattr(request.user, "firebase_uid", str(request.user.pk))
        return obj.user_firebase_uid == user_uid


class ImageAnalysisRateThrottle(UserRateThrottle):
    """
    Limits medical image analysis submissions per user (e.g. 15/hour)
    to prevent AI abuse and API quota exhaustion.
    """
    scope = "image_analysis"

    def get_cache_key(self, request, view):
        if request.user and request.user.is_authenticated:
            ident = getattr(request.user, "firebase_uid", str(request.user.pk))
            return self.cache_format % {"scope": self.scope, "ident": ident}
        return self.get_ident(request)
