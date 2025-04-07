from django.db import models
from apps.bars.models import Bar
from apps.users.models import User
from django.utils import timezone
from django.core.exceptions import ValidationError

class Event(models.Model):
    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='events')
    event_name = models.CharField(max_length=255)
    event_time = models.DateTimeField()
    event_description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        app_label = 'events'
        unique_together = ('bar', 'event_name', 'event_time')  # Prevent duplicate event names at the same bar

    def clean(self):
        super().clean()
        # Ensure event has a name
        if not self.event_name or len(self.event_name.strip()) == 0:
            raise ValidationError({'event_name': 'Event name cannot be empty.'})

        if self.event_time > timezone.now():
            raise ValidationError("Event time must be in the future.")

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.event_name} at {self.bar.name}"


class EventAttendee(models.Model):
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='attendee_list')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='event_participation')

    class Meta:
        unique_together = ('event', 'user')
        app_label = 'events'

    def __str__(self):
        return f"{self.user} attending {self.event}"


Event.attendees = models.ManyToManyField(User, through='EventAttendee', related_name='events_attending', blank=True)
