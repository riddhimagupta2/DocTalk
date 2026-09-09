from django.urls import path
from django.http import JsonResponse

app_name = "appointments"


def appointments_status(request):
    return JsonResponse({"status": "available", "version": "1.0.0"})


urlpatterns = [
    path("status/", appointments_status, name="appointments_status"),
]
