from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from django.db import models
from datetime import date
from django.contrib.gis.db import models as gis

class User(AbstractUser):
    phone_number = models.CharField(max_length=15, blank=True, null=True, unique=True)
    date_of_birth = models.DateField(null=True, blank=True)
    hometown = models.CharField(max_length=255, blank=True)
    job_or_university = models.CharField(max_length=255, blank=True)
    favorite_drink = models.CharField(max_length=100, blank=True)
    location = gis.PointField(geography=True, srid=4326, null=True, blank=True)
    vote_weight = models.IntegerField(default=1)
    friends = models.ManyToManyField('self', symmetrical=True, blank=True)

    firebase_uid = models.CharField(max_length=128, blank=True, null=True, unique=True)


    SEXUAL_PREFERENCE_CHOICES = [
        ('straight', 'Straight'),
        ('gay', 'Gay'),
        ('bisexual', 'Bisexual'),
        ('asexual', 'Asexual'),
        ('pansexual', 'Pansexual'),
        ('other', 'Other'),
    ]
    
    sexual_preference = models.CharField(
        max_length=20,
        choices=SEXUAL_PREFERENCE_CHOICES,
        blank=True,
        null=True
    )

    ACCOUNT_TYPE_CHOICES = [
        ('regular', 'Regular'),
        ('trusted', 'Trusted'),
        ('moderator', 'Moderator'),
        ('admin', 'Admin'),
    ]
    account_type = models.CharField(max_length=20, choices=ACCOUNT_TYPE_CHOICES, default='regular')

    def clean(self):
        super().clean()
        if self.date_of_birth:
            today = date.today()
            age = today.year - self.date_of_birth.year - (
                (today.month, today.day) < (self.date_of_birth.month, self.date_of_birth.day)
            )
            if age < 18 or age > 120:
                raise ValidationError({'date_of_birth': 'User must be between 18 and 120 years old.'})

        if self.pk is None or User.objects.filter(email=self.email).exclude(pk=self.pk).exists():
            raise ValidationError({'email': 'This email is already in use.'})

        if User.objects.filter(username=self.username).exclude(pk=self.pk).exists():
            raise ValidationError({'username': 'This username is already taken.'})

    def get_age(self):
        if not self.date_of_birth:
            return None
        today = date.today()
        return today.year - self.date_of_birth.year - (
            (today.month, today.day) < (self.date_of_birth.month, self.date_of_birth.day)
        )

    class Meta:
        indexes = [
            models.Index(fields=['username']),
            models.Index(fields=['email']),
        ]

    def save(self, *args, **kwargs):
        # Remove self.clean() to avoid re-validation during every save
        account_weights = {
            'regular': 1,
            'trusted': 2,
            'moderator': 3,
            'admin': 5
        }
        self.vote_weight = account_weights.get(self.account_type, 1)
        super().save(*args, **kwargs)



class FriendRequest(models.Model):
    from_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_requests')
    to_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_requests')
    status = models.CharField(max_length=10, choices=[('pending', 'Pending'), ('accepted', 'Accepted'), ('declined', 'Declined')], default='pending')
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('from_user', 'to_user')

    def __str__(self):
        return f"{self.from_user} -> {self.to_user} [{self.status}]"


# from django.contrib.auth import get_user_model

# User = get_user_model()

from django.db import transaction

class ProfilePicture(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="profile_pictures")
    image = models.ImageField(upload_to="profile_pictures/")
    is_primary = models.BooleanField(default=False)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        with transaction.atomic():
            if self.is_primary:
                # Set all other pictures of this user to not primary
                ProfilePicture.objects.filter(user=self.user, is_primary=True).update(is_primary=False)
            # If this is the user's first picture, make it primary
            elif not ProfilePicture.objects.filter(user=self.user).exists():
                self.is_primary = True
            super().save(*args, **kwargs)

    class Meta:
        ordering = ['-is_primary', '-uploaded_at']