from rest_framework import serializers
from apps.matches.models import Match
from django.contrib.auth import get_user_model

User = get_user_model()

class MatchUserSerializer(serializers.ModelSerializer):
    """Simplified user representation for matches"""
    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'last_name', 'profile_pictures']


class MatchSerializer(serializers.ModelSerializer):
    user1_details = MatchUserSerializer(source='user1', read_only=True)
    user2_details = MatchUserSerializer(source='user2', read_only=True)
    disconnected_by_username = serializers.SerializerMethodField()

    class Meta:
        model = Match
        fields = ['id', 'user1', 'user1_details', 'user2', 'user2_details',
                  'status', 'created_at', 'disconnected_by', 'disconnected_by_username']

        extra_kwargs = {
            'user1': {'write_only': True},
            'user2': {'write_only': True},
            'disconnected_by': {'write_only': True}
        }

    def get_disconnected_by_username(self, obj):
        return obj.disconnected_by.username if obj.disconnected_by else None

    def validate(self, data):
        # Add validation to prevent self-matching
        if data.get('user1') == data.get('user2'):
            raise serializers.ValidationError("A user cannot match with themselves.")

        # Ensure disconnected_by is set only when status is 'disconnected'
        if data.get('disconnected_by') and data.get('status') != 'disconnected':
            raise serializers.ValidationError(
                "Disconnected_by can only be set when status is 'disconnected'."
            )

        return data
