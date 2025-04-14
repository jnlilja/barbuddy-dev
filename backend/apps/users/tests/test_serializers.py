from django.test import TestCase
from django.contrib.gis.geos import Point
from datetime import date, timedelta
from apps.users.models import User
from apps.matches.models import Match
from apps.swipes.models import Swipe
from apps.users.serializers import UserSerializer

class UserSerializerTests(TestCase):
    def setUp(self):
        # Create test users
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
            account_type="trusted"
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
            account_type="regular"
        )

        # Create test match and swipe
        self.match = Match.objects.create(user1=self.user1, user2=self.user2, status="connected")
        self.swipe = Swipe.objects.create(swiper=self.user1, swiped=self.user2, direction="right")

    def test_serialize_user(self):
        """Test serializing a user."""
        serializer = UserSerializer(instance=self.user1)
        data = serializer.data
        self.assertEqual(data["username"], self.user1.username)
        self.assertEqual(data["email"], self.user1.email)
        self.assertEqual(data["hometown"], self.user1.hometown)
        self.assertEqual(data["job_or_university"], self.user1.job_or_university)
        self.assertEqual(data["favorite_drink"], self.user1.favorite_drink)
        self.assertEqual(data["location"]["latitude"], self.user1.location.y)
        self.assertEqual(data["location"]["longitude"], self.user1.location.x)
        self.assertEqual(data["profile_pictures"], self.user1.profile_pictures)
        self.assertEqual(data["account_type"], self.user1.account_type)
        self.assertEqual(len(data["matches"]), 1)
        self.assertEqual(len(data["swipes"]), 1)

    def test_deserialize_and_create_user(self):
        """Test deserializing and creating a user."""
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
            "account_type": "regular"
        }
        serializer = UserSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        user = serializer.save()
        self.assertEqual(user.username, "newuser")
        self.assertEqual(user.email, "newuser@example.com")
        self.assertEqual(user.hometown, "New Hometown")
        self.assertEqual(user.job_or_university, "New Job")
        self.assertEqual(user.favorite_drink, "Water")
        self.assertEqual(user.location.x, 6.0)
        self.assertEqual(user.location.y, 5.0)
        self.assertEqual(user.profile_pictures, ["newpic1.jpg", "newpic2.jpg"])
        self.assertEqual(user.account_type, "regular")

    def test_update_user(self):
        """Test updating a user."""
        data = {
            "first_name": "Updated",
            "last_name": "User",
            "hometown": "Updated Hometown",
            "job_or_university": "Updated Job",
            "favorite_drink": "Juice",
            "location": {"latitude": 7.0, "longitude": 8.0},
        }
        serializer = UserSerializer(instance=self.user1, data=data, partial=True)
        self.assertTrue(serializer.is_valid())
        user = serializer.save()
        self.assertEqual(user.first_name, "Updated")
        self.assertEqual(user.last_name, "User")
        self.assertEqual(user.hometown, "Updated Hometown")
        self.assertEqual(user.job_or_university, "Updated Job")
        self.assertEqual(user.favorite_drink, "Juice")
        self.assertEqual(user.location.x, 8.0)
        self.assertEqual(user.location.y, 7.0)

    def test_validate_date_of_birth(self):
        """Test validation for date_of_birth."""
        data = {
            "username": "newuser",
            "email": "newuser@example.com",
            "password": "newpassword123",
            "date_of_birth": "2010-01-01",  # Too young
        }
        serializer = UserSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("date_of_birth", serializer.errors)
        self.assertEqual(serializer.errors["date_of_birth"][0], "You must be at least 18 years old.")

        data["date_of_birth"] = "1800-01-01"  # Too old
        serializer = UserSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("date_of_birth", serializer.errors)
        self.assertEqual(serializer.errors["date_of_birth"][0], "Age cannot exceed 120.")

    def test_invalid_location(self):
        """Test invalid location data."""
        data = {
            "username": "newuser",
            "email": "newuser@example.com",
            "password": "newpassword123",
            "location": {"latitude": 5.0},  # Missing longitude
        }
        serializer = UserSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("location", serializer.errors)
        self.assertEqual(serializer.errors["location"][0], "Must include 'latitude' and 'longitude'.")

    def test_match_and_swipe_fields(self):
        """Test matches and swipes fields."""
        serializer = UserSerializer(instance=self.user1)
        data = serializer.data
        self.assertEqual(len(data["matches"]), 1)
        self.assertEqual(data["matches"][0]["id"], self.match.id)
        self.assertEqual(len(data["swipes"]), 1)
        self.assertEqual(data["swipes"][0]["id"], self.swipe.id)