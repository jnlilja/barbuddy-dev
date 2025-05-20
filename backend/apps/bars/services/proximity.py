from django.contrib.gis.measure import D
from django.contrib.gis.db.models.functions import Distance
from django.utils import timezone
from django.db import transaction
from datetime import timedelta

from apps.users.models import User
from apps.bars.models import Bar

def update_users_at_bar(bar):
    # get all users within 50 m
    nearby = (
        User.objects
            .exclude(location__isnull=True)
            .annotate(dist=Distance('location', bar.location))
            .filter(dist__lte=D(m=50))
    )
    # overwrite the many‐to‐many set
    bar.users_at_bar.set(nearby)

def update_bars_for_user(user, radius_m=50, fresh_minutes=15):
    """Add/remove user from every nearby bar."""
    from django.db.models import Q

    recent_cutoff = timezone.now() - timedelta(minutes=fresh_minutes)
    # Bars in whose bubble the user now is:
    nearby_bars = Bar.objects.filter(
        location__distance_lte=(user.location, D(m=radius_m))
    )
    # Update each bar’s m2m
    for bar in nearby_bars:
        update_users_at_bar(bar)

    # Remove user from bars now too-far
    too_far = Bar.objects.exclude(pk__in=[b.pk for b in nearby_bars])
    for bar in too_far.filter(users_at_bar=user):
        bar.users_at_bar.remove(user)