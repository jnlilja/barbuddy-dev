from django.db import models
from apps.users.models import User
from django.core.exceptions import ValidationError

class Match(models.Model):
    STATUS = [
        ('pending', 'Pending'),
        ('connected', 'Connected'),
        ('disconnected', 'Disconnected'),
    ]

    user1 = models.ForeignKey(User, on_delete=models.CASCADE, related_name='initiated_matches')
    user2 = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_matches')
    status = models.CharField(max_length=20, choices=STATUS)
    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        super().clean()
        # Ensure a user cannot match with themselves
        if self.user1 == self.user2:
            raise ValidationError("A user cannot match with themselves.")

        # Ensure status is valid
        if self.status not in dict(self.STATUS):
            raise ValidationError({'status': f"Invalid status. Choose from: {', '.join(dict(self.STATUS).keys())}"})

        # Check if a match between these users already exists
        existing_match = Match.objects.filter(
            (models.Q(user1=self.user1) & models.Q(user2=self.user2)) |
            (models.Q(user1=self.user2) & models.Q(user2=self.user1))
        ).exclude(pk=self.pk).exists()

        if existing_match:
            raise ValidationError("A match between these users already exists.")

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.user1} - {self.user2} ({self.status})"
