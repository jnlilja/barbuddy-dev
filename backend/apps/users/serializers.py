from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.gis.geos import Point
from datetime import date

from apps.matches.models import Match
from apps.swipes.models import Swipe
from apps.swipes.serializers import SwipeSerializer
from apps.matches.serializers import MatchSerializer
from .models import FriendRequest, User, ProfilePicture  # Add ProfilePicture to imports


class ProfilePictureSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProfilePicture
        fields = ['id', 'image', 'is_primary', 'uploaded_at']
        read_only_fields = ['uploaded_at']


class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True)
    location = serializers.SerializerMethodField()
    matches = serializers.SerializerMethodField()
    swipes = serializers.SerializerMethodField()
    profile_pictures = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            "id", "username", "first_name", "last_name", "email", "password", "date_of_birth",
            "hometown", "job_or_university", "favorite_drink", "location",
            "profile_pictures", "matches", "swipes", "vote_weight", "account_type",
            "sexual_preference", "phone_number"
        ]
        extra_kwargs = {
            "password": {"write_only": True},
            "email": {"write_only": True}
        }
        read_only_fields = ["vote_weight"]

    def get_location(self, obj):
        if (obj.location):
            return {
                "latitude": obj.location.y,
                "longitude": obj.location.x
            }
        return None

    def get_profile_pictures(self, obj):
        pictures = obj.profile_pictures.all()
        return [
            {
                "id": pic.id,
                "url": pic.image.url,
                "is_primary": pic.is_primary,
            }
            for pic in pictures
        ]

    def get_swipes(self, obj):
        swipes = Swipe.objects.filter(swiper=obj)
        return [{"id": swipe.id, "status": swipe.status} for swipe in swipes]

    def get_matches(self, obj):
        matches = Match.objects.filter(
            (Q(user1=obj) | Q(user2=obj)) & Q(status="connected")
        )
        return [{"id": match.id, "status": match.status} for match in matches]

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

    def validate(self, data):
        instance = self.instance or User(**data)
        instance.clean()  # Explicitly call clean() here
        return data


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


class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True)
    confirm_password = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = [
            "username", "email", "password", "confirm_password",
            "first_name", "last_name", "date_of_birth",
            "hometown", "job_or_university", "favorite_drink",
            "sexual_preference", "phone_number"
        ]
        extra_kwargs = {
            "password": {"write_only": True},
            "email": {"required": True}
        }

    def validate(self, data):
        if data['password'] != data['confirm_password']:
            raise serializers.ValidationError({"password": "Passwords do not match"})
        return data

    def validate_date_of_birth(self, value):
        today = date.today()
        age = today.year - value.year - ((today.month, today.day) < (value.month, value.day))
        if age < 18:
            raise serializers.ValidationError("You must be at least 18 years old.")
        if age > 120:
            raise serializers.ValidationError("Age cannot exceed 120.")
        return value

    def create(self, validated_data):
        validated_data.pop('confirm_password')
        password = validated_data.pop('password')
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user

