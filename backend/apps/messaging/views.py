from rest_framework import viewsets
from .models import Message, GroupChat
from .serializers import MessageSerializer, GroupChatSerializer

class MessageViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing direct messages.
    Users can send, retrieve, and delete messages.
    """
    queryset = Message.objects.all()
    serializer_class = MessageSerializer

class GroupChatViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing group chats.
    Users can join, leave, or create group chats.
    """
    queryset = GroupChat.objects.all()
    serializer_class = GroupChatSerializer

