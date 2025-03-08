from django.db import models
from apps.users.models import User
from apps.bars.models import Bar
from django.core.exceptions import ValidationError

class Message(models.Model):
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_messages', null=True,
                                 blank=True)
    message_text = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    group_chat = models.ForeignKey('GroupChat', on_delete=models.CASCADE, related_name='messages', null=True,
                                   blank=True)

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

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def __str__(self):
        if self.group_chat:
            return f"From {self.sender} to group {self.group_chat.id}"
        return f"From {self.sender} to {self.receiver}"

class GroupChat(models.Model):
    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='group_chats', null=True, blank=True)
    users = models.ManyToManyField(User, related_name='group_chats')
    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        super().clean()
        # Ensure group chat has at least 2 members when saving
        if hasattr(self, 'pk') and self.users.count() < 2:
            raise ValidationError("A group chat must have at least 2 members.")

    def save(self, *args, **kwargs):
        # Note: We can't validate users in save() since M2M relationships
        # are set after save(), so this needs to be checked elsewhere
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Group chat {self.id} - {self.created_at}"
