from rest_framework import serializers
from .models import Bar
from apps.users.serializers import UserSerializer

class BarSerializer(serializers.ModelSerializer):
    users_at_bar = UserSerializer(many=True, read_only=True)

    class Meta:
        model = Bar
        fields = '__all__'