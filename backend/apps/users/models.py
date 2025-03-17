from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from django.db import models
from datetime import date
from django.contrib.gis.db import models as gis

class User(AbstractUser):
    phone_number = models.CharField(max_length=15, blank=True, null=True, unique=True)
    date_of_birth = models.DateField(null=True, blank=True)
    height = models.PositiveIntegerField(null=True, blank=True)
    hometown = models.CharField(max_length=255, blank=True)
    job_or_university = models.CharField(max_length=255, blank=True)
    favorite_drink = models.CharField(max_length=100, blank=True)
    location = gis.PointField(geography=True, srid=4326)
    profile_pictures = models.JSONField(default=list, blank=True)

    def clean(self):
        super().clean()
        # age verification
        if self.date_of_birth:
            today = date.today()
            age = today.year - self.date_of_birth.year - (
                        (today.month, today.day) < (self.date_of_birth.month, self.date_of_birth.day))
            if age < 18 or age > 120:
                raise ValidationError({'date_of_birth': 'User must be between 18 and 120 years old.'})

    def get_age(self):
        """Dynamically calculates age from DOB."""
        if not self.date_of_birth:
            return None
        today = date.today()
        return today.year - self.date_of_birth.year - (
                    (today.month, today.day) < (self.date_of_birth.month, self.date_of_birth.day))

    class Meta:
        indexes = [
            models.Index(fields=['username']),
            models.Index(fields=['email']),
        ]

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)