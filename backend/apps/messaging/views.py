from rest_framework import viewsets, permissions
from .models import Message, GroupChat
from .serializers import MessageSerializer, GroupChatSerializer
from .permissions import IsGroupMember, IsSenderOrReceiver
from django.http import JsonResponse
from services.pusher_client import send_message

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

class GroupChatViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing group chats. Users can join, leave, or create group chats.
    """
    queryset = GroupChat.objects.all()
    serializer_class = GroupChatSerializer
    permission_classes = [permissions.IsAuthenticated, IsGroupMember]
