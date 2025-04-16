from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from django.db.models import Q

from rest_framework_simplejwt.authentication import JWTAuthentication
from apps.matches.models import Match
from apps.matches.serializers import MatchSerializer
from .serializers import UserSerializer, UserLocationUpdateSerializer
from .permissions import IsOwnerOrReadOnly
from .authentication import FirebaseAuthentication

User = get_user_model()

class UserViewSet(viewsets.ModelViewSet):
    authentication_classes = [JWTAuthentication, FirebaseAuthentication]
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_queryset(self):
        user = self.request.user
        if not user or not user.is_authenticated:
            return User.objects.none()
        if user.is_superuser:
            return User.objects.all()
        return User.objects.filter(id=user.id)

    # GET /api/users/location
    @action(detail=False, methods=["get"], permission_classes=[permissions.IsAuthenticated])
    def location(self, request):
        user = request.user
        if user.location:
            return Response({
                "latitude": user.location.y,
                "longitude": user.location.x
            })
        return Response({"error": "Location not set."}, status=400)

    # GET /api/users/{id}/matches/
    @action(detail=True, methods=["get"], permission_classes=[permissions.IsAuthenticated])
    def matches(self, request, pk=None):
        user = self.get_object()
        matches = Match.objects.filter(
            (Q(user1=user) | Q(user2=user)) & Q(status="connected")
        )
        serializer = MatchSerializer(matches, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=["post"], permission_classes=[permissions.IsAuthenticated])
    def update_location(self, request):
        serializer = UserLocationUpdateSerializer(data=request.data)
        if serializer.is_valid():
            serializer.update(request.user, serializer.validated_data)
            return Response({"status": "Location updated successfully."})
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)