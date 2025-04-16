from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.gis.geos import Point
from datetime import date

from apps.matches.models import Match
from apps.swipes.models import Swipe
from apps.swipes.serializers import SwipeSerializer
from apps.matches.serializers import MatchSerializer

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True)
    location = serializers.SerializerMethodField()
    matches = serializers.SerializerMethodField()
    swipes = serializers.SerializerMethodField()

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
            "email": {"write_only": True}
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
        today = date.today()
        age = today.year - value.year - ((today.month, today.day) < (value.month, value.day))
        if age < 18:
            raise serializers.ValidationError("You must be at least 18 years old.")
        if age > 120:
            raise serializers.ValidationError("Age cannot exceed 120.")
        return value

    def create(self, validated_data):
        password = validated_data.pop("password", None)
        user = User(**validated_data)
        if password:
            user.set_password(password)
        user.save()
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