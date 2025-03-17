from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.gis.geos import Point
from apps.matches.models import Match
from apps.matches.serializers import MatchSerializer

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)  # Secure password handling
    location = serializers.SerializerMethodField()  # Format location data
    matches = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            "id", "username", "first_name", "last_name", "email", "password",
            "date_of_birth", "height", "hometown", "job_or_university", "favorite_drink",
            "location", "profile_pictures", "matches"
        ]

        extra_kwargs = {
            "password": {"write_only": True},
            "email": {"write_only": True}
        }

    def get_matches(self, obj):
        """ Fetch matches where the user is either user1 or user2. """
        matches = Match.objects.filter(user1=obj, status='connected') | Match.objects.filter(user2=obj, status='connected')
        return MatchSerializer(matches.distinct(), many=True).data  # .distinct() prevents duplicate results

    def get_location(self, obj):
        """Serialize location as (latitude, longitude) instead of raw PointField."""
        return {"latitude": obj.location.y, "longitude": obj.location.x} if obj.location else None

    def to_internal_value(self, data):
        """Convert latitude/longitude input to a GIS PointField."""
        data = super().to_internal_value(data)
        location_data = data.pop('location', None)

        if location_data:
            latitude = location_data.get('latitude')
            longitude = location_data.get('longitude')
            if latitude is None or longitude is None:
                raise serializers.ValidationError({"location": "Both latitude and longitude must be provided."})
            data['location'] = Point(longitude, latitude, srid=4326)

        return data

    def validate_age(self, value):
        if value < 18 or value > 120:
            raise serializers.ValidationError("Age must be between 18 and 120.")
        return value

    def get_match_count(self, obj):
        """Count only matches where status is 'connected'."""
        return Match.objects.filter(user1=obj, status='connected').count() + \
               Match.objects.filter(user2=obj, status='connected').count()

    def update(self, instance, validated_data):
        """Ensure password is hashed when updating."""
        password = validated_data.pop("password", None)
        instance = super().update(instance, validated_data)

        if password:
            instance.set_password(password)
            instance.save()

        return instance

    def create(self, validated_data):
        """Handle user creation with hashed password."""
        password = validated_data.pop("password", None)
        user = User.objects.create(**validated_data)
        if password:
            user.set_password(password)
            user.save()
        return user