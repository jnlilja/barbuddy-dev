from django.contrib.gis.measure import D
from django.contrib.gis.db.models.functions import Distance
from apps.users.models import User

def update_users_at_bar(bar, radius_meters=50):
    if not bar.location:
        return

    nearby_users = User.objects.filter(
        location__distance_lte=(bar.location, D(m=radius_meters))
    )

    bar.users_at_bar.set(nearby_users)