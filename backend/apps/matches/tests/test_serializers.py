from django.test import TestCase
from rest_framework.exceptions import ValidationError
from apps.matches.models import Match
from apps.matches.serializers import MatchSerializer, MatchUserSerializer
from apps.users.models import User
from django.contrib.gis.geos import Point


class MatchSerializerTests(TestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(
            username="user1",
            email="user1@example.com",
            password="password123",
            first_name="User",
            last_name="One",
            profile_pictures=["pic1.jpg"]
        )
        self.user2 = User.objects.create_user(
            username="user2",
            email="user2@example.com",
            password="password123",
            first_name="User",
            last_name="Two",
            profile_pictures=["pic2.jpg"]
        )
        self.user3 = User.objects.create_user(
            username="user3",
            email="user3@example.com",
            password="password123"
        )

        self.match = Match.objects.create(user1=self.user1, user2=self.user2, status="connected")

    def test_match_user_serializer(self):
        serializer = MatchUserSerializer(instance=self.user1)
        data = serializer.data
        self.assertEqual(data["id"], self.user1.id)
        self.assertEqual(data["username"], self.user1.username)
        self.assertEqual(data["first_name"], self.user1.first_name)
        self.assertEqual(data["last_name"], self.user1.last_name)
        self.assertEqual(data["profile_pictures"], self.user1.profile_pictures)

    def test_match_serializer_serialization(self):
        serializer = MatchSerializer(instance=self.match)
        data = serializer.data
        self.assertEqual(data["id"], self.match.id)
        self.assertEqual(data["user1_details"]["id"], self.user1.id)
        self.assertEqual(data["user2_details"]["id"], self.user2.id)
        self.assertEqual(data["user1_details"]["username"], self.user1.username)
        self.assertEqual(data["user2_details"]["username"], self.user2.username)
        self.assertEqual(data["status"], "connected")
        self.assertNotIn("disconnected_by", data)
        self.assertIsNone(data["disconnected_by_username"])

    def test_match_serializer_deserialization(self):
        data = {
            "user1": self.user1.id,
            "user2": self.user3.id,
            "status": "pending"
        }
        serializer = MatchSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        match = serializer.save()
        self.assertEqual(match.user1, self.user1)
        self.assertEqual(match.user2, self.user3)
        self.assertEqual(match.status, "pending")
        self.assertIsNone(match.disconnected_by)

    def test_self_matching_validation(self):
        data = {
            "user1": self.user1.id,
            "user2": self.user1.id,
            "status": "pending"
        }
        serializer = MatchSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("non_field_errors", serializer.errors)
        self.assertEqual(serializer.errors["non_field_errors"][0], "A user cannot match with themselves.")

    def test_disconnected_by_validation(self):
        data = {
            "user1": self.user1.id,
            "user2": self.user3.id, 
            "status": "pending",
            "disconnected_by": self.user1.id
        }
        serializer = MatchSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("non_field_errors", serializer.errors)
        self.assertIn("Disconnected_by can only be set when status is 'disconnected'.", str(serializer.errors["non_field_errors"][0]))

    def test_disconnected_status_with_disconnected_by(self):
        data = {
            "user1": self.user1.id,
            "user2": self.user3.id,  
            "status": "disconnected",
            "disconnected_by": self.user1.id
        }
        serializer = MatchSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        match = serializer.save()
        self.assertEqual(match.status, "disconnected")
        self.assertEqual(match.disconnected_by, self.user1)
