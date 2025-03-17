from rest_framework import serializers
from .models import Bar, BarStatus
from django.contrib.gis.geos import Point
from django.db.models import Avg
from django.contrib.auth import get_user_model

User = get_user_model()

class BarSerializer(serializers.ModelSerializer):
    location = serializers.SerializerMethodField()
    users_at_bar = serializers.PrimaryKeyRelatedField(many=True, queryset=User.objects.all(), required=False)
    current_status = serializers.SerializerMethodField()
    average_rating = serializers.SerializerMethodField()

    class Meta:
        model = Bar
        fields = ['id', 'name', 'address', 'music_genre', 'average_price',
                  'location', 'users_at_bar', 'current_status', 'average_rating']

    def get_location(self, obj):
        return {"latitude": obj.location.y, "longitude": obj.location.x} if obj.location else None

    def get_current_status(self, obj):
        status = obj.get_latest_status()
        return status if status else None

    def get_average_rating(self, obj):
        """Optimize rating retrieval using aggregate()."""
        average = obj.ratings.aggregate(Avg("rating"))["rating__avg"]
        return round(average, 2) if average else None

    def to_internal_value(self, data):
        """Convert latitude/longitude dictionary into a GIS Point object."""
        if "location" in data and isinstance(data["location"], dict):
            try:
                lat = float(data["location"].get("latitude"))
                lon = float(data["location"].get("longitude"))
                if lat is None or lon is None:
                    raise ValueError()
                data["location"] = Point(lon, lat, srid=4326)
            except (TypeError, ValueError):
                raise serializers.ValidationError({"location": "Latitude and longitude must be valid numbers."})
        return super().to_internal_value(data)


class BarStatusSerializer(serializers.ModelSerializer):
    bar = serializers.PrimaryKeyRelatedField(queryset=Bar.objects.all())

    class Meta:
        model = BarStatus
        fields = "__all__"