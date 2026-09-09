from django.urls import path
from django.http import JsonResponse

app_name = "chatbot"


def chat_status(request):
    return JsonResponse({"status": "available", "version": "1.0.0"})


urlpatterns = [
    path("status/", chat_status, name="chat_status"),
]
