"""
DocTalk Backend Package.
Production-ready central healthcare API backend for mobile telemedicine & AI services.
"""
from .celery import app as celery_app

__all__ = ("celery_app",)
