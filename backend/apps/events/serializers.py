from rest_framework import serializers
from apps.events.models import Event, EventAttendee
from django.contrib.auth import get_user_model
from django.utils.timezone import now

User = get_user_model()

class EventSerializer(serializers.ModelSerializer):
    attendees = serializers.PrimaryKeyRelatedField(many=True, queryset=User.objects.all(), required=False)

    class Meta:
        model = Event
        fields = "__all__"

    def validate_event_time(self, value):
        if value < now():
            raise serializers.ValidationError("Event time cannot be in the past.")
        return value

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data["bar_name"] = instance.bar.name  # Include the bar name
        data["attendee_count"] = instance.attendees.count()
        return data


# ✅ Serializer for Event Attendee
class EventAttendeeSerializer(serializers.ModelSerializer):
    event = serializers.PrimaryKeyRelatedField(queryset=Event.objects.all())
    user = serializers.PrimaryKeyRelatedField(queryset=User.objects.all())

    class Meta:
        model = EventAttendee
        fields = ["id", "event", "user"]

    def to_representation(self, instance):
        """Customize the response"""
        data = super().to_representation(instance)
        data["event_name"] = instance.event.event_name  # Include event name
        data["user_name"] = instance.user.get_full_name() if instance.user.get_full_name() else instance.user.username
        return data
