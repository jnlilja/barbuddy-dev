from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from django.db import models
from django.contrib.gis.db import models as gis

class User(AbstractUser):
    # Keep Django's built-in username, email, first_name, last_name

    age = models.PositiveIntegerField(null=True, blank=True)
    height = models.PositiveIntegerField(null=True, blank=True)
    hometown = models.CharField(max_length=255, blank=True)
    job_or_university = models.CharField(max_length=255, blank=True)
    favorite_drink = models.CharField(max_length=100, blank=True)
    location = gis.PointField(geography=True, srid=4326)
    profile_pictures = models.JSONField(default=list, blank=True)
    # Self-referencing fields
    matches = models.ManyToManyField('self', symmetrical=False, blank=True, related_name='matched_by')
    swiped_users = models.ManyToManyField('self', symmetrical=False, related_name='swiped_by', blank=True)

    def clean(self):
        super().clean()
        # age verification
        if self.age is not None and (self.age < 18 or self.age > 120):
            raise ValidationError({'age': 'Age must be between 18 and 120 years.'})

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return self.get_full_name() or self.username