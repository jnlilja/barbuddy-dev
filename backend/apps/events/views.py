from rest_framework import viewsets
from apps.events.models import Event
from apps.events.serializers import EventSerializer
from django.utils.timezone import now

class EventViewSet(viewsets.ModelViewSet):
    queryset = Event.objects.all().order_by('-event_time')
    serializer_class = EventSerializer

    def get_queryset(self):
        queryset = Event.objects.all()

        bar_id = self.request.query_params.get("bar")
        if bar_id:
            queryset = queryset.filter(bar__id=bar_id)

        filter_today = self.request.query_params.get("today")
        if filter_today == "true":
            today = now().strftime("%A")  # e.g. "Thursday"
            queryset = queryset.filter(day_of_week=today)

        return queryset


    def get_queryset(self):
        qs = super().get_queryset()
        if self.request.query_params.get("today") == "true":
            today_name = timezone.now().strftime("%A")
            qs = qs.filter(day_of_week=today_name)
        return qs