"""
Firebase Authentication Backend for Django REST Framework.
Verifies Firebase ID Tokens issued by Firebase Auth in the Flutter client.
Attaches authenticated user to DRF requests.
"""
import os
from typing import Optional, Tuple
from django.contrib.auth import get_user_model
from django.conf import settings
from rest_framework.authentication import BaseAuthentication, get_authorization_header
from rest_framework.exceptions import AuthenticationFailed
from ..utils.logging import get_logger

logger = get_logger("core.authentication.firebase")

_firebase_app_initialized = False


def initialize_firebase_admin():
    """Initializes Firebase Admin SDK if not already configured."""
    global _firebase_app_initialized
    if _firebase_app_initialized:
        return

    import firebase_admin
    from firebase_admin import credentials

    if firebase_admin._apps:
        _firebase_app_initialized = True
        return

    cred_path = getattr(settings, "FIREBASE_CREDENTIALS_PATH", "")
    if cred_path and os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        _firebase_app_initialized = True
        logger.info("Firebase Admin initialized with certificate from %s", cred_path)
    else:
        # Fallback to default application credentials or project ID
        try:
            firebase_admin.initialize_app()
            _firebase_app_initialized = True
            logger.info("Firebase Admin initialized with application default credentials.")
        except Exception as e:
            logger.warning("Firebase Admin initialization deferred: %s", str(e))


class FirebaseUser:
    """Lightweight representation of Firebase authenticated user."""

    def __init__(self, uid: str, email: Optional[str] = None, name: Optional[str] = None):
        self.uid = uid
        self.email = email or ""
        self.name = name or ""
        self.is_authenticated = True

    def __str__(self):
        return f"FirebaseUser(uid={self.uid}, email={self.email})"


class FirebaseAuthentication(BaseAuthentication):
    """
    DRF Authentication class for Firebase ID Tokens.
    Header format: Authorization: Bearer <Firebase_ID_Token>
    """

    def authenticate(self, request) -> Optional[Tuple[object, dict]]:
        auth_header = get_authorization_header(request).split()

        if not auth_header:
            return None

        if len(auth_header) == 1:
            raise AuthenticationFailed("Invalid authorization header. No credentials provided.")
        elif len(auth_header) > 2:
            raise AuthenticationFailed("Invalid authorization header. Token string contains spaces.")

        prefix = auth_header[0].decode("utf-8").lower()
        if prefix != "bearer":
            return None

        id_token = auth_header[1].decode("utf-8")

        # In dev mode, handle dev test bypass token
        if getattr(settings, "DEBUG", False) and id_token.startswith("test_token_"):
            test_uid = id_token.replace("test_token_", "")
            User = get_user_model()
            user, _ = User.objects.get_or_create(
                firebase_uid=test_uid,
                defaults={"email": f"{test_uid}@example.com", "username": test_uid},
            )
            return (user, {"uid": test_uid, "email": user.email})

        # Initialize firebase admin
        initialize_firebase_admin()

        import firebase_admin
        from firebase_admin import auth

        try:
            decoded_token = auth.verify_id_token(id_token, check_revoked=True)
        except auth.ExpiredIdTokenError:
            logger.warning("Firebase ID Token expired.")
            raise AuthenticationFailed("Firebase token has expired. Please refresh your session.")
        except auth.RevokedIdTokenError:
            logger.warning("Firebase ID Token has been revoked.")
            raise AuthenticationFailed("Firebase token has been revoked. Please re-authenticate.")
        except auth.InvalidIdTokenError as e:
            logger.warning("Invalid Firebase ID Token: %s", str(e))
            raise AuthenticationFailed("Invalid Firebase authentication token.")
        except Exception as e:
            logger.error("Unexpected error verifying Firebase ID Token: %s", str(e))
            raise AuthenticationFailed("Authentication failed: Unable to verify credentials.")

        uid = decoded_token.get("uid")
        if not uid:
            raise AuthenticationFailed("Token contains no valid user identity.")

        email = decoded_token.get("email", "")
        name = decoded_token.get("name", "")

        # Sync or create local user
        User = get_user_model()
        user, created = User.objects.get_or_create(
            firebase_uid=uid,
            defaults={
                "username": uid[:150],
                "email": email,
                "display_name": name,
            },
        )
        if not created and email and user.email != email:
            user.email = email
            user.save(update_fields=["email"])

        return (user, decoded_token)

    def authenticate_header(self, request):
        return 'Bearer realm="api"'
