from rest_framework import viewsets
from apps.events.models import Event
from apps.events.serializers import EventSerializer

class EventViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing events at bars.
    Supports creating, listing, retrieving, and deleting events.
    """    
    queryset = Event.objects.all().order_by('-event_time')
    serializer_class = EventSerializer

    def get_queryset(self):
        queryset = Event.objects.all()
        bar_id = self.request.query_params.get("bar")
        if bar_id:
            queryset = queryset.filter(bar__id=bar_id)
        return queryset

