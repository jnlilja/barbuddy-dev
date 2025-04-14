from django.test import TestCase
from django.core.exceptions import ValidationError
from django.utils.timezone import now, timedelta
from apps.events.models import Event
from apps.bars.models import Bar
from apps.users.models import User
from django.contrib.gis.geos import Point

class EventModelTests(TestCase):
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

    def test_create_valid_event(self):
        """Test creating a valid event."""
        event = Event.objects.create(
            bar=self.bar,
            event_name='Test Event',
            event_time=now() + timedelta(days=1),  # Future time
            event_description='This is a test event.'
        )
        self.assertEqual(event.event_name, 'Test Event')
        self.assertEqual(event.bar, self.bar)
        self.assertGreater(event.event_time, now())

    def test_empty_event_name_validation(self):
        """Test validation for an empty event name."""
        event = Event(
            bar=self.bar,
            event_name='',
            event_time=now() + timedelta(days=1),
            event_description='This is a test event.'
        )
        with self.assertRaises(ValidationError):
            event.clean()

    def test_event_time_in_past_validation(self):
        """Test validation for an event time in the past."""
        event = Event(
            bar=self.bar,
            event_name='Past Event',
            event_time=now() - timedelta(days=1),  # Past time
            event_description='This is a test event.'
        )
        with self.assertRaises(ValidationError):
            event.clean()

    def test_event_str_method(self):
        """Test the __str__ method of the Event model."""
        event = Event.objects.create(
            bar=self.bar,
            event_name='Test Event',
            event_time=now() + timedelta(days=1),
            event_description='This is a test event.'
        )
        self.assertEqual(str(event), f"Test Event at {self.bar.name}")