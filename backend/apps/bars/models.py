from django.db import models
from apps.users.models import User
from django.contrib.gis.db import models as gis
from django.core.exceptions import ValidationError

class Bar(models.Model):

    # Edit the music Choices, these are not valid 

    # Music is managed by front end


    name = models.CharField(max_length=255)
    address = models.CharField(max_length=255)
    #music_genre = models.CharField(max_length=100, choices=GENRE_CHOICES, default='other')
    average_price = models.CharField(max_length=50)
    location = gis.PointField(geography=True, srid=4326) # add more if possible
    users_at_bar = models.ManyToManyField(User, related_name='bars_attended', blank=True)
    


    def clean(self):
        super().clean()
        if not self.name or len(self.name.strip()) == 0:
            raise ValidationError({'name': 'Bar name cannot be empty or whitespace-only.'})

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def get_latest_status(self):
        latest_status = self.status_updates.order_by('-last_updated').first()
        return {
            'crowd_size': latest_status.crowd_size if latest_status else None,
            'wait_time': latest_status.wait_time if latest_status else None,
            'last_updated': latest_status.last_updated if latest_status else None
        }
    

    def __str__(self):
        return self.name

    class Meta:
        indexes = [
            models.Index(fields=['name']),
            models.Index(fields=['location']),
        ]


class BarStatus(models.Model):
    CROWD_CHOICES = [
        ('empty', 'Empty'),
        ('low', 'Low'),
        ('moderate', 'Moderate'),
        ('busy', 'Busy'),
        ('crowded', 'Crowded'),
        ('packed', 'Packed'), ]

    WAIT_TIME_CHOICES = [
        ('<5 min', 'Less than 5 minutes'),
        ('5-10 min', '5 to 10 minutes'),
        ('10-20 min', '10 to 20 minutes'),
        ('20-30 min', '20 to 30 minutes'),
        ('>30 min', 'More than 30 minutes'), ]

    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='status_updates')
    crowd_size = models.CharField(max_length=50, choices=CROWD_CHOICES)
    wait_time = models.CharField(max_length=50, choices=WAIT_TIME_CHOICES)
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
        """Ensure rating is between 1 and 5 stars."""
        super().clean()
        if not (1 <= self.rating <= 5):
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