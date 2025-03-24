from django.test import TestCase
from django.contrib.auth import get_user_model
from django.contrib.gis.geos import Point
from datetime import date, timedelta
from unittest.mock import patch, MagicMock

from apps.users.serializers import UserSerializer
from apps.matches.models import Match
from apps.swipes.models import Swipe

User = get_user_model()

class UserSerializerTest(TestCase):
    def setUp(self):
        self.user_data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'securepassword123',
            'first_name': 'Test',
            'last_name': 'User',
            'date_of_birth': date.today() - timedelta(days=365 * 25),
            'height': 175,
            'hometown': 'Test City',
            'job_or_university': 'Test Company',
            'favorite_drink': 'Water',
            'location': {'latitude': 37.7749, 'longitude': -122.4194},
            'profile_pictures': ['pic1.jpg', 'pic2.jpg']
        }

        self.user = User.objects.create_user(
            username='existinguser',
            email='existing@example.com',
            password='password123',
            date_of_birth=date.today() - timedelta(days=365 * 30),
            height=180,
            hometown='Existing City',
            job_or_university='Existing Company',
            favorite_drink='Coffee',
            location=Point(-122.4194, 37.7749, srid=4326),
            profile_pictures=['existing1.jpg', 'existing2.jpg']
        )

    def test_serializer_with_valid_data(self):
        serializer = UserSerializer(data=self.user_data)
        self.assertTrue(serializer.is_valid())

    def test_serializer_create_method(self):
        serializer = UserSerializer(data=self.user_data)
        self.assertTrue(serializer.is_valid())

        user = serializer.save()
        self.assertEqual(user.username, 'testuser')
        self.assertEqual(user.email, 'test@example.com')
        self.assertEqual(user.first_name, 'Test')
        self.assertEqual(user.height, 175)
        self.assertNotEqual(user.password, 'securepassword123')
        self.assertTrue(user.check_password('securepassword123'))
        self.assertIsInstance(user.location, Point)
        self.assertEqual(user.location.x, -122.4194)
        self.assertEqual(user.location.y, 37.7749)

    def test_serializer_update_method(self):
        update_data = {
            'first_name': 'Updated',
            'last_name': 'Name',
            'password': 'newpassword123',
            'height': 190,
            'location': {'latitude': 34.0522, 'longitude': -118.2437}
        }

        serializer = UserSerializer(self.user, data=update_data, partial=True)
        self.assertTrue(serializer.is_valid())
        updated_user = serializer.save()
        self.assertEqual(updated_user.first_name, 'Updated')
        self.assertEqual(updated_user.last_name, 'Name')
        self.assertEqual(updated_user.height, 190)
        self.assertTrue(updated_user.check_password('newpassword123'))
        self.assertEqual(updated_user.location.x, -118.2437)
        self.assertEqual(updated_user.location.y, 34.0522)
        self.assertEqual(updated_user.hometown, 'Existing City')

    def test_date_of_birth_validation(self):
        too_young = self.user_data.copy()
        too_young['date_of_birth'] = date.today() - timedelta(days=365 * 17)
        serializer = UserSerializer(data=too_young)
        self.assertFalse(serializer.is_valid())
        self.assertIn('date_of_birth', serializer.errors)

        too_old = self.user_data.copy()
        too_old['date_of_birth'] = date.today() - timedelta(days=365 * 121)
        serializer = UserSerializer(data=too_old)
        self.assertFalse(serializer.is_valid())
        self.assertIn('date_of_birth', serializer.errors)

    def test_location_serialization(self):
        serializer = UserSerializer(self.user)
        data = serializer.data
        self.assertIn('location', data)
        self.assertEqual(data['location']['latitude'], 37.7749)
        self.assertEqual(data['location']['longitude'], -122.4194)

    def test_location_validation(self):
        invalid_data = self.user_data.copy()
        invalid_data['location'] = {'latitude': 37.7749}  # Missing longitude
        serializer = UserSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn('location', serializer.errors)

    def test_password_write_only(self):
        serializer = UserSerializer(self.user)
        data = serializer.data
        self.assertNotIn('password', data)

    @patch('apps.matches.models.Match.objects')
    @patch('apps.swipes.models.Swipe.objects')
    def test_get_matches(self, mock_swipe_objects, mock_match_objects):
        mock_match = MagicMock()
        mock_match_qs = MagicMock()
        mock_match_objects.filter.return_value = mock_match_qs
        mock_match_qs.__or__.return_value = mock_match_qs
        mock_match_qs.distinct.return_value = [mock_match]

        serializer = UserSerializer(self.user)
        matches = serializer.get_matches(self.user)

        self.assertEqual(mock_match_objects.filter.call_count, 2)
        args1, kwargs1 = mock_match_objects.filter.call_args_list[0]
        self.assertEqual(kwargs1['user1'], self.user)
        self.assertEqual(kwargs1['status'], 'connected')
        args2, kwargs2 = mock_match_objects.filter.call_args_list[1]
        self.assertEqual(kwargs2['user2'], self.user)
        self.assertEqual(kwargs2['status'], 'connected')

    @patch('apps.swipes.models.Swipe.objects')
    def test_get_swipes(self, mock_swipe_objects):
        mock_swipe = MagicMock()
        mock_swipe_objects.filter.return_value = [mock_swipe]

        serializer = UserSerializer(self.user)
        swipes = serializer.get_swipes(self.user)
        mock_swipe_objects.filter.assert_called_once_with(swiper=self.user)

    @patch('apps.matches.models.Match.objects')
    def test_get_match_count(self, mock_match_objects):
        mock_qs1 = MagicMock()
        mock_qs1.count.return_value = 5
        mock_qs2 = MagicMock()
        mock_qs2.count.return_value = 3
        mock_match_objects.filter.side_effect = [mock_qs1, mock_qs2]

        serializer = UserSerializer(self.user)
        count = serializer.get_match_count(self.user)
        self.assertEqual(count, 8)
        self.assertEqual(mock_match_objects.filter.call_count, 2)

        args1, kwargs1 = mock_match_objects.filter.call_args_list[0]
        self.assertEqual(kwargs1['user1'], self.user)
        self.assertEqual(kwargs1['status'], 'connected')
        args2, kwargs2 = mock_match_objects.filter.call_args_list[1]
        self.assertEqual(kwargs2['user2'], self.user)
        self.assertEqual(kwargs2['status'], 'connected')