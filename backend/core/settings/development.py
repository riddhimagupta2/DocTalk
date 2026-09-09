"""
Development settings for DocTalk backend.
"""
import os
from .base import *

ENVIRONMENT = "development"
DEBUG = True

# In dev, allow CORS from all origins for easy emulator / mobile testing
CORS_ALLOW_ALL_ORIGINS = True

# Allow all hosts in dev
ALLOWED_HOSTS = ["*"]

# In local development, use SQLite unless PostgreSQL is explicitly requested
if os.getenv("USE_POSTGRESQL", "False").lower() not in ("true", "1"):
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": BASE_DIR / "db.sqlite3",
        }
    }
