from rest_framework import serializers
from .models import Message, GroupChat, GroupMessage
from django.contrib.auth import get_user_model

User = get_user_model()

class MessageSerializer(serializers.ModelSerializer):
    sender_username = serializers.CharField(source='sender.username', read_only=True)
    recipient_username = serializers.CharField(source='recipient.username', read_only=True)

    class Meta:
        model = Message
        fields = ['id', 'sender', 'recipient', 'content', 'timestamp', 'is_read', 
                 'sender_username', 'recipient_username']
        read_only_fields = ['sender', 'timestamp', 'is_read']

    def validate_content(self, value):
        """Ensure message is not empty."""
        if not value.strip():
            raise serializers.ValidationError("Message content cannot be empty.")
        return value

class GroupChatUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'last_name']

class GroupChatSerializer(serializers.ModelSerializer):
    members = serializers.PrimaryKeyRelatedField(many=True, queryset=User.objects.all())

    class Meta:
        model = GroupChat
        fields = ['id', 'name', 'members', 'created_at']
        read_only_fields = ['created_at']

    def validate_members(self, value):
        """Ensure at least 2 members in group chat."""
        if len(value) < 2:
            raise serializers.ValidationError("A group chat must have at least 2 members.")
        return value

    def validate_name(self, value):
        """Ensure name is not empty."""
        if not value.strip():
            raise serializers.ValidationError("Group chat name cannot be empty.")
        return value

class GroupMessageSerializer(serializers.ModelSerializer):
    sender_username = serializers.CharField(source='sender.username', read_only=True)
    group_name = serializers.CharField(source='group.name', read_only=True)

    class Meta:
        model = GroupMessage
        fields = ['id', 'group', 'sender', 'content', 'timestamp', 'sender_username', 'group_name']
        read_only_fields = ['sender', 'timestamp']

    def validate_content(self, value):
        """Ensure message is not empty."""
        if not value.strip():
            raise serializers.ValidationError("Message content cannot be empty.")
        return value

class PusherEventSerializer(serializers.Serializer):
    """Serializer for Pusher event data."""
    channel = serializers.CharField()
    event = serializers.CharField()
    data = serializers.JSONField()

class PusherUnsubscribeSerializer(serializers.Serializer):
    """Serializer for Pusher unsubscribe data."""
    channel = serializers.CharField()
