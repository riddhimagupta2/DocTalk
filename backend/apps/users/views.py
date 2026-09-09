from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from core.utils.responses import success_response
from .serializers import UserProfileSerializer


class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserProfileSerializer(request.user)
        return success_response(serializer.data, message="User profile retrieved.")

    def patch(self, request):
        serializer = UserProfileSerializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return success_response(serializer.data, message="User profile updated.")
