from django.test import TestCase
from rest_framework.exceptions import ValidationError
from apps.matches.models import Match
from apps.matches.serializers import MatchSerializer, MatchUserSerializer
from apps.users.models import User


class MatchSerializerTests(TestCase):
    def setUp(self):
        # Create test users
        self.user1 = User.objects.create_user(
            username='testuser1',
            email='test1@example.com',
            password='testpass123',
            first_name='Test',
            last_name='User1',
            profile_pictures=['pic1.jpg', 'pic2.jpg']
        )
        self.user2 = User.objects.create_user(
            username='testuser2',
            email='test2@example.com',
            password='testpass123',
            first_name='Test',
            last_name='User2',
            profile_pictures=['pic3.jpg']
        )
        self.user3 = User.objects.create_user(
            username='testuser3',
            email='test3@example.com',
            password='testpass123'
        )

        # Create a sample match
        self.match = Match.objects.create(
            user1=self.user1,
            user2=self.user2,
            status='connected'
        )

    def test_match_user_serializer(self):
        """Test the MatchUserSerializer"""
        serializer = MatchUserSerializer(self.user1)
        data = serializer.data

        self.assertEqual(data['id'], self.user1.id)
        self.assertEqual(data['username'], 'testuser1')
        self.assertEqual(data['first_name'], 'Test')
        self.assertEqual(data['last_name'], 'User1')
        self.assertEqual(data['profile_pictures'], ['pic1.jpg', 'pic2.jpg'])

    def test_match_serializer(self):
        """Test the MatchSerializer with a connected match"""
        serializer = MatchSerializer(self.match)
        data = serializer.data

        self.assertEqual(data['id'], self.match.id)
        self.assertEqual(data['status'], 'connected')
        self.assertEqual(data['disconnected_by_username'], None)

        # Test user1 details
        self.assertEqual(data['user1_details']['id'], self.user1.id)
        self.assertEqual(data['user1_details']['username'], 'testuser1')

        # Test user2 details
        self.assertEqual(data['user2_details']['id'], self.user2.id)
        self.assertEqual(data['user2_details']['username'], 'testuser2')

        # Ensure write-only fields are not in the serialized data
        self.assertNotIn('user1', data)
        self.assertNotIn('user2', data)
        self.assertNotIn('disconnected_by', data)

    def test_match_serializer_disconnected(self):
        """Test the MatchSerializer with a disconnected match"""
        # Update match to disconnected
        self.match.status = 'disconnected'
        self.match.disconnected_by = self.user1
        self.match.save()

        serializer = MatchSerializer(self.match)
        data = serializer.data

        self.assertEqual(data['status'], 'disconnected')
        self.assertEqual(data['disconnected_by_username'], 'testuser1')

    def test_validate_prevent_self_matching(self):
        """Test validation to prevent self-matching"""
        data = {
            'user1': self.user1.id,
            'user2': self.user1.id,
            'status': 'pending'
        }

        serializer = MatchSerializer(data=data)
        with self.assertRaises(ValidationError):
            serializer.is_valid(raise_exception=True)

    def test_validate_disconnected_by(self):
        """Test validation for disconnected_by field"""
        # Test setting disconnected_by with status not being 'disconnected'
        data = {
            'user1': self.user1.id,
            'user2': self.user2.id,
            'status': 'connected',
            'disconnected_by': self.user1.id
        }

        serializer = MatchSerializer(data=data)
        with self.assertRaises(ValidationError):
            serializer.is_valid(raise_exception=True)

    def test_create_match(self):
        """Test creating a match through the serializer"""
        data = {
            'user1': self.user1.id,
            'user2': self.user3.id,
            'status': 'pending'
        }

        serializer = MatchSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        match = serializer.save()

        self.assertEqual(match.user1, self.user1)
        self.assertEqual(match.user2, self.user3)
        self.assertEqual(match.status, 'pending')

    def test_update_match(self):
        """Test updating a match through the serializer"""
        data = {
            'user1': self.user1.id,
            'user2': self.user2.id,
            'status': 'disconnected',
            'disconnected_by': self.user2.id
        }

        serializer = MatchSerializer(self.match, data=data)
        self.assertTrue(serializer.is_valid())
        updated_match = serializer.save()

        self.assertEqual(updated_match.status, 'disconnected')
        self.assertEqual(updated_match.disconnected_by, self.user2)
