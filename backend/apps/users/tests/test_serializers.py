from django.test import TestCase
from django.contrib.gis.geos import Point
from datetime import date
from apps.users.models import User
from apps.matches.models import Match
from apps.swipes.models import Swipe
from apps.users.serializers import UserSerializer, UserLocationUpdateSerializer

class UserSerializerTests(TestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(
            username="user1",
            email="user1@example.com",
            password="password123",
            date_of_birth=date(1995, 1, 1),
            hometown="Hometown1",
            job_or_university="Job1",
            favorite_drink="Coffee",
            location=Point(1.0, 2.0, srid=4326),
            profile_pictures=["pic1.jpg", "pic2.jpg"],
            account_type="trusted",
            sexual_preference="gay"
        )

        self.user2 = User.objects.create_user(
            username="user2",
            email="user2@example.com",
            password="password123",
            date_of_birth=date(1990, 1, 1),
            hometown="Hometown2",
            job_or_university="Job2",
            favorite_drink="Tea",
            location=Point(3.0, 4.0, srid=4326),
            profile_pictures=["pic3.jpg"],
            account_type="regular",
            sexual_preference="straight"
        )

        self.match = Match.objects.create(user1=self.user1, user2=self.user2, status="connected")
        self.swipe = Swipe.objects.create(swiper=self.user1, swiped_on=self.user2, status="like")

    def test_serialize_user(self):
        serializer = UserSerializer(instance=self.user1)
        data = serializer.data
        self.assertEqual(data["username"], self.user1.username)
        self.assertEqual(data["hometown"], self.user1.hometown)
        self.assertEqual(data["job_or_university"], self.user1.job_or_university)
        self.assertEqual(data["favorite_drink"], self.user1.favorite_drink)
        self.assertEqual(data["location"]["latitude"], self.user1.location.y)
        self.assertEqual(data["location"]["longitude"], self.user1.location.x)
        self.assertEqual(data["profile_pictures"], self.user1.profile_pictures)
        self.assertEqual(data["account_type"], self.user1.account_type)
        self.assertEqual(len(data["matches"]), 1)
        self.assertEqual(len(data["swipes"]), 1)
        self.assertEqual(data["sexual_preference"], self.user1.sexual_preference)

    def test_deserialize_and_create_user(self):
        data = {
            "username": "newuser",
            "email": "newuser@example.com",
            "password": "newpassword123",
            "date_of_birth": "2000-01-01",
            "hometown": "New Hometown",
            "job_or_university": "New Job",
            "favorite_drink": "Water",
            "location": {"latitude": 5.0, "longitude": 6.0},
            "profile_pictures": ["newpic1.jpg", "newpic2.jpg"],
            "account_type": "regular",
            "sexual_preference": "bisexual"
        }
        serializer = UserSerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        user = serializer.save()
        self.assertEqual(user.username, "newuser")
        self.assertEqual(user.location.x, 6.0)
        self.assertEqual(user.location.y, 5.0)
        self.assertEqual(user.sexual_preference, "bisexual")

    def test_update_user(self):
        data = {
            "first_name": "Updated",
            "last_name": "User",
            "hometown": "Updated Town",
            "location": {"latitude": 9.0, "longitude": 10.0},
            "sexual_preference": "asexual"
        }
        serializer = UserSerializer(instance=self.user1, data=data, partial=True)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        user = serializer.save()
        self.assertEqual(user.first_name, "Updated")
        self.assertEqual(user.location.x, 10.0)
        self.assertEqual(user.location.y, 9.0)
        self.assertEqual(user.sexual_preference, "asexual")

    def test_validate_date_of_birth(self):
        too_young_data = {
            "username": "teen",
            "email": "teen@example.com",
            "password": "password",
            "date_of_birth": "2010-01-01"
        }
        serializer = UserSerializer(data=too_young_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("date_of_birth", serializer.errors)

        too_old_data = {
            **too_young_data,
            "date_of_birth": "1800-01-01"
        }
        serializer = UserSerializer(data=too_old_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("date_of_birth", serializer.errors)

    def test_invalid_location(self):
        bad_location_data = {
            "username": "userX",
            "email": "x@example.com",
            "password": "xpass",
            "location": {"latitude": 1.0}
        }
        serializer = UserSerializer(data=bad_location_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("location", serializer.errors)

    def test_update_user_location(self):
        data = {"latitude": 12.34, "longitude": 56.78}
        serializer = UserLocationUpdateSerializer(instance=self.user1, data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        user = serializer.save()
        self.assertEqual(user.location.x, 56.78)
        self.assertEqual(user.location.y, 12.34)

    def test_match_and_swipe_fields(self):
        serializer = UserSerializer(instance=self.user1)
        data = serializer.data
        self.assertEqual(len(data["matches"]), 1)
        self.assertEqual(data["matches"][0]["id"], self.match.id)
        self.assertEqual(len(data["swipes"]), 1)
        self.assertEqual(data["swipes"][0]["id"], self.swipe.id)
