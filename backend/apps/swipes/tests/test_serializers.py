from django.test import TestCase
from rest_framework.exceptions import ValidationError
from rest_framework.test import APIRequestFactory
from apps.swipes.models import Swipe
from apps.users.models import User
from apps.swipes.serializers import SwipeSerializer

class SwipeSerializerTests(TestCase):
    def setUp(self):
        # Create test users
        self.user1 = User.objects.create_user(
            username="user1",
            email="user1@example.com",
            password="password123"
        )
        self.user2 = User.objects.create_user(
            username="user2",
            email="user2@example.com",
            password="password123"
        )
        self.user3 = User.objects.create_user(
            username="user3",
            email="user3@example.com",
            password="password123"
        )

        # Create a request factory for simulating requests
        self.factory = APIRequestFactory()

    def test_serialize_swipe(self):
        """Test serializing a swipe."""
        swipe = Swipe.objects.create(swiper=self.user1, swiped_on=self.user2, status="like")
        serializer = SwipeSerializer(instance=swipe)
        data = serializer.data
        self.assertEqual(data["swiper_username"], self.user1.username)
        self.assertEqual(data["swiped_on_username"], self.user2.username)
        self.assertEqual(data["status"], "like")

    def test_deserialize_and_create_swipe(self):
        """Test deserializing and creating a swipe."""
        request = self.factory.post("/api/swipes/")
        request.user = self.user1  # Simulate an authenticated user
        data = {
            "swiped_on": self.user2.id,
            "status": "like"
        }
        serializer = SwipeSerializer(data=data, context={"request": request})
        self.assertTrue(serializer.is_valid())
        swipe = serializer.save()
        self.assertEqual(swipe.swiper, self.user1)
        self.assertEqual(swipe.swiped_on, self.user2)
        self.assertEqual(swipe.status, "like")

    def test_swipe_on_self_validation(self):
        """Test validation for swiping on oneself."""
        request = self.factory.post("/api/swipes/")
        request.user = self.user1  # Simulate an authenticated user
        data = {
            "swiped_on": self.user1.id,
            "status": "like"
        }
        serializer = SwipeSerializer(data=data, context={"request": request})
        self.assertFalse(serializer.is_valid())
        self.assertIn("non_field_errors", serializer.errors)
        self.assertEqual(serializer.errors["non_field_errors"][0], "You cannot swipe on yourself.")

    def test_read_only_fields(self):
        """Test that read-only fields cannot be modified."""
        swipe = Swipe.objects.create(swiper=self.user1, swiped_on=self.user2, status="like")
        request = self.factory.patch("/api/swipes/")  # Simulate a PATCH request
        request.user = self.user1  # Simulate an authenticated user
        data = {
            "swiped_on": self.user2.id,  # Include required field
            "timestamp": "2025-01-01T00:00:00Z"
        }
        serializer = SwipeSerializer(instance=swipe, data=data, partial=True, context={"request": request})
        self.assertTrue(serializer.is_valid())
        updated_swipe = serializer.save()
        self.assertNotEqual(updated_swipe.timestamp.isoformat(), "2025-01-01T00:00:00Z")  # Timestamp should remain unchanged

