"""
Test settings for DocTalk backend.
Uses fast in-memory SQLite and mock services for instant isolated test execution.
"""
from .base import *

ENVIRONMENT = "test"
DEBUG = False

# Fast in-memory DB for automated testing
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
    }
}

# Fast password hasher for tests
PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.MD5PasswordHasher",
]

# Local storage for tests
STORAGE_BACKEND = "local"
MEDIA_ROOT = BASE_DIR / "test_media"

# In-memory Celery for tests
CELERY_TASK_ALWAYS_EAGER = True
CELERY_TASK_EAGER_PROPAGATES = True

# Disable throttling during test runs
REST_FRAMEWORK["DEFAULT_THROTTLE_CLASSES"] = []
