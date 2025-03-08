from django.db import models

from django.db import models
from apps.bars.models import Bar
from apps.users.models import User
from django.core.exceptions import ValidationError

class Event(models.Model):
    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='events')
    event_name = models.CharField(max_length=255)
    event_time = models.DateTimeField()
    event_description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    # Many-to-many relationship for users attending events
    attendees = models.ManyToManyField(User, related_name='events_attending', blank=True)

    def clean(self):
        super().clean()
        # Ensure event has a name
        if not self.event_name or len(self.event_name.strip()) == 0:
            raise ValidationError({'event_name': 'Event name cannot be empty.'})

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.event_name} at {self.bar.name}"
