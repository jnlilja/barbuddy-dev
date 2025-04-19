from django.db import models
from apps.users.models import User
from apps.bars.models import Bar
import random, string
from django.core.exceptions import ValidationError


class MessageManager(models.Manager):
    def get_unread_messages(self, user):
        return self.filter(recipient=user, is_read=False)


class Message(models.Model):
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    recipient = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_messages')
    content = models.TextField(max_length=5000)
    timestamp = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)
    objects = MessageManager()

    class Meta:
        app_label = 'messaging'
        ordering = ['-timestamp']

    def clean(self):
        super().clean()
        # Ensure message isn't empty
        if not self.content or len(self.content.strip()) == 0:
            raise ValidationError({'content': 'Message content cannot be empty.'})

        # Prevent sending message to self
        if self.recipient == self.sender:
            raise ValidationError("You cannot send a message to yourself.")

    def mark_as_read(self):
        """Mark the message as read"""
        self.is_read = True
        self.save()

    @classmethod
    def get_unread_messages(cls, user):
        """Get all unread messages for a user"""
        return cls.objects.filter(recipient=user, is_read=False)

    def __str__(self):
        return f'Message from {self.sender.username} to {self.recipient.username}'

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

class GroupChat(models.Model):
    name = models.CharField(max_length=255)
    members = models.ManyToManyField(User, related_name='group_chats')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

    def clean(self):
        super().clean()
        if not self.name or len(self.name.strip()) == 0:
            raise ValidationError("Group chat name cannot be empty.")

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

    @classmethod
    def create_with_members(cls, name, members):
        """Create a group chat with the specified members."""
        if len(members) < 2:
            raise ValidationError("A group chat must have at least 2 members.")
            
        group_chat = cls(name=name)
        group_chat.save()
        group_chat.members.add(*members)
        return group_chat

class GroupMessage(models.Model):
    group = models.ForeignKey(GroupChat, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='group_messages')
    content = models.TextField(max_length=5000)
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        app_label = 'messaging'
        ordering = ['-timestamp']

    def clean(self):
        super().clean()
        # Ensure message isn't empty
        if not self.content or len(self.content.strip()) == 0:
            raise ValidationError({'content': 'Message content cannot be empty.'})

        # Ensure sender is a member of the group
        if not self.group.members.filter(id=self.sender.id).exists():
            raise ValidationError("You cannot send a message to a group chat you're not a member of.")

    def __str__(self):
        return f'Group message from {self.sender.username} in {self.group.name}'

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)


