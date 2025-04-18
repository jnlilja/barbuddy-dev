from django.test import TestCase
from apps.users.models import User
from apps.matches.models import Match
from apps.messaging.models import Message, GroupChat, GroupMessage

class MessageModelTests(TestCase):
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
        
        # Create a match between users
        self.match = Match.objects.create(
            user1=self.user1,
            user2=self.user2,
            status='connected'
        )

    def test_create_message(self):
        """Test creating a message between matched users"""
        message = Message.objects.create(
            sender=self.user1,
            recipient=self.user2,
            content='Hello, user2!'
        )
        
        self.assertEqual(message.sender, self.user1)
        self.assertEqual(message.recipient, self.user2)
        self.assertEqual(message.content, 'Hello, user2!')
        self.assertFalse(message.is_read)
        self.assertIsNotNone(message.timestamp)

    def test_message_str_representation(self):
        """Test the string representation of a message"""
        message = Message.objects.create(
            sender=self.user1,
            recipient=self.user2,
            content='Hello!'
        )
        
        expected_str = f'Message from {self.user1.username} to {self.user2.username}'
        self.assertEqual(str(message), expected_str)

    def test_mark_as_read(self):
        """Test marking a message as read"""
        message = Message.objects.create(
            sender=self.user1,
            recipient=self.user2,
            content='Hello!'
        )
        
        message.mark_as_read()
        self.assertTrue(message.is_read)

    def test_get_unread_messages(self):
        """Test retrieving unread messages for a user"""
        # Create some messages
        Message.objects.create(
            sender=self.user1,
            recipient=self.user2,
            content='Unread message 1'
        )
        Message.objects.create(
            sender=self.user1,
            recipient=self.user2,
            content='Unread message 2'
        )
        Message.objects.create(
            sender=self.user1,
            recipient=self.user2,
            content='Read message',
            is_read=True
        )
        
        unread_messages = Message.objects.get_unread_messages(self.user2)
        self.assertEqual(unread_messages.count(), 2)

    def test_message_ordering(self):
        """Test that messages are ordered by timestamp"""
        message1 = Message.objects.create(
            sender=self.user1,
            recipient=self.user2,
            content='First message'
        )
        message2 = Message.objects.create(
            sender=self.user1,
            recipient=self.user2,
            content='Second message'
        )
        
        messages = Message.objects.all()
        self.assertEqual(messages[0], message1)
        self.assertEqual(messages[1], message2)

    def test_message_validation(self):
        """Test message validation"""
        # Test empty message
        with self.assertRaises(ValueError):
            Message.objects.create(
                sender=self.user1,
                recipient=self.user2,
                content=''
            )
        
        # Test whitespace-only message
        with self.assertRaises(ValueError):
            Message.objects.create(
                sender=self.user1,
                recipient=self.user2,
                content='   '
            )

    def test_message_between_unmatched_users(self):
        """Test message creation between unmatched users"""
        # Create a third user who is not matched with user1
        user3 = User.objects.create_user(
            username='user3',
            password='testpass123'
        )
        
        # Should be able to create message even without a match
        message = Message.objects.create(
            sender=self.user1,
            recipient=user3,
            content='Hello!'
        )
        
        self.assertEqual(message.sender, self.user1)
        self.assertEqual(message.recipient, user3)

class GroupChatModelTests(TestCase):
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

    def test_create_group_chat(self):
        """Test creating a group chat"""
        group_chat = GroupChat.objects.create(name='Test Group')
        group_chat.members.add(self.user1, self.user2, self.user3)
        
        self.assertEqual(group_chat.name, 'Test Group')
        self.assertEqual(group_chat.members.count(), 3)
        self.assertIn(self.user1, group_chat.members.all())
        self.assertIn(self.user2, group_chat.members.all())
        self.assertIn(self.user3, group_chat.members.all())

    def test_group_chat_str_representation(self):
        """Test the string representation of a group chat"""
        group_chat = GroupChat.objects.create(name='Test Group')
        group_chat.members.add(self.user1, self.user2)
        
        expected_str = 'Test Group'
        self.assertEqual(str(group_chat), expected_str)

    def test_group_chat_validation(self):
        """Test group chat validation"""
        # Test empty name
        with self.assertRaises(ValueError):
            GroupChat.objects.create(name='')
        
        # Test whitespace-only name
        with self.assertRaises(ValueError):
            GroupChat.objects.create(name='   ')

class GroupMessageModelTests(TestCase):
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
        
        # Create a group chat
        self.group_chat = GroupChat.objects.create(name='Test Group')
        self.group_chat.members.add(self.user1, self.user2)

    def test_create_group_message(self):
        """Test creating a group message"""
        message = GroupMessage.objects.create(
            group=self.group_chat,
            sender=self.user1,
            content='Hello everyone!'
        )
        
        self.assertEqual(message.group, self.group_chat)
        self.assertEqual(message.sender, self.user1)
        self.assertEqual(message.content, 'Hello everyone!')
        self.assertIsNotNone(message.timestamp)

    def test_group_message_str_representation(self):
        """Test the string representation of a group message"""
        message = GroupMessage.objects.create(
            group=self.group_chat,
            sender=self.user1,
            content='Hello!'
        )
        
        expected_str = f'Group message from {self.user1.username} in {self.group_chat.name}'
        self.assertEqual(str(message), expected_str)

    def test_group_message_validation(self):
        """Test group message validation"""
        # Test empty message
        with self.assertRaises(ValueError):
            GroupMessage.objects.create(
                group=self.group_chat,
                sender=self.user1,
                content=''
            )
        
        # Test whitespace-only message
        with self.assertRaises(ValueError):
            GroupMessage.objects.create(
                group=self.group_chat,
                sender=self.user1,
                content='   '
            )
        
        # Test message from non-member
        user3 = User.objects.create_user(
            username='user3',
            password='testpass123'
        )
        with self.assertRaises(ValueError):
            GroupMessage.objects.create(
                group=self.group_chat,
                sender=user3,
                content='Hello!'
            )
