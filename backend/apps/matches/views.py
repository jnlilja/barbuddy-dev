from rest_framework import viewsets
from .models import Match
from .serializers import MatchSerializer

class MatchViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing user matches.
    Users can initiate, accept, or remove matches.
    """
    queryset = Match.objects.all()
    serializer_class = MatchSerializer

