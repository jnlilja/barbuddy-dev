from rest_framework import serializers
from .models import Bar, BarStatus
from django.contrib.auth import get_user_model

User = get_user_model()

class BarSerializer(serializers.ModelSerializer):
    location = serializers.SerializerMethodField()  # Convert GIS PointField
    users_at_bar = serializers.PrimaryKeyRelatedField(many=True, queryset=User.objects.all(), required=False)

    class Meta:
        model = Bar
        fields = "__all__"

    def get_location(self, obj):
        return {"latitude": obj.location.y, "longitude": obj.location.x} if obj.location else None


class BarStatusSerializer(serializers.ModelSerializer):
    bar = serializers.PrimaryKeyRelatedField(queryset=Bar.objects.all())

    class Meta:
        model = BarStatus
        fields = "__all__"