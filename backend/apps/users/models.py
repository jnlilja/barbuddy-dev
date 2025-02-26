from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    # Keep Django's built-in username, email, first_name, last_name

    # Add your custom fields
    age = models.PositiveIntegerField(null=True, blank=True)
    height = models.PositiveIntegerField(null=True, blank=True)
    hometown = models.CharField(max_length=255, blank=True)
    job_or_university = models.CharField(max_length=255, blank=True)
    favorite_drink = models.CharField(max_length=100, blank=True)
    location = models.CharField(max_length=255, blank=True)
    profile_pictures = models.JSONField(default=list, blank=True)

    # Self-referencing fields
    matches = models.ManyToManyField('self', symmetrical=False, blank=True, related_name='matched_by')
    swiped_users = models.ManyToManyField('self', symmetrical=False, related_name='swiped_by', blank=True)

    def __str__(self):
        return self.get_full_name() or self.username