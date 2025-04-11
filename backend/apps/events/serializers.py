from rest_framework import serializers
from apps.events.models import Event
from django.utils.timezone import now

class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = "__all__"

    def validate_event_time(self, value):
        if value < now():
            raise serializers.ValidationError("Event time cannot be in the past.")
        return value

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data["bar_name"] = instance.bar.name  # Optional: show bar name
        return data
