from rest_framework import viewsets, permissions
from django.contrib.auth import get_user_model
from rest_framework.decorators import action
from rest_framework.response import Response
from apps.matches.models import Match
from apps.matches.serializers import MatchSerializer
from .serializers import UserSerializer

User = get_user_model()
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    # Custom action: Retrieve matches for a user
    @action(detail=True, methods=["get"])
    def matches(self, request, pk=None):
        user = self.get_object()
        matches = Match.objects.filter(user1=user, status="connected") | Match.objects.filter(user2=user, status="connected")
        serializer = MatchSerializer(matches, many=True)
        return Response(serializer.data)

class UserViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing users.
    Supports listing, retrieving, updating, and deleting users.
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_queryset(self):
        """
        Optionally filter user details (e.g., restrict data for non-admins).
        """
        if self.request.user.is_authenticated:
            return User.objects.all()
        return User.objects.none()

