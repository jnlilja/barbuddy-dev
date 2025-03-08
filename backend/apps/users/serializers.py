from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)  # Secure password handling
    location = serializers.SerializerMethodField()  # Format location data

    class Meta:
        model = User
        fields = [
            "id", "username", "first_name", "last_name", "email", "password",
            "age", "height", "hometown", "job_or_university", "favorite_drink",
            "location", "profile_pictures", "matches", "swiped_users"]

        extra_kwargs = {"password": {"write_only": True}}

    def get_location(self, obj):
        """Serialize location as (latitude, longitude) instead of raw PointField."""
        return {"latitude": obj.location.y, "longitude": obj.location.x} if obj.location else None

    def create(self, validated_data):
        """Handle user creation with hashed password."""
        password = validated_data.pop("password", None)
        user = User.objects.create(**validated_data)
        if password:
            user.set_password(password)
            user.save()
        return user