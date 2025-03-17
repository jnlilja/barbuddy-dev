from rest_framework import viewsets
from django.contrib.auth import get_user_model
from .serializers import BarSerializer, BarStatusSerializer
from .models import Bar, BarStatus


User = get_user_model()

class BarViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing bars.
    Supports listing, creating, retrieving, updating, and deleting bars.
    """
    queryset = Bar.objects.all()
    serializer_class = BarSerializer

    def get_queryset(self):
        """
        Optionally filter bars based on user location or preferences.
        """
        return Bar.objects.all()

class BarStatusViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing bar status updates.
    """
    queryset = BarStatus.objects.all()
    serializer_class = BarStatusSerializer

