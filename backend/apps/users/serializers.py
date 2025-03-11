from django.contrib.auth import get_user_model
from rest_framework import serializers

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        # Include any extra fields if needed, for example: 'age', 'hometown', etc.
        fields = ('id', 'username', 'email', 'password', 'age', 'height', 'hometown', 'job_or_university', 'favorite_drink', 'location', 'profile_pictures')

    def create(self, validated_data):
        # Use create_user to handle password hashing and default fields (like is_active)
        user = User.objects.create_user(**validated_data)
        return user
