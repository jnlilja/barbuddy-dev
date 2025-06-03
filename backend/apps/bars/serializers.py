from rest_framework import serializers
from django.contrib.gis.geos import Point
from django.db.models import Avg
from django.contrib.auth import get_user_model

from .models import Bar, BarStatus, BarRating, BarVote, BarImage, BarHours, BarCrowdSize

User = get_user_model()

class BarImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = BarImage
        fields = ['id', 'image', 'caption', 'uploaded_at']


# First, create a serializer for the status object 
class BarStatusSerializer(serializers.ModelSerializer):
    # Add a numeric representation of crowd_size
    
    class Meta:
        model = BarStatus
        fields = ['id', 'bar', 'crowd_size',  'wait_time', 'last_updated']
    
    def get_crowd_size_value(self, obj):
        """Convert string crowd_size to integer for mobile clients"""
        crowd_size_map = {
            'empty': 0,
            'light': 1,
            'moderate': 2,
            'busy': 3,
            'packed': 4
        }
        
        if obj.crowd_size:
            return crowd_size_map.get(obj.crowd_size.lower(), 2)  # default to moderate (2) if unknown value
        return None


# Create a separate serializer specifically for nested use in BarSerializer
class BarStatusInfoSerializer(serializers.Serializer):
    crowd_size = serializers.CharField(allow_null=True)
    wait_time = serializers.CharField(allow_null=True)
    last_updated = serializers.DateTimeField(allow_null=True)
        
class BarSerializer(serializers.ModelSerializer):
    # Add latitude/longitude fields to the serializer
    latitude = serializers.FloatField(write_only=True)
    longitude = serializers.FloatField(write_only=True)
    location = serializers.SerializerMethodField()
    users_at_bar = serializers.PrimaryKeyRelatedField(
        many=True, queryset=User.objects.all(), required=False
    )
    # Use the new info serializer that explicitly defines fields for better Swagger documentation
    current_status = serializers.SerializerMethodField()
    average_rating = serializers.SerializerMethodField()
    images = BarImageSerializer(many=True, read_only=True)
    current_user_count = serializers.SerializerMethodField()
    activity_level = serializers.SerializerMethodField()

    class Meta:
        model = Bar
        fields = [
            'id', 'name', 'address', 'average_price',
            'latitude', 'longitude', 'location',  # Add lat/lon to fields
            'users_at_bar', 'current_status',
            'average_rating', 'images',
            'current_user_count',
            'activity_level'
        ]
    
    def get_current_status(self, obj):
        status = obj.get_latest_status()
        if not status:
            return {
                "crowd_size": None,
                "crowd_size_value": None,
                "wait_time": None,
                "last_updated": None
            }
        
        return {
            "crowd_size": status.get('crowd_size'),
            "wait_time": status.get('wait_time'),
            "last_updated": status.get('last_updated')
        }

    def get_location(self, obj):
        if not obj.location:
            return None
        return {
            "latitude": obj.location.y,
            "longitude": obj.location.x
        }

    def get_average_rating(self, obj):
        avg = obj.ratings.aggregate(Avg("rating"))["rating__avg"]
        return round(avg, 2) if avg is not None else None

    def get_current_user_count(self, obj):
        return obj.current_user_count

    def get_activity_level(self, obj):
        return obj.get_activity_level()

    def validate_users_at_bar(self, value):
        return value  # front‑end managed

    def validate(self, data):
        """Ensure both latitude and longitude are provided."""
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        
        if latitude is None or longitude is None:
            raise serializers.ValidationError({
                "location": "Both latitude and longitude are required."
            })

        # Create Point object from coordinates
        data['location'] = Point(
            x=longitude,  # longitude goes first (x)
            y=latitude,   # latitude goes second (y)
            srid=4326     # standard GPS coordinate system
        )
        
        return data

    def create(self, validated_data):
        # Remove lat/lon since they're not model fields
        latitude = validated_data.pop('latitude', None)
        longitude = validated_data.pop('longitude', None)
        return super().create(validated_data)

    def update(self, instance, validated_data):
        # Remove lat/lon since they're not model fields
        latitude = validated_data.pop('latitude', None)
        longitude = validated_data.pop('longitude', None)
        users = validated_data.pop('users_at_bar', None)
        for attr, val in validated_data.items():
            setattr(instance, attr, val)
        if users is not None:
            instance.users_at_bar.set(users)
        instance.save()
        return instance




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
        fields = ['id', 'bar', 'user', 'wait_time', 'timestamp']
        read_only_fields = ['timestamp']

    def validate(self, data):
        if data.get('bar') is None:
            raise serializers.ValidationError("A bar must be specified.")
        return data


class BarCrowdSizeSerializer(serializers.ModelSerializer):
    user = serializers.HiddenField(default=serializers.CurrentUserDefault())

    class Meta:
        model = BarCrowdSize
        fields = ['id', 'bar', 'user', 'crowd_size', 'timestamp']
        read_only_fields = ['timestamp']

    def validate(self, data):
        if data.get('bar') is None:
            raise serializers.ValidationError("A bar must be specified.")
        return data

class BarHoursSerializer(serializers.ModelSerializer):
    class Meta:
        model = BarHours
        fields = ['id', 'bar', 'day', 'open_time', 'close_time', 'is_closed']
        read_only_fields = ['id']

    def validate(self, data):
        # Remove the validation that prevents close time from being before open time
        # This allows for overnight hours (e.g., 11am-2am)
        return data
