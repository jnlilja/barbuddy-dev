from django.db import models
from apps.users.models import User
from apps.swipes.models import Swipe
from django.core.exceptions import ValidationError

class Match(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('connected', 'Connected'),
        ('disconnected', 'Disconnected'),
    ]

    user1 = models.ForeignKey(User, on_delete=models.CASCADE, related_name='initiated_matches')
    user2 = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_matches')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    # New field to track who initiated the disconnection
    disconnected_by = models.ForeignKey(User, on_delete=models.SET_NULL,
                                        null=True, blank=True, related_name='disconnected_matches')

    class Meta:
        unique_together = ('user1', 'user2')  # Ensure unique match
        indexes = [models.Index(fields=['user1', 'user2'])]

    def clean(self):
        super().clean()
        if self.user1 == self.user2:
            raise ValidationError("A user cannot match with themselves.")

        if self.status not in dict(self.STATUS_CHOICES):
            raise ValidationError({'status': f"Invalid status. Choose from: {', '.join(dict(self.STATUS_CHOICES).keys())}"})

        if self.disconnected_by and self.status != 'disconnected':
            raise ValidationError({'disconnected_by': 'This field should only be set when status is "disconnected".'})

        if self.disconnected_by and self.disconnected_by not in [self.user1, self.user2]:
            raise ValidationError({'disconnected_by': 'Only matched users can disconnect the match.'})

        existing_match = Match.objects.filter(
            (models.Q(user1=self.user1) & models.Q(user2=self.user2)) |
            (models.Q(user1=self.user2) & models.Q(user2=self.user1))
        ).exclude(pk=self.pk).exists()

        if existing_match:
            raise ValidationError("A match between these users already exists.")

    @staticmethod
    def check_and_create_match(user1, user2):
        """Check if a mutual like exists, and create a match if so."""
        if Swipe.objects.filter(swiper=user1, swiped_on=user2, status='like').exists() and \
                Swipe.objects.filter(swiper=user2, swiped_on=user1, status='like').exists():
            # Create a match
            match, created = Match.objects.get_or_create(user1=min(user1, user2, key=lambda x: x.id),
                                                         user2=max(user1, user2, key=lambda x: x.id),
                                                         defaults={'status': 'connected'})
            return match if created else None

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

        # Check for a match only if the swipe was a "like"
        if self.status == 'like':
            Match.check_and_create_match(self.swiper, self.swiped_on)

    def __str__(self):
        return f"{self.user1} - {self.user2} ({self.status})"