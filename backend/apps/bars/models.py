from django.db import models
from django.contrib.gis.db.models import PointField
from apps.users.models import User

class Bar(models.Model):
    CROWD_CHOICES = [
        ('empty', 'Empty'),
        ('low', 'Low'),
        ('moderate', 'Moderate'),
        ('busy', 'Busy'),
        ('crowded', 'Crowded'),]

    name = models.CharField(max_length=255)
    address = models.CharField(max_length=255)
    music_genre = models.CharField(max_length=100)
    average_price = models.CharField(max_length=50)
    event = models.CharField(max_length=100, blank=True)
    location = PointField(null=True, blank=True, srid=4326) # Actual geographic point

    current_crowd = models.CharField(max_length=50, choices=CROWD_CHOICES)
    current_wait_time = models.CharField(max_length=50)
    users_at_bar = models.ManyToManyField(User, related_name='bars_visited', blank=True)

    def __str__(self):
        return self.name


class BarStatus(models.Model):
    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='status_updates')
    crowd_size = models.CharField(max_length=50, choices=Bar.CROWD_CHOICES)
    wait_time = models.CharField(max_length=50)
    last_updated = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.bar.name} Status - {self.last_updated}"