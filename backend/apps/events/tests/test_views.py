from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from django.utils.timezone import now, timedelta
from apps.events.models import Event
from apps.bars.models import Bar
from apps.users.models import User
from django.contrib.gis.geos import Point

class EventViewTests(APITestCase):
    def setUp(self):
        # Create a test user
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )

        # Authenticate the user
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)

        # Create a test bar
        self.bar = Bar.objects.create(
            name='Test Bar',
            address='123 Test Street',
            average_price='$$',
            location=Point(1.0, 2.0, srid=4326)
        )

        # Create a test event
        self.event = Event.objects.create(
            bar=self.bar,
            event_name='Test Event',
            event_time=now() + timedelta(days=1),
            event_description='This is a test event.'
        )

    def test_list_events(self):
        """Test retrieving a list of events."""
        response = self.client.get('/api/events/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['event_name'], self.event.event_name)

    def test_retrieve_event(self):
        """Test retrieving a single event."""
        response = self.client.get(f'/api/events/{self.event.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['event_name'], self.event.event_name)
        self.assertEqual(response.data['bar'], self.bar.id)

    def test_create_event(self):
        """Test creating a new event."""
        data = {
            "bar": self.bar.id,
            "event_name": "New Event",
            "event_time": (now() + timedelta(days=1)).isoformat(),
            "event_description": "This is a new event."
        }
        response = self.client.post('/api/events/', data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['event_name'], "New Event")
        self.assertEqual(response.data['bar'], self.bar.id)

    def test_create_event_with_past_time(self):
        """Test creating an event with a time in the past."""
        data = {
            "bar": self.bar.id,
            "event_name": "Past Event",
            "event_time": (now() - timedelta(days=1)).isoformat(),
            "event_description": "This is a past event."
        }
        response = self.client.post('/api/events/', data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("event_time", response.data)

    def test_update_event(self):
        """Test updating an existing event."""
        data = {
            "bar": self.bar.id,  # Include the bar ID
            "event_name": "Updated Event",
            "event_time": (now() + timedelta(days=2)).isoformat(),  # Future time
            "event_description": "This is an updated event."
        }
        response = self.client.put(f'/api/events/{self.event.id}/', data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['event_name'], "Updated Event")

    def test_delete_event(self):
        """Test deleting an event."""
        response = self.client.delete(f'/api/events/{self.event.id}/')
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Event.objects.filter(id=self.event.id).exists())