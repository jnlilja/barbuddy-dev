from django.test import TestCase
from django.core.exceptions import ValidationError
from django.db import IntegrityError
from apps.matches.models import Match
from apps.users.models import User

class MatchModelTests(TestCase):
    def setUp(self):
        # Create test users
        self.user1 = User.objects.create_user(
            username='testuser1',
            email='test1@example.com',
            password='testpass123'
        )
        self.user2 = User.objects.create_user(
            username='testuser2',
            email='test2@example.com',
            password='testpass123'
        )
        self.user3 = User.objects.create_user(
            username='testuser3',
            email='test3@example.com',
            password='testpass123'
        )

    def test_create_valid_match(self):
        """Test creating a valid match between two users"""
        match = Match.objects.create(
            user1=self.user1,
            user2=self.user2,
            status='pending'
        )
        self.assertEqual(match.user1, self.user1)
        self.assertEqual(match.user2, self.user2)
        self.assertEqual(match.status, 'pending')
        self.assertIsNone(match.disconnected_by)
        self.assertIsNotNone(match.created_at)

    def test_match_unique_constraint(self):
        """Test that the same match can't be created twice"""
        Match.objects.create(
            user1=self.user1,
            user2=self.user2,
            status='pending'
        )

        # Try to create the same match again
        with self.assertRaises(IntegrityError):
            Match.objects.create(
                user1=self.user1,
                user2=self.user2,
                status='pending'
            )

    def test_match_reverse_unique_constraint(self):
        """Test that a match can't be created in reverse order"""
        # Create match with clean() validation bypassed
        Match.objects.create(
            user1=self.user1,
            user2=self.user2,
            status='pending'
        )

        # This should fail during clean validation
        reverse_match = Match(
            user1=self.user2,
            user2=self.user1,
            status='pending'
        )
        with self.assertRaises(ValidationError):
            reverse_match.clean()

    def test_prevent_self_matching(self):
        """Test that a user cannot match with themselves"""
        match = Match(
            user1=self.user1,
            user2=self.user1,
            status='pending'
        )
        with self.assertRaises(ValidationError):
            match.clean()

    def test_invalid_status(self):
        """Test validation for invalid status"""
        match = Match(
            user1=self.user1,
            user2=self.user2,
            status='invalid_status'
        )
        with self.assertRaises(ValidationError):
            match.clean()

    def test_disconnect_match(self):
        """Test disconnecting a match"""
        match = Match.objects.create(
            user1=self.user1,
            user2=self.user2,
            status='connected'
        )

        match.status = 'disconnected'
        match.disconnected_by = self.user1
        match.save()

        updated_match = Match.objects.get(id=match.id)
        self.assertEqual(updated_match.status, 'disconnected')
        self.assertEqual(updated_match.disconnected_by, self.user1)

    def test_disconnect_validation(self):
        """Test validations for disconnecting a match"""
        match = Match.objects.create(
            user1=self.user1,
            user2=self.user2,
            status='connected'
        )

        # Test invalid disconnection (disconnected_by set but status not 'disconnected')
        match.disconnected_by = self.user1
        with self.assertRaises(ValidationError):
            match.clean()

        # Test invalid disconnection (user not in the match)
        match.status = 'disconnected'
        match.disconnected_by = self.user3
        with self.assertRaises(ValidationError):
            match.clean()

    def test_string_representation(self):
        """Test the string representation of a Match"""
        match = Match.objects.create(
            user1=self.user1,
            user2=self.user2,
            status='pending'
        )
        expected_string = f"{self.user1} - {self.user2} (pending)"
        self.assertEqual(str(match), expected_string)
