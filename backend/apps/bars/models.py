from django.db import models
from apps.users.models import User
from django.contrib.gis.db import models as gis
from django.core.exceptions import ValidationError

class Bar(models.Model):
    CROWD_CHOICES = [
        ('empty', 'Empty'),
        ('low', 'Low'),
        ('moderate', 'Moderate'),
        ('busy', 'Busy'),
        ('crowded', 'Crowded'),
        ('packed', 'Packed'),]

    WAIT_TIME_CHOICES = [
        ('<5 min', 'Less than 5 minutes'),
        ('5-10 min', '5 to 10 minutes'),
        ('10-20 min', '10 to 20 minutes'),
        ('20-30 min', '20 to 30 minutes'),
        ('>30 min', 'More than 30 minutes'),]

    name = models.CharField(max_length=255)
    address = models.CharField(max_length=255)
    music_genre = models.CharField(max_length=100)
    average_price = models.CharField(max_length=50)
    event = models.CharField(max_length=100, blank=True)
    location = gis.PointField(geography=True, srid=4326) # add more if possible

    current_crowd = models.CharField(max_length=50, choices=CROWD_CHOICES)
    current_wait_time = models.CharField(max_length=50, choices=WAIT_TIME_CHOICES)
    users_at_bar = models.ManyToManyField(User, related_name='bars_visited', blank=True)

    def clean(self):
        super().clean()
        if not self.name or len(self.name.strip()) == 0:
            raise ValidationError({'name': 'Bar name cannot be empty.'})

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

    class Meta:
        indexes = [
            models.Index(fields=['name']),
            models.Index(fields=['current_crowd']),
        ]


class BarStatus(models.Model):
    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='status_updates')
    crowd_size = models.CharField(max_length=50, choices=Bar.CROWD_CHOICES)
    wait_time = models.CharField(max_length=50, choices=Bar.WAIT_TIME_CHOICES)
    last_updated = models.DateTimeField(auto_now=True)

    def clean(self):
        super().clean()
        if not self.crowd_size:
            raise ValidationError({'crowd_size': 'Crowd size must be specified.'})

        if not self.wait_time:
            raise ValidationError({'wait_time': 'Wait time must be specified.'})

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.bar.name} Status - {self.last_updated}"


class BarRating(models.Model):
    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='ratings')
    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='bar_ratings')
    rating = models.PositiveSmallIntegerField()  # 1-5 stars
    review = models.TextField(blank=True)
    timestamp = models.DateTimeField(auto_now_add=True)

    def clean(self):
        super().clean()
        if self.rating < 1 or self.rating > 5:
            raise ValidationError({'rating': 'Rating must be between 1 and 5 stars.'})

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    class Meta:
        unique_together = ('bar', 'user')  # A user can only rate a bar once
        indexes = [
            models.Index(fields=['rating']),
            models.Index(fields=['timestamp']),
        ]

    def __str__(self):
        return f"{self.user.username}'s rating for {self.bar.name}"