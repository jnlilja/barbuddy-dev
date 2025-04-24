from django.contrib.gis.geos import Point
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from apps.bars.models import Bar, BarStatus
from apps.users.models import User

from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth import get_user_model
from django.urls import reverse
from django.utils import timezone
from django.contrib.gis.geos import Point
from apps.bars.models import Bar, BarStatus, BarVote


User = get_user_model()

class BarViewSetTestCase(APITestCase):
    def setUp(self):
        """Set up test data."""
        self.user = User.objects.create_user(username="testuser", password="password123")
        self.bar = Bar.objects.create(
            name="Test Bar",
            address="123 Main St",
            average_price=10.50,
            location=Point(1.0, 2.0, srid=4326) 
        )

        self.bar_status = BarStatus.objects.create(
            bar=self.bar,
            crowd_size="moderate",
            wait_time="5-10 min"
        )

        self.client.force_authenticate(user=self.user)  # Authenticate user for requests

        self.list_url = reverse('bars-list')  # Adjust based on URL configuration
        self.detail_url = reverse('bars-detail', kwargs={'pk': self.bar.id})

    def test_list_bars(self):
        """Test retrieving a list of bars."""
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('Test Bar', str(response.data))

    def test_retrieve_bar(self):
        """Test retrieving a single bar."""
        response = self.client.get(self.detail_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['name'], self.bar.name)

    def test_create_bar(self):
        """Test creating a new bar."""
        data = {
            "name": "New Bar",
            "address": "456 Side St",
            "average_price": 15.00,
            "location": {"latitude": 1.0, "longitude": 2.0}  # Add location data
        }
        response = self.client.post(self.list_url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Bar.objects.count(), 2)

    def test_update_bar(self):
        """Test updating a bar's information."""
        data = {
            "name": "Updated Test Bar",
            "address": self.bar.address,
            # "music_genre": "Pop",
            "average_price": self.bar.average_price
        }
        response = self.client.put(self.detail_url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.bar.refresh_from_db()
        self.assertEqual(self.bar.name, "Updated Test Bar")

    def test_delete_bar(self):
        """Test deleting a bar."""
        response = self.client.delete(self.detail_url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Bar.objects.filter(id=self.bar.id).exists())

    def test_filter_bars(self):
        """Test filtering bars by user preferences (if applicable)."""
        # Assuming filters are applied in `get_queryset`
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("Test Bar", str(response.data))

    def test_retrieve_bar_status(self):
        """Test getting the latest status of a bar."""
        response = self.client.get(self.detail_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        # Extract the current_status field from the response
        current_status = response.data.get('current_status')

        # Assert that the current_status matches the expected values
        self.assertEqual(current_status['crowd_size'], self.bar_status.crowd_size)
        self.assertEqual(current_status['wait_time'], self.bar_status.wait_time)
        self.assertIn('last_updated', current_status)  # Ensure last_updated is present


class BarStatusViewSetTestCase(APITestCase):
    def setUp(self):
        """Set up test data."""
        self.user = User.objects.create_user(username="testuser", password="password123")
        self.bar = Bar.objects.create(
            name="Test Bar",
            address="123 Main St",
            average_price=10.50,
            location=Point(1.0, 2.0, srid=4326)
        )
        self.bar_status = BarStatus.objects.create(
            bar=self.bar,
            crowd_size="moderate",
            wait_time="5-10 min"
        )
        self.client.force_authenticate(user=self.user)

        self.list_url = reverse('bar-status-list')  # Matches the basename in urls.py
        self.detail_url = reverse('bar-status-detail', kwargs={'pk': self.bar_status.id})

    def test_list_bar_statuses(self):
        """Test retrieving a list of bar statuses."""
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        #self.assertIn("Open", str(response.data)) BROOO 
        self.assertIn("moderate", str(response.data))
        self.assertIn("5-10 min", str(response.data))

    def test_retrieve_bar_status(self):
        """Test retrieving a single bar status."""
        response = self.client.get(self.detail_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['crowd_size'], self.bar_status.crowd_size)  # Use the correct field

    def test_create_bar_status(self):
        """Test creating a new bar status."""
        data = {
            "bar": self.bar.id,
            #"status": "Closed" bro im hunting these down 
            "crowd_size": "busy",
            "wait_time": "10-20 min"
        }
        response = self.client.post(self.list_url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(BarStatus.objects.count(), 2)

    def test_update_bar_status(self):
        """Test updating a bar status."""
        data = {
            "bar": self.bar.id,
            #"status": "Busy" bro im finna loose it this is NOT a field that the bars have 
            "crowd_size": "crowded",
            "wait_time": ">30 min"
        }
        response = self.client.put(self.detail_url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.bar_status.refresh_from_db()
        self.assertEqual(self.bar_status.crowd_size, "crowded")
        self.assertEqual(self.bar_status.wait_time, ">30 min")

    def test_delete_bar_status(self):
        """Test deleting a bar status."""
        response = self.client.delete(self.detail_url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(BarStatus.objects.filter(id=self.bar_status.id).exists())

class AggregatedVoteViewTest(APITestCase):
    def setUp(self):
        # Create users with different weights
        self.user1 = User.objects.create_user(username="user1", password="test123", account_type='regular')  # vote_weight = 1
        self.user2 = User.objects.create_user(username="user2", password="test123", account_type='trusted')  # vote_weight = 2
        self.user3 = User.objects.create_user(username="user3", password="test123", account_type='moderator')  # vote_weight = 3

        self.bar = Bar.objects.create(
            name="The Spot",
            address="123 Chill Ave",
            average_price="$",
            location=Point(-117.0, 32.0, srid=4326)
        )

        # Add votes
        BarVote.objects.create(bar=self.bar, user=self.user1, crowd_size='moderate', wait_time='10-20 min')
        BarVote.objects.create(bar=self.bar, user=self.user2, crowd_size='moderate', wait_time='5-10 min')
        BarVote.objects.create(bar=self.bar, user=self.user3, crowd_size='crowded', wait_time='10-20 min')

        self.client.force_authenticate(user=self.user1)

    def test_aggregated_vote_results(self):
        url = reverse('bars-aggregated-vote', kwargs={'pk': self.bar.id})
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        # The weighted votes should make:
        # - 'crowded' (3 points) win over 'moderate' (1 + 2 = 3) because it's a tie and max() returns first
        # - '10-20 min' (1 + 3 = 4) beat '5-10 min' (2)

        self.assertIn('crowd_size', response.data)
        self.assertIn('wait_time', response.data)
        self.assertEqual(response.data['crowd_size'], 'crowded')
        self.assertEqual(response.data['wait_time'], '10-20 min')

class BarActivityTests(APITestCase):
    def setUp(self):
        self.bar1 = Bar.objects.create(
            name="Busy Bar",
            address="123 Party St",
            average_price="$$",
            location=Point(-117.0, 32.0, srid=4326)
        )
        
        self.bar2 = Bar.objects.create(
            name="Quiet Bar",
            address="456 Chill St",
            average_price="$$",
            location=Point(-117.1, 32.1, srid=4326)
        )
        
        # Create and add users to bar1
        for i in range(5):
            user = User.objects.create_user(
                username=f"user{i}",
                password="testpass123"
            )
            self.bar1.users_at_bar.add(user)

    def test_most_active_bars_endpoint(self):
        url = reverse('bar-most-active')
        response = self.response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)
        self.assertEqual(response.data[0]['name'], "Busy Bar")
        self.assertEqual(response.data[0]['user_count'], 5)