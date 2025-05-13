from django.db import models
from apps.users.models import User
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
        ordering = ['-created_at']


    def clean(self):
        super().clean()
        # Only check if both users are set
        if hasattr(self, 'user1_id') and hasattr(self, 'user2_id') and self.user1_id and self.user2_id:
            if self.user1_id == self.user2_id:
                raise ValidationError("A user cannot match with themselves.")
            
            existing_match = Match.objects.filter(
                (models.Q(user1=self.user1) & models.Q(user2=self.user2)) |
                (models.Q(user1=self.user2) & models.Q(user2=self.user1))
            ).exclude(pk=self.pk).exists()

            if existing_match:
                raise ValidationError("A match between these users already exists.")

        if self.status not in dict(self.STATUS_CHOICES):
            raise ValidationError({'status': f"Invalid status. Choose from: {', '.join(dict(self.STATUS_CHOICES).keys())}"})

        if self.disconnected_by and self.status != 'disconnected':
            raise ValidationError({'disconnected_by': 'This field should only be set when status is "disconnected".'})

        if self.disconnected_by and self.disconnected_by not in [self.user1, self.user2]:
            raise ValidationError({'disconnected_by': 'Only matched users can disconnect the match.'})
    def __str__(self):
        return f"{self.user1} - {self.user2} ({self.status})"