from rest_framework import serializers
from .models import User


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            "id",
            "firebase_uid",
            "email",
            "display_name",
            "phone_number",
            "avatar_url",
            "created_at",
        ]
        read_only_fields = ["id", "firebase_uid", "created_at"]
