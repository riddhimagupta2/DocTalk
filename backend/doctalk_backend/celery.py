"""
Celery configuration for DocTalk backend.
Handles asynchronous background medical image processing, AI triage, and webhook notifications.
"""
import os
from celery import Celery

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "core.settings.development")

app = Celery("doctalk_backend")

# Read config from Django settings with CELERY_ namespace
app.config_from_object("django.conf:settings", namespace="CELERY")

# Auto-discover tasks in all registered apps
app.autodiscover_tasks()


@app.task(bind=True, ignore_result=True)
def debug_task(self):
    print(f"Request: {self.request!r}")
