from django.test import TestCase
from django.core.exceptions import ValidationError
from django.db import IntegrityError
from apps.matches.models import Match
from apps.users.models import User

class MatchModelTest(TestCase):
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

    def test_create_valid_match(self):
        """Test creating a valid match."""
        match = Match.objects.create(user1=self.user1, user2=self.user2, status="pending")
        self.assertEqual(match.user1, self.user1)
        self.assertEqual(match.user2, self.user2)
        self.assertEqual(match.status, "pending")
        self.assertIsNone(match.disconnected_by)
        self.assertIsNotNone(match.created_at)

    def test_user_cannot_match_with_themselves(self):
        """Test that a user cannot match with themselves."""
        match = Match(user1=self.user1, user2=self.user1, status="pending")
        with self.assertRaises(ValidationError) as context:
            match.clean()
        self.assertIn("A user cannot match with themselves.", str(context.exception))

    def test_invalid_status(self):
        """Test that an invalid status raises a validation error."""
        match = Match(user1=self.user1, user2=self.user2, status="invalid_status")
        with self.assertRaises(ValidationError) as context:
            match.clean()
        self.assertIn("Invalid status. Choose from:", str(context.exception))

    def test_disconnected_by_without_disconnected_status(self):
        """Test that disconnected_by is only set when status is 'disconnected'."""
        match = Match(user1=self.user1, user2=self.user2, status="pending", disconnected_by=self.user1)
        with self.assertRaises(ValidationError) as context:
            match.clean()
        self.assertIn("This field should only be set when status is \"disconnected\".", str(context.exception))

    def test_disconnected_by_invalid_user(self):
        """Test that disconnected_by must be one of the matched users."""
        match = Match(user1=self.user1, user2=self.user2, status="disconnected", disconnected_by=self.user3)
        with self.assertRaises(ValidationError) as context:
            match.clean()
        self.assertIn("Only matched users can disconnect the match.", str(context.exception))

    def test_duplicate_match(self):
        """Test that duplicate matches are not allowed."""
        Match.objects.create(user1=self.user1, user2=self.user2, status="connected")
        duplicate_match = Match(user1=self.user2, user2=self.user1, status="pending")
        with self.assertRaises(ValidationError) as context:
            duplicate_match.clean()
        self.assertIn("A match between these users already exists.", str(context.exception))

    def test_str_representation(self):
        """Test the string representation of the Match model."""
        match = Match.objects.create(user1=self.user1, user2=self.user2, status="connected")
        self.assertEqual(str(match), f"{self.user1} - {self.user2} (connected)")
