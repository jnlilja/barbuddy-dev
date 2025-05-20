from django.test import TestCase
from django.contrib.gis.geos import Point
from django.utils import timezone
from datetime import timedelta

from apps.users.models import User
from apps.bars.models import Bar
from apps.bars.services.proximity import update_users_at_bar, update_bars_for_user

class ProximityServiceTest(TestCase):
    def setUp(self):
        # create a bar at (32.7928, -117.2556)
        self.bar = Bar.objects.create(
            name="Test Bar",
            address="123 Main St",
            average_price="$",
            location=Point(-117.2556, 32.7928, srid=4326)
        )
        # user INSIDE bubble
        self.u_inside = User.objects.create_user(username="inside", password="x")
        self.u_inside.location = Point(-117.2556, 32.7928, srid=4326)
        self.u_inside.location_updated_at = timezone.now()
        self.u_inside.save(update_fields=["location","location_updated_at"])

        # user OUTSIDE bubble (>50m away)
        self.u_outside = User.objects.create_user(username="outside", password="x")
        self.u_outside.location = Point(-117.2565, 32.7938, srid=4326)
        self.u_outside.location_updated_at = timezone.now()
        self.u_outside.save(update_fields=["location","location_updated_at"])

    def test_update_users_at_bar(self):
        update_users_at_bar(self.bar)
        self.assertIn(self.u_inside,  self.bar.users_at_bar.all())
        self.assertNotIn(self.u_outside, self.bar.users_at_bar.all())

    def test_update_bars_for_user(self):
        # clear any existing m2m
        self.bar.users_at_bar.clear()

        update_bars_for_user(self.u_inside)
        self.assertIn(self.u_inside, self.bar.users_at_bar.all())

        update_bars_for_user(self.u_outside)
        self.assertNotIn(self.u_outside, self.bar.users_at_bar.all())