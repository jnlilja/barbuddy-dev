from rest_framework import serializers
from django.utils.timezone import now
from apps.events.models import Event

class EventSerializer(serializers.ModelSerializer):
    is_today = serializers.SerializerMethodField()
    bar_name = serializers.SerializerMethodField()

    class Meta:
        model = Event
        # only expose the below fields on input/output
        fields = [
            "id",
            "bar",
            "event_name",
            "event_time",
            "event_description",
            "is_today",
            "bar_name",
        ]
        extra_kwargs = {
            # make the model‐required fields _not_ required by the serializer
            "day_of_week": {"required": False},
            "category":    {"required": False},
        }

    def validate_event_time(self, value):
        if value < now():
            raise serializers.ValidationError("Event time cannot be in the past.")
        return value

    def get_is_today(self, obj):
        return obj.is_today

    def get_bar_name(self, obj):
        return obj.bar.name

    def create(self, validated_data):
        # Auto‐derive the missing model fields
        event_time = validated_data["event_time"]
        validated_data["day_of_week"] = event_time.strftime("%A")
        validated_data["category"]    = validated_data.get("category", "BLUE")
        return super().create(validated_data)

    def update(self, instance, validated_data):
        # If the client changes the time, re‐derive the weekday
        if "event_time" in validated_data:
            validated_data["day_of_week"] = validated_data["event_time"].strftime("%A")
        # Leave category alone unless explicitly passed
        return super().update(instance, validated_data)
