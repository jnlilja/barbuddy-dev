from django.db import models
from apps.users.models import User
from apps.bars.models import Bar
import random, string
from django.core.exceptions import ValidationError

class Message(models.Model):
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_messages', null=True,
                                 blank=True)
    message_text = models.TextField(max_length=5000)
    timestamp = models.DateTimeField(auto_now_add=True)
    group_chat = models.ForeignKey('GroupChat', on_delete=models.CASCADE, related_name='messages', null=True,
                                   blank=True)

    class Meta:
        app_label = 'messaging'

    def clean(self):
        super().clean()
        # Message must have either a receiver or a group_chat, not both or neither
        if (self.receiver is None and self.group_chat is None) or (
                self.receiver is not None and self.group_chat is not None):
            raise ValidationError("Message must have either a receiver or a group chat, not both or neither.")

        # Prevent sending message to self
        if self.receiver == self.sender:
            raise ValidationError("You cannot send a message to yourself.")

        # Ensure message isn't empty
        if not self.message_text or len(self.message_text.strip()) == 0:
            raise ValidationError({'message_text': 'Message text cannot be empty.'})

        # If sending to group chat, ensure sender is a member
        if self.group_chat and not self.group_chat.users.filter(id=self.sender.id).exists():
            raise ValidationError("You cannot send a message to a group chat you're not a member of.")

    def __str__(self):
        if self.group_chat:
            return f"From {self.sender} to group {self.group_chat.id}"
        return f"From {self.sender} to {self.receiver}"

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

class GroupChat(models.Model):
    def generate_random_name(self):
        return ''.join(random.choices(string.ascii_letters + string.digits, k=10))

    name = models.CharField(max_length=255, blank=True)
    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='group_chats', null=True, blank=True)
    creator = models.ForeignKey(User, on_delete=models.SET_NULL, related_name='created_group_chats', null=True)
    users = models.ManyToManyField(User, related_name='group_chats')
    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        super().clean()
        # Ensure group chat has at least 2 members when saving
        if hasattr(self, 'pk') and self.users.count() < 2:
            raise ValidationError("A group chat must have at least 2 members.")

        # Ensure creator is a member of the group chat
        if self.creator and hasattr(self, 'pk') and not self.users.filter(id=self.creator.id).exists():
            raise ValidationError("The creator must be a member of the group chat.")

        super().clean()

    def get_display_name(self):
        """Returns a display name for the group chat"""
        if self.name:
            return self.name
        elif self.bar:
            return f"Group at {self.bar.name}"
        else:
            # Get the first few members' names
            members = self.users.all()[:3]
            names = ", ".join(user.username for user in members)
            if self.users.count() > 3:
                names += f" and {self.users.count() - 3} others"
            return names

    def save(self, *args, **kwargs):
        if self.users.count() < 2:
            raise ValidationError("A group chat must have at least 2 members.")

        if not self.name:
            self.name = self.generate_random_name()

        super().save(*args, **kwargs)

    def __str__(self):
        if self.name:
            return f"{self.name} - {self.created_at}"
        return f"Group chat {self.id} - {self.created_at}"
