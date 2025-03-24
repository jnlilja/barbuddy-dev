from django.core.exceptions import ValidationError
from django.db import models
from apps.users.models import User
from apps.matches.models import Match

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

        # Only check for a match if this is a "like" swipe
        if self.status == 'like':
            # Check if the other user has also liked this user
            if Swipe.objects.filter(swiper=self.swiped_on, swiped_on=self.swiper, status='like').exists():
                # Create a match (ordering users by ID to prevent duplicates)
                user1, user2 = sorted([self.swiper, self.swiped_on], key=lambda u: u.id)
                Match.objects.get_or_create(user1=user1, user2=user2,defaults={'status': 'connected'})

    def __str__(self):
        return f"{self.swiper} swiped {self.status} on {self.swiped_on}"
