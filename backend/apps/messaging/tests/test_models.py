from django.test import TestCase
from django.core.exceptions import ValidationError
from apps.users.models import User
from apps.matches.models import Match
from apps.messaging.models import Message, GroupChat, GroupMessage


class MessageModelTests(TestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(username='user1', password='testpass123')
        self.user2 = User.objects.create_user(username='user2', password='testpass123')
        self.match = Match.objects.create(user1=self.user1, user2=self.user2, status='connected')

    def test_create_message(self):
        message = Message.objects.create(sender=self.user1, recipient=self.user2, content='Hello, user2!')
        self.assertEqual(message.sender, self.user1)
        self.assertEqual(message.recipient, self.user2)
        self.assertEqual(message.content, 'Hello, user2!')
        self.assertFalse(message.is_read)
        self.assertIsNotNone(message.timestamp)

    def test_message_str_representation(self):
        message = Message.objects.create(sender=self.user1, recipient=self.user2, content='Hello!')
        expected_str = f'Message from {self.user1.username} to {self.user2.username}'
        self.assertEqual(str(message), expected_str)

    def test_mark_as_read(self):
        message = Message.objects.create(sender=self.user1, recipient=self.user2, content='Hello!')
        message.mark_as_read()
        self.assertTrue(message.is_read)

    def test_get_unread_messages(self):
        Message.objects.create(sender=self.user1, recipient=self.user2, content='Unread message 1')
        Message.objects.create(sender=self.user1, recipient=self.user2, content='Unread message 2')
        Message.objects.create(sender=self.user1, recipient=self.user2, content='Read message', is_read=True)
        unread_messages = Message.objects.get_unread_messages(self.user2)
        self.assertEqual(unread_messages.count(), 2)

    def test_message_ordering(self):
        msg1 = Message.objects.create(sender=self.user1, recipient=self.user2, content='First message')
        msg2 = Message.objects.create(sender=self.user1, recipient=self.user2, content='Second message')
        messages = list(Message.objects.all())
        self.assertEqual(messages[0], msg2)  # newest first
        self.assertEqual(messages[1], msg1)

    def test_message_validation(self):
        with self.assertRaises(ValidationError):
            Message.objects.create(sender=self.user1, recipient=self.user2, content='')

        with self.assertRaises(ValidationError):
            Message.objects.create(sender=self.user1, recipient=self.user2, content='   ')

    def test_message_between_unmatched_users(self):
        user3 = User.objects.create_user(username='user3', password='testpass123')
        message = Message.objects.create(sender=self.user1, recipient=user3, content='Hello!')
        self.assertEqual(message.sender, self.user1)
        self.assertEqual(message.recipient, user3)


# class GroupChatModelTests(TestCase):
#     def setUp(self):
#         self.user1 = User.objects.create_user(username='user1', password='testpass123')
#         self.user2 = User.objects.create_user(username='user2', password='testpass123')
#         self.user3 = User.objects.create_user(username='user3', password='testpass123')

#     def test_create_group_chat(self):
#         group_chat = GroupChat.objects.create(name='Test Group')
#         group_chat.members.set([self.user1, self.user2, self.user3])
#         group_chat.save()  # validate after members are set
#         self.assertEqual(group_chat.name, 'Test Group')
#         self.assertEqual(group_chat.members.count(), 3)

#     def test_group_chat_str_representation(self):
#         group_chat = GroupChat.objects.create(name='Test Group')
#         group_chat.members.set([self.user1, self.user2])
#         group_chat.save()
#         self.assertEqual(str(group_chat), 'Test Group')

#     def test_group_chat_validation(self):
#         with self.assertRaises(ValidationError):
#             GroupChat(name='').full_clean()
#         with self.assertRaises(ValidationError):
#             GroupChat(name='   ').full_clean()


# class GroupMessageModelTests(TestCase):
#     def setUp(self):
#         self.user1 = User.objects.create_user(username='user1', password='testpass123')
#         self.user2 = User.objects.create_user(username='user2', password='testpass123')
#         self.group_chat = GroupChat.objects.create(name='Test Group')
#         self.group_chat.members.set([self.user1, self.user2])
#         self.group_chat.save()

#     def test_create_group_message(self):
#         message = GroupMessage.objects.create(group=self.group_chat, sender=self.user1, content='Hello everyone!')
#         self.assertEqual(message.group, self.group_chat)
#         self.assertEqual(message.sender, self.user1)
#         self.assertEqual(message.content, 'Hello everyone!')
#         self.assertIsNotNone(message.timestamp)

#     def test_group_message_str_representation(self):
#         message = GroupMessage.objects.create(group=self.group_chat, sender=self.user1, content='Hello!')
#         expected_str = f'Group message from {self.user1.username} in {self.group_chat.name}'
#         self.assertEqual(str(message), expected_str)

#     def test_group_message_validation(self):
#         with self.assertRaises(ValidationError):
#             GroupMessage.objects.create(group=self.group_chat, sender=self.user1, content='')

#         with self.assertRaises(ValidationError):
#             GroupMessage.objects.create(group=self.group_chat, sender=self.user1, content='   ')

#         user3 = User.objects.create_user(username='user3', password='testpass123')
#         with self.assertRaises(ValidationError):
#             GroupMessage.objects.create(group=self.group_chat, sender=user3, content='Hey!')
