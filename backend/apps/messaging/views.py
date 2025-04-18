from rest_framework import viewsets, permissions, status
from .models import Message, GroupChat, GroupMessage
from .serializers import (
    MessageSerializer,
    GroupChatSerializer,
    GroupMessageSerializer,
    PusherEventSerializer,
    PusherUnsubscribeSerializer
)
from .permissions import IsGroupMember, IsSenderOrReceiver
from apps.services.pusher_client import send_message, unsubscribe_channel
from rest_framework.decorators import action
from rest_framework.response import Response
from apps.matches.models import Match
from rest_framework.exceptions import PermissionDenied
from django.db import models

class PusherViewSet(viewsets.ViewSet):
    """
    ViewSet for handling Pusher-related operations.
    """
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['post'])
    def trigger(self, request):
        """
        Trigger a Pusher event.
        Required data:
        {
            "channel": "channel-name",
            "event": "event-name",
            "data": {
                "message": "message content",
                "other_data": "other content"
            }
        }
        """
        serializer = PusherEventSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            send_message(
                serializer.validated_data['channel'],
                serializer.validated_data['event'],
                serializer.validated_data['data']
            )
            return Response({'status': 'Message sent successfully'})
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['post'])
    def unsubscribe(self, request):
        """
        Unsubscribe from a Pusher channel.
        Required data:
        {
            "channel": "channel-name"
        }
        """
        serializer = PusherUnsubscribeSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            unsubscribe_channel(serializer.validated_data['channel'])
            return Response({'status': 'Successfully unsubscribed from channel'})
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class MessageViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing direct messages. Users can send, retrieve, and delete messages.
    Only connected matches can message each other.
    """
    queryset = Message.objects.all()
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated, IsSenderOrReceiver]

    def get_queryset(self):
        """Return messages where the user is either sender or recipient"""
        return Message.objects.filter(
            models.Q(sender=self.request.user) |
            models.Q(recipient=self.request.user)
        )

    def perform_create(self, serializer):
        recipient = serializer.validated_data.get('recipient')
        sender = self.request.user
        
        # Check if there's an active match between the users
        match = Match.objects.filter(
            (models.Q(user1=sender) & models.Q(user2=recipient)) |
            (models.Q(user1=recipient) & models.Q(user2=sender)),
            status='connected'
        ).first()
        
        if not match:
            raise PermissionDenied("You can only message users you are connected with.")
        
        message = serializer.save(sender=sender)
        
        # Create channel name for direct messages
        user_ids = sorted([message.sender.id, message.recipient.id])
        channel = f'private-chat-{user_ids[0]}-{user_ids[1]}'
        
        # Send the message through Pusher
        send_message(
            channel,
            'new-message',
            {
                'id': message.id,
                'sender': message.sender.id,
                'recipient': message.recipient.id,
                'content': message.content,
                'timestamp': message.timestamp.isoformat(),
                'is_read': message.is_read
            }
        )

    @action(detail=True, methods=['patch'])
    def mark_as_read(self, request, pk=None):
        """Mark a message as read"""
        message = self.get_object()
        if message.recipient != request.user:
            raise PermissionDenied("You can only mark your own messages as read.")
        
        message.mark_as_read()
        return Response({'status': 'Message marked as read'})

class GroupChatViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing group chats. Users can create, join, and leave group chats.
    """
    queryset = GroupChat.objects.all()
    serializer_class = GroupChatSerializer
    permission_classes = [permissions.IsAuthenticated, IsGroupMember]

    def get_queryset(self):
        """Return group chats where the user is a member"""
        return GroupChat.objects.filter(members=self.request.user)

    def perform_create(self, serializer):
        group_chat = serializer.save()
        # Add creator as a member
        group_chat.members.add(self.request.user)

    @action(detail=True, methods=['get'])
    def get_channel_name(self, request, pk=None):
        """Get the Pusher channel name for a group chat"""
        group_chat = self.get_object()
        channel = f'group-chat-{group_chat.id}'
        return Response({'channel': channel})

class GroupMessageViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing group messages. Users can send and retrieve messages in group chats.
    """
    queryset = GroupMessage.objects.all()
    serializer_class = GroupMessageSerializer
    permission_classes = [permissions.IsAuthenticated, IsGroupMember]

    def get_queryset(self):
        """Return messages from groups where the user is a member"""
        return GroupMessage.objects.filter(group__members=self.request.user)

    def perform_create(self, serializer):
        group = serializer.validated_data.get('group')
        if not group.members.filter(id=self.request.user.id).exists():
            raise PermissionDenied("You must be a member of the group to send messages.")
        
        message = serializer.save(sender=self.request.user)
        
        # Send the message through Pusher
        channel = f'group-chat-{group.id}'
        send_message(
            channel,
            'new-group-message',
            {
                'id': message.id,
                'group': group.id,
                'sender': message.sender.id,
                'content': message.content,
                'timestamp': message.timestamp.isoformat()
            }
        )
