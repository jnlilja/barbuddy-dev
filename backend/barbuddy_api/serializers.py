from django.contrib.auth import get_user_model
from rest_framework import serializers

User = get_user_model()  # This retrieves the correct user model

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'password')

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email'),
            password=validated_data['password']
        )

        user.is_active = True
        user.save()
        return user


