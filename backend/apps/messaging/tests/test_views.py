# tests/messaging/test_views.py
from django.test import TestCase, Client
from django.urls import reverse
from apps.users.models import User
from apps.matches.models import Match
from apps.messaging.models import Message, GroupChat, GroupMessage
from rest_framework.test import APIClient
from rest_framework import status
from unittest.mock import patch
import json
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

class MessageViewSetTests(TestCase):
    def setUp(self):
        # Create test users
        self.user1 = User.objects.create_user(
            username='user1',
            password='testpass123'
        )
        self.user2 = User.objects.create_user(
            username='user2',
            password='testpass123'
        )
        self.user3 = User.objects.create_user(
            username='user3',
            password='testpass123'
        )
        
        # Create a match between users
        self.match = Match.objects.create(
            user1=self.user1,
            user2=self.user2,
            status='connected'
        )
        
        # Create test client
        self.client = APIClient()
        self.client.force_authenticate(user=self.user1)
        
        # URLs
        self.message_list_url = reverse('message-list')
        self.message_detail_url = reverse('message-detail', args=[1])  # Will be formatted with actual ID

    @patch('apps.services.pusher_client.send_message')
    def test_create_message(self, mock_send_message):
        """Test creating a new message"""
        data = {
            'recipient': self.user2.id,
            'content': 'Hello, user2!'
        }
        
        response = self.client.post(
            self.message_list_url,
            data=json.dumps(data),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Message.objects.count(), 1)
        
        message = Message.objects.first()
        self.assertEqual(message.sender, self.user1)
        self.assertEqual(message.recipient, self.user2)
        self.assertEqual(message.content, 'Hello, user2!')
        self.assertFalse(message.is_read)
        
        # Verify Pusher was called
        mock_send_message.assert_called_once()

    def test_create_message_unauthenticated(self):
        """Test creating a message when not authenticated"""
        self.client.force_authenticate(user=None)
        
        data = {
            'recipient': self.user2.id,
            'content': 'Hello!'
        }
        
        response = self.client.post(
            self.message_list_url,
            data=json.dumps(data),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_create_message_to_unmatched_user(self):
        """Test creating a message to an unmatched user"""
        data = {
            'recipient': self.user3.id,
            'content': 'Hello!'
        }
        
        response = self.client.post(
            self.message_list_url,
            data=json.dumps(data),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_list_messages(self):
        """Test listing messages"""
        # Create test messages
        Message.objects.create(
            sender=self.user1,
            recipient=self.user2,
            content='Message 1'
        )
        Message.objects.create(
            sender=self.user2,
            recipient=self.user1,
            content='Message 2'
        )
        
        response = self.client.get(self.message_list_url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)

    def test_mark_message_as_read(self):
        """Test marking a message as read"""
        message = Message.objects.create(
            sender=self.user2,
            recipient=self.user1,
            content='Test message'
        )
        
        response = self.client.patch(
            reverse('message-detail', args=[message.id]),
            data=json.dumps({'is_read': True}),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        message.refresh_from_db()
        self.assertTrue(message.is_read)

class GroupChatViewSetTests(TestCase):
    def setUp(self):
        # Create test users
        self.user1 = User.objects.create_user(
            username='user1',
            password='testpass123'
        )
        self.user2 = User.objects.create_user(
            username='user2',
            password='testpass123'
        )
        self.user3 = User.objects.create_user(
            username='user3',
            password='testpass123'
        )
        
        # Create test client
        self.client = APIClient()
        self.client.force_authenticate(user=self.user1)
        
        # URLs
        self.group_chat_list_url = reverse('group-chat-list')
        self.group_chat_detail_url = reverse('group-chat-detail', args=[1])  # Will be formatted with actual ID

    def test_create_group_chat(self):
        """Test creating a new group chat"""
        data = {
            'name': 'Test Group',
            'members': [self.user2.id, self.user3.id]
        }
        
        response = self.client.post(
            self.group_chat_list_url,
            data=json.dumps(data),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(GroupChat.objects.count(), 1)
        
        group_chat = GroupChat.objects.first()
        self.assertEqual(group_chat.name, 'Test Group')
        self.assertEqual(group_chat.members.count(), 3)  # Including creator

    def test_list_group_chats(self):
        """Test listing group chats"""
        group_chat = GroupChat.objects.create(name='Test Group')
        group_chat.members.add(self.user1, self.user2)
        
        response = self.client.get(self.group_chat_list_url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_retrieve_group_chat(self):
        """Test retrieving a specific group chat"""
        group_chat = GroupChat.objects.create(name='Test Group')
        group_chat.members.add(self.user1, self.user2)
        
        response = self.client.get(
            reverse('group-chat-detail', args=[group_chat.id])
        )
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['name'], 'Test Group')

class PusherViewSetTests(TestCase):
    def setUp(self):
        # Create test user
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass123'
        )
        
        # Create test client
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
        
        # URLs
        self.pusher_trigger_url = reverse('pusher-trigger')
        self.pusher_unsubscribe_url = reverse('pusher-unsubscribe')

    @patch('apps.services.pusher_client.send_message')
    def test_trigger_event(self, mock_send_message):
        """Test triggering a Pusher event"""
        data = {
            'channel': 'test-channel',
            'event': 'test-event',
            'data': {'message': 'Hello!'}
        }
        
        response = self.client.post(
            self.pusher_trigger_url,
            data=json.dumps(data),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        mock_send_message.assert_called_once_with(
            'test-channel',
            'test-event',
            {'message': 'Hello!'}
        )

    @patch('apps.services.pusher_client.unsubscribe_channel')
    def test_unsubscribe(self, mock_unsubscribe):
        """Test unsubscribing from a Pusher channel"""
        data = {
            'channel': 'test-channel'
        }
        
        response = self.client.post(
            self.pusher_unsubscribe_url,
            data=json.dumps(data),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        mock_unsubscribe.assert_called_once_with('test-channel')

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_pusher_message(request):
    """
    API endpoint to send a Pusher message.
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
    try:
        # Get required data from request
        channel = request.data.get('channel')
        event = request.data.get('event')
        data = request.data.get('data')

        # Validate required fields
        if not all([channel, event, data]):
            return Response(
                {'error': 'Missing required fields: channel, event, data'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Send message through Pusher
        send_message(channel, event, data)
        
        return Response(
            {'status': 'Message sent successfully'},
            status=status.HTTP_200_OK
        )
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
