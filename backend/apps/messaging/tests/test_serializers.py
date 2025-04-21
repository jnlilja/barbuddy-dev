from django.test import TestCase
from apps.users.models import User
from apps.messaging.models import Message, GroupChat, GroupMessage
from apps.messaging.serializers import (
    MessageSerializer,
    GroupChatSerializer,
    GroupMessageSerializer,
    PusherEventSerializer,
    PusherUnsubscribeSerializer
)

class MessageSerializerTests(TestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(
            username='user1',
            password='testpass123'
        )
        self.user2 = User.objects.create_user(
            username='user2',
            password='testpass123'
        )
        self.message = Message.objects.create(
            sender=self.user1,
            recipient=self.user2,
            content='Hello!'
        )

    def test_message_serialization(self):
        """Test serializing a message"""
        serializer = MessageSerializer(self.message)
        data = serializer.data
        
        self.assertEqual(data['id'], self.message.id)
        self.assertEqual(data['sender'], self.user1.id)
        self.assertEqual(data['recipient'], self.user2.id)
        self.assertEqual(data['content'], 'Hello!')
        self.assertEqual(data['is_read'], False)
        self.assertEqual(data['sender_username'], 'user1')
        self.assertEqual(data['recipient_username'], 'user2')
        self.assertIn('timestamp', data)

    def test_message_deserialization(self):
        """Test deserializing message data"""
        data = {
            'recipient': self.user2.id,
            'content': 'New message'
        }
        serializer = MessageSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        
        message = serializer.save(sender=self.user1)
        self.assertEqual(message.sender, self.user1)
        self.assertEqual(message.recipient, self.user2)
        self.assertEqual(message.content, 'New message')
        self.assertFalse(message.is_read)

class GroupChatSerializerTests(TestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(
            username='user1',
            password='testpass123'
        )
        self.user2 = User.objects.create_user(
            username='user2',
            password='testpass123'
        )
        self.group_chat = GroupChat.objects.create(name='Test Group')
        self.group_chat.members.add(self.user1, self.user2)

    def test_group_chat_serialization(self):
        """Test serializing a group chat"""
        serializer = GroupChatSerializer(self.group_chat)
        data = serializer.data
        
        self.assertEqual(data['id'], self.group_chat.id)
        self.assertEqual(data['name'], 'Test Group')
        self.assertEqual(len(data['members']), 2)
        self.assertIn(self.user1.id, data['members'])
        self.assertIn(self.user2.id, data['members'])
        self.assertIn('created_at', data)

    def test_group_chat_deserialization(self):
        """Test deserializing group chat data"""
        data = {
            'name': 'New Group',
            'members': [self.user1.id, self.user2.id]
        }
        serializer = GroupChatSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        
        group_chat = serializer.save()
        self.assertEqual(group_chat.name, 'New Group')
        self.assertEqual(group_chat.members.count(), 2)
        self.assertIn(self.user1, group_chat.members.all())
        self.assertIn(self.user2, group_chat.members.all())

class GroupMessageSerializerTests(TestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(
            username='user1',
            password='testpass123'
        )
        self.user2 = User.objects.create_user(
            username='user2',
            password='testpass123'
        )
        self.group_chat = GroupChat.objects.create(name='Test Group')
        self.group_chat.members.add(self.user1, self.user2)
        self.message = GroupMessage.objects.create(
            group=self.group_chat,
            sender=self.user1,
            content='Hello everyone!'
        )

    def test_group_message_serialization(self):
        """Test serializing a group message"""
        serializer = GroupMessageSerializer(self.message)
        data = serializer.data
        
        self.assertEqual(data['id'], self.message.id)
        self.assertEqual(data['group'], self.group_chat.id)
        self.assertEqual(data['sender'], self.user1.id)
        self.assertEqual(data['content'], 'Hello everyone!')
        self.assertEqual(data['sender_username'], 'user1')
        self.assertIn('timestamp', data)

    def test_group_message_deserialization(self):
        """Test deserializing group message data"""
        data = {
            'group': self.group_chat.id,
            'content': 'New message'
        }
        serializer = GroupMessageSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        
        message = serializer.save(sender=self.user1)
        self.assertEqual(message.group, self.group_chat)
        self.assertEqual(message.sender, self.user1)
        self.assertEqual(message.content, 'New message')

class PusherSerializerTests(TestCase):
    def test_pusher_event_serialization(self):
        """Test serializing Pusher event data"""
        data = {
            'channel': 'test-channel',
            'event': 'test-event',
            'data': {'message': 'Hello!'}
        }
        serializer = PusherEventSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        self.assertEqual(serializer.validated_data, data)

    def test_pusher_unsubscribe_serialization(self):
        """Test serializing Pusher unsubscribe data"""
        data = {
            'channel': 'test-channel'
        }
        serializer = PusherUnsubscribeSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        self.assertEqual(serializer.validated_data, data)
