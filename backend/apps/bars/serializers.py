from rest_framework import serializers
from django.contrib.gis.geos import Point
from django.db.models import Avg
from django.contrib.auth import get_user_model

from .models import Bar, BarStatus, BarRating, BarVote, BarImage

User = get_user_model()

class BarImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = BarImage
        fields = ['id', 'image', 'caption', 'uploaded_at']


class BarSerializer(serializers.ModelSerializer):
    location = serializers.SerializerMethodField()
    users_at_bar = serializers.PrimaryKeyRelatedField(
        many=True, queryset=User.objects.all(), required=False
    )
    current_status = serializers.SerializerMethodField()
    average_rating = serializers.SerializerMethodField()
    images = BarImageSerializer(many=True, read_only=True)    # ← NEW

    class Meta:
        model = Bar
        fields = [
            'id', 'name', 'address', 'average_price',
            'location', 'users_at_bar', 'current_status',
            'average_rating', 'images',                   # ← NEW
        ]

    def get_location(self, obj):
        if not obj.location:
            return None
        return {
            "latitude": obj.location.y,
            "longitude": obj.location.x
        }

    def get_current_status(self, obj):
        return obj.get_latest_status()

    def get_average_rating(self, obj):
        avg = obj.ratings.aggregate(Avg("rating"))["rating__avg"]
        return round(avg, 2) if avg is not None else None

    def validate_users_at_bar(self, value):
        return value  # front‑end managed

    def to_internal_value(self, data):
        iv = super().to_internal_value(data)
        loc = data.get("location")
        if isinstance(loc, dict):
            try:
                lat = float(loc["latitude"])
                lon = float(loc["longitude"])
                iv["location"] = Point(lon, lat, srid=4326)
            except Exception:
                raise serializers.ValidationError({
                    "location": "Latitude and longitude must be valid numbers."
                })
        return iv

    def update(self, instance, validated_data):
        users = validated_data.pop('users_at_bar', None)
        for attr, val in validated_data.items():
            setattr(instance, attr, val)
        if users is not None:
            instance.users_at_bar.set(users)
        instance.save()
        return instance


class BarStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = BarStatus
        fields = ['id', 'bar', 'crowd_size', 'wait_time', 'last_updated']


class BarRatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = BarRating
        fields = ['id', 'bar', 'user', 'rating', 'review', 'timestamp']
        read_only_fields = ['user']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)


class BarVoteSerializer(serializers.ModelSerializer):
    user = serializers.HiddenField(default=serializers.CurrentUserDefault())

    class Meta:
        model = BarVote
        fields = ['id', 'bar', 'user', 'crowd_size', 'wait_time', 'timestamp']
        read_only_fields = ['timestamp']

    def validate(self, data):
        if data.get('bar') is None:
            raise serializers.ValidationError("A bar must be specified.")
        return data
