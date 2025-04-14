from rest_framework import viewsets, permissions
from django.contrib.auth import get_user_model
from rest_framework.decorators import action
from rest_framework.response import Response
from apps.matches.models import Match
from apps.matches.serializers import MatchSerializer
from .serializers import UserSerializer
from .permissions import IsOwnerOrReadOnly
from django.db.models import Q

User = get_user_model()

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]

    def get_queryset(self):
        if self.request.user.is_superuser:
            return User.objects.all()
        return User.objects.filter(id=self.request.user.id)

    # GET /api/users/{id}/matches/
    @action(detail=True, methods=["get"])
    def matches(self, request, pk=None):
        user = self.get_object()
        matches = Match.objects.filter(
            (Q(user1=user) | Q(user2=user)) & Q(status="connected")
        )
        serializer = MatchSerializer(matches, many=True)
        return Response(serializer.data)
