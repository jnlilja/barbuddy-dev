from django.db import models
from django.core.exceptions import ValidationError
from django.db.models import Avg
from django.contrib.gis.db import models as gis
from django.db import transaction
from django.contrib.gis.measure import D
from django.utils import timezone
from apps.users.models import User
from datetime import timedelta

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
        self.full_clean()
        super().save(*args, **kwargs)
        from apps.bars.services.proximity import update_users_at_bar
        update_users_at_bar(self)

    def get_latest_status(self):
        # Old code accessing the non-existent 'status_updates' related name
        # latest = self.status_updates.order_by('-last_updated').first()
        
        # New code using the correct related name 'status'
        try:
            latest = self.status
            return {
                'crowd_size': latest.crowd_size if latest else None,
                'wait_time':  latest.wait_time  if latest else None,
                'last_updated': latest.last_updated if latest else None
            }
        except BarStatus.DoesNotExist:
            return {
                'crowd_size': None,
                'wait_time': None,
                'last_updated': None
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

    def is_currently_open(self):
        """Check if the bar is currently open based on day and time"""
        current_time = timezone.localtime()
        today_name = current_time.strftime('%A').lower()  # e.g. 'monday'
        
        try:
            hours = self.hours.get(day=today_name)
            
            # If marked as closed for the day, return False
            if hours.is_closed:
                return False
                
            # Check if current time is within open and close times
            current_time_only = current_time.time()
            
            # Handle overnight hours (e.g. 10pm-2am)
            if hours.close_time < hours.open_time:
                # Bar closes after midnight
                return (current_time_only >= hours.open_time or 
                       current_time_only <= hours.close_time)
            else:
                # Regular hours (e.g. 11am-11pm)
                return hours.open_time <= current_time_only <= hours.close_time
                
        except BarHours.DoesNotExist:
            # If no hours set for today, assume closed
            return False

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

    bar = models.OneToOneField(Bar, on_delete=models.CASCADE, related_name='status')
    crowd_size = models.CharField(max_length=50, choices=CROWD_CHOICES)
    wait_time = models.CharField(max_length=50, choices=WAIT_TIME_CHOICES)
    last_updated = models.DateTimeField(auto_now=True)
    wait_time_votes = models.PositiveIntegerField(default=0)
    crowd_size_votes = models.PositiveIntegerField(default=0)

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

    class Meta:
        indexes = [
            models.Index(fields=['bar']),
            models.Index(fields=['last_updated']),
        ]


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

        ### COMENTING OUT UNIQUE CONSTRAINTS FOR NOW
        # constraints = [
        #     models.UniqueConstraint(fields=['bar', 'user'], name='unique_wait_time_vote_per_bar_user')
        # ]
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
        ### COMENTING OUT UNIQUE CONSTRAINTS FOR NOW
        # constraints = [
        #     models.UniqueConstraint(fields=['bar', 'user'], name='unique_crowd_size_vote_per_bar_user')
        # ]
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

# Signal handlers for automatic status updates
from django.db.models.signals import post_save
from django.dispatch import receiver

@receiver(post_save, sender=BarVote)
@receiver(post_save, sender=BarCrowdSize)
def update_bar_status_on_vote(sender, instance, created, **kwargs):
    """Update the BarStatus for a bar whenever a new vote is submitted"""
    from apps.bars.services.voting import aggregate_bar_votes
    
    # Get the bar ID from the vote
    bar_id = instance.bar_id
    
    # Get aggregated vote results (only from last hour)
    result = aggregate_bar_votes(bar_id, lookback_hours=1)
    
    # Skip if no votes to aggregate
    if not result['crowd_size'] and not result['wait_time']:
        return
    
    # Get or create the status object
    status, created = BarStatus.objects.get_or_create(
        bar_id=bar_id,
        defaults={
            'crowd_size': result['crowd_size'] or 'moderate',
            'wait_time': result['wait_time'] or '<5 min',
            'crowd_size_votes': instance.bar.crowd_size_votes.filter(
                timestamp__gte=timezone.now() - timedelta(hours=1)
            ).count(),
            'wait_time_votes': instance.bar.wait_time_votes.filter(
                timestamp__gte=timezone.now() - timedelta(hours=1)
            ).count()
        }
    )
    
    if not created:
        # Update existing status with aggregated values from last hour
        if result['crowd_size']:
            status.crowd_size = result['crowd_size']
        if result['wait_time']:
            status.wait_time = result['wait_time']
            
        # Update vote counts to show only recent votes
        status.crowd_size_votes = instance.bar.crowd_size_votes.filter(
            timestamp__gte=timezone.now() - timedelta(hours=1)
        ).count()
        
        status.wait_time_votes = instance.bar.wait_time_votes.filter(
            timestamp__gte=timezone.now() - timedelta(hours=1)
        ).count()
        
        status.save()
