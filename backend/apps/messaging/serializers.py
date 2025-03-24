from rest_framework import serializers
from .models import Message, GroupChat
from django.contrib.auth import get_user_model

User = get_user_model()

class MessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.SerializerMethodField()
    receiver_name = serializers.SerializerMethodField()
    group_chat_name = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = ['id', 'sender', 'sender_name', 'receiver', 'receiver_name',
                  'group_chat', 'group_chat_name', 'message_text', 'timestamp']

    def validate_message_text(self, value):
        """Ensure message is not empty."""
        if not value.strip():
            raise serializers.ValidationError("Message text cannot be empty.")
        return value

    def get_sender_name(self, obj):
        return obj.sender.username

    def get_receiver_name(self, obj):
        return obj.receiver.username if obj.receiver else None

    def get_group_chat_name(self, obj):
        return obj.group_chat.get_display_name() if obj.group_chat else None


class GroupChatUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'last_name']

class GroupChatSerializer(serializers.ModelSerializer):
    users = GroupChatUserSerializer(many=True, read_only=True)
    users_ids = serializers.PrimaryKeyRelatedField(many=True, queryset=User.objects.all(),
                                                   source='users', write_only=True)

    class Meta:
        model = GroupChat
        fields = ['id', 'name', 'bar', 'users', 'users_ids', 'creator', 'created_at']

    def validate_users_ids(self, value):
        """Ensure at least 2 members in group chat."""
        if len(value) < 2:
            raise serializers.ValidationError("A group chat must have at least 2 members.")
        return value
