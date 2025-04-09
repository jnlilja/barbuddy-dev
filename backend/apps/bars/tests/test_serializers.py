from django.test import TestCase
from django.contrib.gis.geos import Point
from apps.bars.models import Bar, BarStatus, BarRating
from apps.bars.serializers import BarSerializer, BarStatusSerializer
from apps.users.models import User


class BarSerializerTests(TestCase):
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

        # Create a test bar
        self.bar = Bar.objects.create(
            name='Test Bar',
            address='123 Test Street',
            average_price='$$',
            location=Point(1.0, 2.0, srid=4326)  # longitude, latitude
        )

        # Add users to bar
        self.bar.users_at_bar.add(self.user1)

        # Create bar status
        self.status = BarStatus.objects.create(
            bar=self.bar,
            crowd_size='moderate',
            wait_time='5-10 min'
        )

        # Create bar rating
        self.rating = BarRating.objects.create(
            bar=self.bar,
            user=self.user1,
            rating=4,
            review="Great place!"
        )

    def test_bar_serialization(self):
        """Test serializing a bar with all its related data"""
        serializer = BarSerializer(self.bar)
        data = serializer.data

        # Check basic fields
        self.assertEqual(data['id'], self.bar.id)
        self.assertEqual(data['name'], 'Test Bar')
        self.assertEqual(data['address'], '123 Test Street')
        self.assertEqual(data['average_price'], '$$')

        # Check location
        self.assertEqual(data['location']['latitude'], 2.0)
        self.assertEqual(data['location']['longitude'], 1.0)

        # Check users at bar
        self.assertEqual(len(data['users_at_bar']), 1)
        self.assertEqual(data['users_at_bar'][0], self.user1.id)

        # Check current status
        self.assertEqual(data['current_status']['crowd_size'], 'moderate')
        self.assertEqual(data['current_status']['wait_time'], '5-10 min')
        self.assertIsNotNone(data['current_status']['last_updated'])

        # Check average rating
        self.assertEqual(data['average_rating'], 4.0)

    def test_bar_deserialization(self):
        """Test deserializing bar data"""
        data = {
            'name': 'New Bar',
            'address': '456 New Street',
            'average_price': '$$$',
            'location': {'latitude': 3.0, 'longitude': 4.0},
            'users_at_bar': [self.user1.id, self.user2.id]
        }

        serializer = BarSerializer(data=data)
        self.assertTrue(serializer.is_valid())

        bar = serializer.save()

        # Check basic fields
        self.assertEqual(bar.name, 'New Bar')
        self.assertEqual(bar.address, '456 New Street')
        self.assertEqual(bar.average_price, '$$$')

        # Check location
        self.assertEqual(bar.location.y, 3.0)  # latitude
        self.assertEqual(bar.location.x, 4.0)  # longitude

        # Check users at bar
        self.assertEqual(bar.users_at_bar.count(), 2)
        self.assertIn(self.user1, bar.users_at_bar.all())
        self.assertIn(self.user2, bar.users_at_bar.all())

    def test_bar_update(self):
        """Test updating a bar"""
        data = {
            'name': 'Updated Bar',
            'address': '789 Updated Street',
            'average_price': '$$$$',
            'location': {'latitude': 5.0, 'longitude': 6.0},
            'users_at_bar': [self.user2.id]  # Only user2 now
        }

        serializer = BarSerializer(self.bar, data=data)
        self.assertTrue(serializer.is_valid())

        updated_bar = serializer.save()

        # Check basic fields
        self.assertEqual(updated_bar.name, 'Updated Bar')
        self.assertEqual(updated_bar.address, '789 Updated Street')
        self.assertEqual(updated_bar.average_price, '$$$$')

        # Check location
        self.assertEqual(updated_bar.location.y, 5.0)  # latitude
        self.assertEqual(updated_bar.location.x, 6.0)  # longitude

        # Check users at bar (should be replaced, not appended)
        self.assertEqual(updated_bar.users_at_bar.count(), 1)
        self.assertIn(self.user2, updated_bar.users_at_bar.all())
        self.assertNotIn(self.user1, updated_bar.users_at_bar.all())

    def test_invalid_location_data(self):
        """Test validation for invalid location data"""
        data = {
            'name': 'Invalid Bar',
            'address': '123 Test Street',
            'average_price': '$$',
            'location': {'latitude': 'not-a-number', 'longitude': 1.0}
        }

        serializer = BarSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn('location', serializer.errors)

        # Test with missing coordinates
        data['location'] = {'latitude': None, 'longitude': 1.0}
        serializer = BarSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn('location', serializer.errors)

    def test_bar_with_no_status(self):
        """Test serializing a bar with no status updates"""
        # Create a new bar with no status
        bar_no_status = Bar.objects.create(
            name='No Status Bar',
            address='123 Empty Street',
            average_price='$',
            location=Point(7.0, 8.0, srid=4326)
        )

        serializer = BarSerializer(bar_no_status)
        data = serializer.data

        # Check that current_status values are None
        self.assertEqual(data['current_status']['crowd_size'], None)
        self.assertEqual(data['current_status']['wait_time'], None)
        self.assertEqual(data['current_status']['last_updated'], None)

        # Check that average_rating is None
        self.assertIsNone(data['average_rating'])


class BarStatusSerializerTests(TestCase):
    def setUp(self):
        # Create a test bar
        self.bar = Bar.objects.create(
            name='Test Bar',
            address='123 Test Street',
            average_price='$$',
            location=Point(1.0, 2.0, srid=4326)
        )

        # Create a bar status
        self.status = BarStatus.objects.create(
            bar=self.bar,
            crowd_size='busy',
            wait_time='10-20 min'
        )

    def test_status_serialization(self):
        """Test serializing a bar status"""
        serializer = BarStatusSerializer(self.status)
        data = serializer.data

        self.assertEqual(data['bar'], self.bar.id)
        self.assertEqual(data['crowd_size'], 'busy')
        self.assertEqual(data['wait_time'], '10-20 min')
        self.assertIsNotNone(data['last_updated'])
        self.assertEqual(data['id'], self.status.id)

    def test_status_deserialization(self):
        """Test deserializing bar status data"""
        data = {
            'bar': self.bar.id,
            'crowd_size': 'crowded',
            'wait_time': '20-30 min'
        }

        serializer = BarStatusSerializer(data=data)
        self.assertTrue(serializer.is_valid())

        status = serializer.save()

        self.assertEqual(status.bar, self.bar)
        self.assertEqual(status.crowd_size, 'crowded')
        self.assertEqual(status.wait_time, '20-30 min')
        self.assertIsNotNone(status.last_updated)

    def test_status_update(self):
        """Test updating a bar status"""
        data = {
            'bar': self.bar.id,
            'crowd_size': 'packed',
            'wait_time': '>30 min'
        }

        serializer = BarStatusSerializer(self.status, data=data)
        self.assertTrue(serializer.is_valid())

        updated_status = serializer.save()

        self.assertEqual(updated_status.bar, self.bar)
        self.assertEqual(updated_status.crowd_size, 'packed')
        self.assertEqual(updated_status.wait_time, '>30 min')