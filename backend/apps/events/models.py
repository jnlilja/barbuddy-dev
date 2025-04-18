from django.db import models
from apps.bars.models import Bar
from django.utils import timezone
from django.core.exceptions import ValidationError

DAYS_OF_WEEK = [
    ('Monday', 'Monday'),
    ('Tuesday', 'Tuesday'),
    ('Wednesday', 'Wednesday'),
    ('Thursday', 'Thursday'),
    ('Friday', 'Friday'),
    ('Saturday', 'Saturday'),
    ('Sunday', 'Sunday'),
]

CATEGORY_CHOICES = [
    ('RED', 'Deal / Drink Special'),
    ('BLUE', 'Event'),
]

class Event(models.Model):
    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='events')
    event_name = models.CharField(max_length=255)
    event_time = models.DateTimeField()
    event_description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    day_of_week = models.CharField(max_length=10, choices=DAYS_OF_WEEK)
    category = models.CharField(max_length=10, choices=CATEGORY_CHOICES)

    class Meta:
        app_label = 'events'
        unique_together = ('bar', 'event_name', 'event_time')

    def clean(self):
        super().clean()
        if not self.event_name or len(self.event_name.strip()) == 0:
            raise ValidationError({'event_name': 'Event name cannot be empty.'})
        if self.event_time < timezone.now():
            raise ValidationError("Event time must be in the future.")

    def save(self, *args, **kwargs):
        # Normalize event_time to seconds precision to ensure unique constraint enforcement
        if self.event_time:
            self.event_time = self.event_time.replace(microsecond=0)
        self.clean()
        super().save(*args, **kwargs)

    @property
    def is_today(self):
        return self.day_of_week == timezone.now().strftime("%A")

    def __str__(self):
        return f"{self.event_name} at {self.bar.name}"
