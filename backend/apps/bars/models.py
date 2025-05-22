from django.db import models
from django.core.exceptions import ValidationError
from django.db.models import Avg
from django.contrib.gis.db import models as gis
from django.db import transaction

from apps.users.models import User


class Bar(models.Model):
    name = models.CharField(max_length=255)
    address = models.CharField(max_length=255)
    average_price = models.CharField(max_length=50)
    location = gis.PointField(geography=True, srid=4326)
    users_at_bar = models.ManyToManyField(User, related_name='bars_attended', blank=True)

    def clean(self):
        super().clean()
        if not self.name.strip():
            raise ValidationError({'name': 'Bar name cannot be empty or whitespace-only.'})

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)
        # proximity update stays as-is
        from apps.bars.services.proximity import update_users_at_bar
        update_users_at_bar(self)

    def get_latest_status(self):
        latest = self.status_updates.order_by('-last_updated').first()
        return {
            'crowd_size': latest.crowd_size if latest else None,
            'wait_time':  latest.wait_time  if latest else None,
            'last_updated': latest.last_updated if latest else None
        }

    def get_aggregated_vote_status(self):
        from apps.bars.services.voting import aggregate_bar_votes
        return aggregate_bar_votes(self.id)

    def get_average_rating(self):
        avg = self.ratings.aggregate(Avg('rating'))['rating__avg']
        return round(avg, 2) if avg is not None else None

    @property
    def current_user_count(self):
        """Get the current number of users at this bar"""
        return self.users_at_bar.count()

    @classmethod
    def get_most_active_bars(cls, limit=10):
        """Returns bars ordered by current number of users"""
        return cls.objects.annotate(
            user_count=models.Count('users_at_bar')
        ).order_by('-user_count')[:limit]

    def get_activity_level(self):
        count = self.current_user_count
        if count == 0:
            return "Dead"
        elif count < 5:
            return "Quiet"
        elif count < 15:
            return "Moderate"
        elif count < 30:
            return "Active"
        else:
            return "Buzzing"

    def __str__(self):
        return self.name

    class Meta:
        indexes = [
            models.Index(fields=['name']),
            models.Index(fields=['location']),
        ]


class BarStatus(models.Model):
    CROWD_CHOICES = [
        ('empty',    'Empty'),
        ('low',      'Low'),
        ('moderate', 'Moderate'),
        ('busy',     'Busy'),
        ('crowded',  'Crowded'),
        ('packed',   'Packed'),
    ]
    WAIT_TIME_CHOICES = [
        ('<5 min',   'Less than 5 minutes'),
        ('5-10 min', '5 to 10 minutes'),
        ('10-20 min','10 to 20 minutes'),
        ('20-30 min','20 to 30 minutes'),
        ('>30 min',  'More than 30 minutes'),
    ]

    bar         = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='status_updates')
    crowd_size  = models.CharField(max_length=50, choices=CROWD_CHOICES)
    wait_time   = models.CharField(max_length=50, choices=WAIT_TIME_CHOICES)
    last_updated= models.DateTimeField(auto_now=True)

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
        return f"{self.bar.name} Status — {self.last_updated}"


class BarRating(models.Model):
    bar       = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='ratings')
    user      = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bar_ratings')
    rating    = models.PositiveSmallIntegerField()  # 1–5
    review    = models.TextField(blank=True)
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('bar', 'user')
        indexes = [
            models.Index(fields=['rating']),
            models.Index(fields=['timestamp']),
        ]

    def clean(self):
        super().clean()
        if not (1 <= self.rating <= 5):
            raise ValidationError({'rating': 'Rating must be between 1 and 5 stars.'})

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.user.username}'s rating for {self.bar.name}"


class BarVote(models.Model):
    WAIT_TIME_CHOICES = BarStatus.WAIT_TIME_CHOICES

    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='wait_time_votes')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='wait_time_votes')
    wait_time = models.CharField(max_length=50, choices=WAIT_TIME_CHOICES)
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['bar', 'user'], name='unique_wait_time_vote_per_bar_user')
        ]
        indexes = [
            models.Index(fields=['bar']),
            models.Index(fields=['user']),
            models.Index(fields=['timestamp']),
        ]

    def clean(self):
        super().clean()
        if self.wait_time not in dict(self.WAIT_TIME_CHOICES):
            raise ValidationError({'wait_time': 'Invalid wait time.'})

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.user.username}'s vote for {self.bar.name} — {self.wait_time}"

class BarCrowdSize(models.Model):
    CROWD_CHOICES = BarStatus.CROWD_CHOICES

    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='crowd_size_votes')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='crowd_size_votes')
    crowd_size = models.CharField(max_length=50, choices=CROWD_CHOICES)
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['bar', 'user'], name='unique_crowd_size_vote_per_bar_user')
        ]
        indexes = [
            models.Index(fields=['bar']),
            models.Index(fields=['user']),
            models.Index(fields=['timestamp']),
        ]

    def clean(self):
        super().clean()
        if self.crowd_size not in dict(self.CROWD_CHOICES):
            raise ValidationError({'crowd_size': 'Invalid crowd size.'})

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.user.username}'s vote for {self.bar.name} — {self.crowd_size}"

class BarImage(models.Model):
    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='images')
    image = models.URLField(max_length=500)  # Using URLField for storing image URLs
    caption = models.CharField(max_length=255, blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-uploaded_at']

    def __str__(self):
        return f"Image for {self.bar.name} @ {self.uploaded_at}"

class BarHours(models.Model):
    DAY_CHOICES = [
        ('monday', 'Monday'),
        ('tuesday', 'Tuesday'),
        ('wednesday', 'Wednesday'),
        ('thursday', 'Thursday'),
        ('friday', 'Friday'),
        ('saturday', 'Saturday'),
        ('sunday', 'Sunday'),
    ]

    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='hours')
    day = models.CharField(max_length=10, choices=DAY_CHOICES)
    open_time = models.TimeField(null=True, blank=True)
    close_time = models.TimeField(null=True, blank=True)
    is_closed = models.BooleanField(default=False)

    class Meta:
        unique_together = ('bar', 'day')
        ordering = ['day']
        indexes = [
            models.Index(fields=['bar']),
            models.Index(fields=['day']),
        ]
    
    def clean(self):
        super().clean()
        if not self.is_closed:
            if not self.open_time or not self.close_time:
                raise ValidationError({'open_time': 'Open and close times are required when bar is not closed.'})
        else:
            # If bar is closed, we don't need to validate times
            self.open_time = None
            self.close_time = None

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def __str__(self):
        if self.is_closed:
            return f"{self.bar.name} - {self.get_day_display()}: Closed"
        return f"{self.bar.name} - {self.get_day_display()}: {self.open_time.strftime('%I:%M %p')} - {self.close_time.strftime('%I:%M %p')}"
