from django.core.exceptions import ValidationError
from django.db import models
from apps.users.models import User

class Swipe(models.Model):
    SWIPE_CHOICES = [
        ('like', 'Like'),
        ('dislike', 'Dislike'),
    ]

    swiper = models.ForeignKey(User, on_delete=models.CASCADE, related_name='swipe_actions')
    swiped_on = models.ForeignKey(User, on_delete=models.CASCADE, related_name='swiped_on_by')
    status = models.CharField(max_length=10, choices=SWIPE_CHOICES)
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('swiper', 'swiped_on')  # Prevent duplicate swipes
        indexes = [
            models.Index(fields=['swiper', 'swiped_on', 'status']),
        ]

    def clean(self):
        super().clean()
        if self.swiper == self.swiped_on:
            raise ValidationError("You cannot swipe on yourself.")

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.swiper} swiped {self.status} on {self.swiped_on}"
