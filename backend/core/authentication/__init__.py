"""
Authentication package for DocTalk backend.
"""
from .firebase import FirebaseAuthentication, FirebaseUser

__all__ = ["FirebaseAuthentication", "FirebaseUser"]
