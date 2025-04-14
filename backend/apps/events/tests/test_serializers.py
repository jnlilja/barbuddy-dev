from django.test import TestCase
from django.utils.timezone import now, timedelta
from apps.events.models import Event
from apps.bars.models import Bar
from apps.users.models import User
from apps.events.serializers import EventSerializer
from django.contrib.gis.geos import Point

class EventSerializerTests(TestCase):
    def setUp(self):
        # Create a test user
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )

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

    def test_serialize_event(self):
        """Test serializing a valid event."""
        serializer = EventSerializer(instance=self.event)
        data = serializer.data
        self.assertEqual(data["event_name"], self.event.event_name)
        self.assertEqual(data["bar"], self.bar.id)
        self.assertEqual(data["event_description"], self.event.event_description)

    def test_deserialize_valid_event(self):
        """Test deserializing and validating a valid event."""
        data = {
            "bar": self.bar.id,
            "event_name": "New Event",
            "event_time": (now() + timedelta(days=1)).isoformat(),
            "event_description": "This is a new event."
        }
        serializer = EventSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        event = serializer.save()
        self.assertEqual(event.event_name, "New Event")
        self.assertEqual(event.bar, self.bar)

    def test_event_time_in_past_validation(self):
        """Test validation for an event time in the past."""
        data = {
            "bar": self.bar.id,
            "event_name": "Past Event",
            "event_time": (now() - timedelta(days=1)).isoformat(),
            "event_description": "This is a past event."
        }
        serializer = EventSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("event_time", serializer.errors)
        self.assertEqual(
            serializer.errors["event_time"][0],
            "Event time cannot be in the past."
        )

    def test_to_representation(self):
        """Test the to_representation method to include bar_name."""
        serializer = EventSerializer(instance=self.event)
        data = serializer.data
        self.assertIn("bar_name", data)
        self.assertEqual(data["bar_name"], self.bar.name)


