from django.test import TestCase
from django.utils.timezone import now, timedelta
from apps.events.models import Event, EventAttendee
from apps.bars.models import Bar
from apps.users.models import User
from django.contrib.gis.geos import Point
from django.contrib.auth import get_user_model
from apps.events.serializers import EventSerializer, EventAttendeeSerializer

User = get_user_model()

class EventSerializerTestCase(TestCase):
    def setUp(self):
        # Creates a test bar
        self.bar = Bar.objects.create(
            name='Test Bar', 
            address='123 Test St',
            music_genre='pop',
            average_price='$$$$',
            location=Point(1.0, 2.0, srid=4326))

        # Creates a test user
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123')

        # Creates a test event
        self.event = Event.objects.create(
            bar=self.bar,
            event_name="Test Event",
            event_time=now() + timedelta(days=1),
            event_description="A fun event"
        )

    def test_valid_event_serialization(self):
        serializer = EventSerializer(instance=self.event)
        data = serializer.data

        # Check basic fields
        self.assertEqual(data["event_name"], self.event.event_name)
        self.assertEqual(data["bar_name"], self.bar.name)
        self.assertEqual(data["attendee_count"], 0)

    def test_event_time_validation(self):
        past_time = now() - timedelta(days=1)
        invalid_event = Event(
            bar=self.bar,
            event_name="Past Event",
            event_time=past_time
        )
        serializer = EventSerializer(data={
            "bar": self.bar.id,
            "event_name": "Past Event",
            "event_time": past_time
        })
        self.assertFalse(serializer.is_valid())
        self.assertIn("event_time", serializer.errors)


class EventAttendeeSerializerTestCase(TestCase):
    def setUp(self):
        self.bar = Bar.objects.create(name="Test Bar", address="123 Test St")
        self.user = User.objects.create_user(username="testuser", password="password")
        self.event = Event.objects.create(
            bar=self.bar,
            event_name="Test Event",
            event_time=now() + timedelta(days=1)
        )
        self.event_attendee = EventAttendee.objects.create(event=self.event, user=self.user)

    def test_valid_event_attendee_serialization(self):
        serializer = EventAttendeeSerializer(instance=self.event_attendee)
        data = serializer.data
        self.assertEqual(data["event"], self.event.id)
        self.assertEqual(data["user"], self.user.id)
        self.assertEqual(data["event_name"], self.event.event_name)
        self.assertEqual(data["user_name"], self.user.username)