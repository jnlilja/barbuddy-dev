from rest_framework import viewsets, permissions
from .models import Match
from .serializers import MatchSerializer

class MatchViewSet(viewsets.ModelViewSet):
    serializer_class = MatchSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        #swagger schma generation
        if getattr(self, 'swagger_fake_view', False):
            return Match.objects.none()
        
        user = self.request.user
        return Match.objects.filter(user1=user) | Match.objects.filter(user2=user)

