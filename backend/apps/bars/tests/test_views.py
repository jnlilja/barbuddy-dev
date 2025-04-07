
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
from apps.bars.models import Bar, BarStatus

User = get_user_model()

class BarViewSetTestCase(APITestCase):
    def setUp(self):
        """Set up test data."""
        self.user = User.objects.create_user(username="testuser", password="password123")
        self.bar = Bar.objects.create(
            name="Test Bar",
            address="123 Main St",
            music_genre="Rock",
            average_price=10.50,
            location=Point(1.0, 2.0, srid=4326) 
        )
        self.bar_status = BarStatus.objects.create(bar=self.bar, status="Open")

        self.client.force_authenticate(user=self.user)  # Authenticate user for requests

        self.list_url = reverse('bar-list')  # Adjust based on URL configuration
        self.detail_url = reverse('bar-detail', kwargs={'pk': self.bar.id})

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
            "music_genre": "Jazz",
            "average_price": 15.00
        }
        response = self.client.post(self.list_url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Bar.objects.count(), 2)

    def test_update_bar(self):
        """Test updating a bar's information."""
        data = {
            "name": "Updated Test Bar",
            "address": self.bar.address,
            "music_genre": "Pop",
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
        response = self.client.get(self.list_url, {"music_genre": "Rock"})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("Test Bar", str(response.data))

    def test_retrieve_bar_status(self):
        """Test getting the latest status of a bar."""
        response = self.client.get(self.detail_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data.get('current_status'), self.bar_status.status)


class BarStatusViewSetTestCase(APITestCase):
    def setUp(self):
        """Set up test data."""
        self.user = User.objects.create_user(username="testuser", password="password123")
        self.bar = Bar.objects.create(
            name="Test Bar",
            address="123 Main St",
            music_genre="Rock",
            average_price=10.50,
            location=Point(1.0, 2.0, srid=4326) 
        )
        self.bar_status = BarStatus.objects.create(bar=self.bar, status="Open")

        self.client.force_authenticate(user=self.user)  # Authenticate user for API requests

        self.list_url = reverse('barstatus-list')  # Update with actual route name
        self.detail_url = reverse('barstatus-detail', kwargs={'pk': self.bar_status.id})

    def test_list_bar_statuses(self):
        """Test retrieving a list of bar statuses."""
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("Open", str(response.data))

    def test_retrieve_bar_status(self):
        """Test retrieving a single bar status."""
        response = self.client.get(self.detail_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], self.bar_status.status)

    def test_create_bar_status(self):
        """Test creating a new bar status."""
        data = {
            "bar": self.bar.id,
            "status": "Closed"
        }
        response = self.client.post(self.list_url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(BarStatus.objects.count(), 2)

    def test_update_bar_status(self):
        """Test updating a bar status."""
        data = {
            "bar": self.bar.id,
            "status": "Busy"
        }
        response = self.client.put(self.detail_url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.bar_status.refresh_from_db()
        self.assertEqual(self.bar_status.status, "Busy")

    def test_delete_bar_status(self):
        """Test deleting a bar status."""
        response = self.client.delete(self.detail_url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(BarStatus.objects.filter(id=self.bar_status.id).exists())