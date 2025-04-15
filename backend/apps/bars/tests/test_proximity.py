from django.contrib.gis.geos import Point
from django.test import TestCase
from apps.users.models import User
from apps.bars.models import Bar
from apps.bars.services.proximity import update_users_at_bar

class ProximityUpdateTests(TestCase):
    def setUp(self):
        self.bar = Bar.objects.create(
            name="GeoBar",
            address="789 Radius Rd",
            average_price="$$",
            location=Point(-117.0, 32.0, srid=4326)
        )

        self.nearby_user = User.objects.create_user(
            username="nearby_user",
            password="test123",
            location=Point(-117.0001, 32.0001, srid=4326)
        )

        self.far_user = User.objects.create_user(
            username="far_user",
            password="test123",
            location=Point(-118.0, 33.0, srid=4326)
        )

    def test_users_within_radius_added_to_bar(self):
        update_users_at_bar(self.bar, radius_meters=1000)
        users = self.bar.users_at_bar.all()
        self.assertIn(self.nearby_user, users)
        self.assertNotIn(self.far_user, users)
