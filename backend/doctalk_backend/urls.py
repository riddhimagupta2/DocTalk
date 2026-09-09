"""
Root URL Configuration for DocTalk Backend.
Features unified, versioned API routing: /api/v1/
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import JsonResponse


def health_check(request):
    """Liveness & readiness probe for load balancers & monitoring."""
    return JsonResponse(
        {
            "status": "healthy",
            "service": "DocTalk Central API",
            "version": "1.0.0",
            "environment": getattr(settings, "ENVIRONMENT", "development"),
        }
    )


urlpatterns = [
    path("admin/", admin.site.urls),
    path("health/", health_check, name="health_check"),
    # API v1 Versioned endpoints
    path("api/v1/image-analysis/", include("apps.image_analysis.urls")),
    path("api/v1/users/", include("apps.users.urls")),
    path("api/v1/chat/", include("apps.chatbot.urls")),
    path("api/v1/appointments/", include("apps.appointments.urls")),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
