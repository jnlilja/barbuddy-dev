from rest_framework import viewsets, permissions
from .models import Match
from .serializers import MatchSerializer
from django.db.models import Q
from rest_framework.decorators import action
from rest_framework.response import Response


class MatchViewSet(viewsets.ModelViewSet):
    serializer_class = MatchSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if getattr(self, 'swagger_fake_view', False):
            return Match.objects.none()
        
        user = self.request.user
        # Filter matches where the user is either user1 or user2
        # This ensures that the user can only see their own matches
        # and not matches involving other users
        return Match.objects.filter(Q(user1=user) | Q(user2=user))


    @action(detail=False, methods=["get"])
    def mutual(self, request):
        user = request.user
        matches = Match.objects.filter(
            status='connected'
        ).filter(
            Q(user1=user) | Q(user2=user)
        )
        serializer = self.get_serializer(matches, many=True)
        return Response(serializer.data)