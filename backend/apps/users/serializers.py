from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.gis.geos import Point
from datetime import date
from django.core.validators import RegexValidator

from apps.matches.models import Match
from apps.swipes.models import Swipe
from apps.swipes.serializers import SwipeSerializer
from apps.matches.serializers import MatchSerializer
from .models import FriendRequest, ProfilePicture


User = get_user_model()

class ProfilePictureSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProfilePicture
        fields = ["id", "image", "is_primary"]

class UserSerializer(serializers.ModelSerializer):
    username = serializers.CharField(
        validators=[
            RegexValidator(
                regex='^[a-zA-Z0-9_]{3,30}$',
                message='Username must be 3-30 characters long and contain only letters, numbers, and underscores'
            )
        ]
    )
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, min_length=8)
    location = serializers.SerializerMethodField()
    matches = serializers.SerializerMethodField()
    swipes = serializers.SerializerMethodField()
    profile_pictures = ProfilePictureSerializer(many=True, read_only=True)

    class Meta:
        model = User
        fields = [
            "id", "username", "first_name", "last_name", "email", "password", "date_of_birth",
            "hometown", "job_or_university", "favorite_drink", "location",
            "profile_pictures", "matches", "swipes", "vote_weight", "account_type",
            "sexual_preference"  
        ]
        extra_kwargs = {
            "password": {"write_only": True},
            "email": {"write_only": True},
            "date_of_birth": {"required": True},
            "hometown": {"required": True},
            "job_or_university": {"required": True},
            "favorite_drink": {"required": True},
            "sexual_preference": {"required": True}
        }
        read_only_fields = ["vote_weight"]

    def get_location(self, obj):
        if obj.location:
            return {
                "latitude": obj.location.y,
                "longitude": obj.location.x
            }
        return None

    def get_matches(self, obj):
        matches = Match.objects.filter(user1=obj, status='connected') | Match.objects.filter(user2=obj, status='connected')
        return MatchSerializer(matches.distinct(), many=True).data

    def get_swipes(self, obj):
        swipes = Swipe.objects.filter(swiper=obj)
        return SwipeSerializer(swipes, many=True).data

    def to_internal_value(self, data):
        validated_data = super().to_internal_value(data)
        raw_location = self.initial_data.get('location')

        if raw_location:
            try:
                lat = raw_location['latitude']
                lon = raw_location['longitude']
                validated_data['location'] = Point(lon, lat, srid=4326)
            except (KeyError, TypeError):
                raise serializers.ValidationError({"location": "Must include 'latitude' and 'longitude'"})

        return validated_data

    def validate_date_of_birth(self, value):
        from dateutil.relativedelta import relativedelta
        
        age = relativedelta(date.today(), value).years
        if age < 18:
            raise serializers.ValidationError("User must be at least 18 years old")
        return value

    def validate_sexual_preference(self, value):
        valid_preferences = ['straight', 'gay', 'bisexual', 'other']
        if value.lower() not in valid_preferences:
            raise serializers.ValidationError(
                f"Sexual preference must be one of: {', '.join(valid_preferences)}"
            )
        return value.lower()

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

    def update(self, instance, validated_data):
        password = validated_data.pop("password", None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        if password:
            instance.set_password(password)
        instance.save()
        return instance

    def get_match_count(self, obj):
        return Match.objects.filter(user1=obj, status='connected').count() + \
               Match.objects.filter(user2=obj, status='connected').count()



class UserLocationUpdateSerializer(serializers.Serializer):
    latitude = serializers.FloatField()
    longitude = serializers.FloatField()

    def update(self, instance, validated_data):
        instance.location = Point(
            validated_data['longitude'],
            validated_data['latitude'],
            srid=4326
        )
        instance.save()
        return instance


class FriendRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = FriendRequest
        fields = ['id', 'from_user', 'to_user', 'status', 'timestamp']
        read_only_fields = ['from_user', 'timestamp', 'status']

