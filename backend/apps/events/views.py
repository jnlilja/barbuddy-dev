from rest_framework import viewsets
from apps.events.models import Event, EventAttendee
from apps.events.serializers import EventSerializer, EventAttendeeSerializer

class EventViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing events at bars.
    Supports creating, listing, retrieving, and deleting events.
    """
    queryset = Event.objects.all()
    serializer_class = EventSerializer

class EventAttendeeViewSet(viewsets.ModelViewSet):
    queryset = EventAttendee.objects.all()
    serializer_class = EventAttendeeSerializer
