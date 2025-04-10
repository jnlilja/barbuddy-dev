from rest_framework import viewsets, permissions
from .models import Message, GroupChat
from .serializers import MessageSerializer, GroupChatSerializer
from .permissions import IsGroupMember, IsSenderOrReceiver
from django.http import JsonResponse
from apps.services.pusher_client import send_message
from rest_framework.decorators import action
from rest_framework.response import Response

def send_pusher_message(request):
    data = {'message': 'hello world'}
    send_message('my-channel', 'my-event', data)
    return JsonResponse({'status': 'Message sent!'})

class MessageViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing direct messages. Users can send, retrieve, and delete messages.
    """
    queryset = Message.objects.all()
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated, IsSenderOrReceiver]

    def perform_create(self, serializer):
        message = serializer.save(sender=self.request.user)
        
        # Determine the channel name based on whether it's a direct message or group chat
        if message.group_chat:
            channel = f'group-chat-{message.group_chat.id}'
        else:
            # For direct messages, create a consistent channel name
            user_ids = sorted([message.sender.id, message.receiver.id])
            channel = f'private-chat-{user_ids[0]}-{user_ids[1]}'
        
        # Send the message through Pusher
        send_message(
            channel,
            'new-message',
            {
                'id': message.id,
                'sender': message.sender.id,
                'receiver': message.receiver.id if message.receiver else None,
                'group_chat': message.group_chat.id if message.group_chat else None,
                'message_text': message.message_text,
                'timestamp': message.timestamp.isoformat()
            }
        )

    @action(detail=False, methods=['get'])
    def get_channel_name(self, request):
        """Get the Pusher channel name for a conversation"""
        other_user_id = request.query_params.get('user_id')
        if not other_user_id:
            return Response({'error': 'user_id is required'}, status=400)
            
        user_ids = sorted([request.user.id, int(other_user_id)])
        channel = f'private-chat-{user_ids[0]}-{user_ids[1]}'
        return Response({'channel': channel})

class GroupChatViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing group chats. Users can join, leave, or create group chats.
    """
    queryset = GroupChat.objects.all()
    serializer_class = GroupChatSerializer
    permission_classes = [permissions.IsAuthenticated, IsGroupMember]

    @action(detail=True, methods=['get'])
    def get_channel_name(self, request, pk=None):
        """Get the Pusher channel name for a group chat"""
        group_chat = self.get_object()
        channel = f'group-chat-{group_chat.id}'
        return Response({'channel': channel})
