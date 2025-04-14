# tests/messaging/test_views.py
from django.test import TestCase
from rest_framework.test import APIClient
from apps.users.models import User
from apps.matches.models import Match
from apps.messaging.models import Message
from unittest.mock import patch

class MessagingTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user1 = User.objects.create(username='user1')
        self.user2 = User.objects.create(username='user2')
        self.client.force_authenticate(user=self.user1)
        
        # Create a match between users
        self.match = Match.objects.create(
            user1=self.user1,
            user2=self.user2,
            status='connected'
        )

    @patch('apps.services.pusher_client.send_message')
    def test_send_message(self, mock_send_message):
        # Test sending a message
        response = self.client.post('/api/messages/', {
            'receiver': self.user2.id,
            'message_text': 'Hello!'
        })
        
        self.assertEqual(response.status_code, 201)
        self.assertTrue(Message.objects.exists())
        
        # Verify Pusher was called
        mock_send_message.assert_called_once()
        
        # Verify channel name format
        channel_name = mock_send_message.call_args[0][0]
        self.assertTrue(channel_name.startswith('private-chat-'))
        
        # Verify event name
        event_name = mock_send_message.call_args[0][1]
        self.assertEqual(event_name, 'new-message')

    def test_get_channel_name(self):
        # Test getting channel name
        response = self.client.get(f'/api/messages/get_channel_name/?user_id={self.user2.id}')
        
        self.assertEqual(response.status_code, 200)
        self.assertIn('channel', response.data)
        
        # Verify channel name format
        channel_name = response.data['channel']
        self.assertTrue(channel_name.startswith('private-chat-'))
