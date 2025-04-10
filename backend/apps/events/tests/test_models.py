from django.test import TestCase
from django.core.exceptions import ValidationError
from django.contrib.gis.geos import Point
from apps.bars.models import Bar
from apps.users.models import User
from apps.events.models import Event, EventAttendee
from django.utils import timezone
from datetime import timedelta, datetime


# Must delete the music_genre field from the bar model
# because it is not used in the test 
class EventModelTests(TestCase):
    def setUp(self):
        # Create a test bar
        self.bar = Bar.objects.create(
            name='Test Bar',
            address='123 Test Street',
            # music_genre='rock',
            average_price='$$',
            location=Point(1.0, 2.0, srid=4326)
        )

        # Create a test event
        self.event = Event.objects.create(
            bar='Test Bar',
            event_name='Free Drinks',
            event_time=timezone.now() + timedelta(hours=5),
            event_description='Free Drinks if you buy...',
            created_at=timezone.make_aware(datetime(2025, 2, 5, 12, 0, 0))
        )

    def test_create_valid_event(self):
        """Test creating a valid event"""
        self.assertEqual(self.event.bar, 'Test Bar')
        self.assertEqual(self.event.event_name, 'Free Drinks')
        self.assertEqual(self.event.event_description, 'Free Drinks if you buy...')
        self.assertEqual(self.event.created_at, timezone.make_aware(datetime(2025, 2, 5, 12, 0, 0))) 
        self.assertTrue(self.event.event_time > timezone.now())

    def test_empty_event_name_validation(self):
        """Test validation for empty event name"""
        event = Event(
            bar='Test Bar',
            event_name='',
            event_time=timezone.now() + timedelta(hours=5),
            event_description='Free Drinks if you buy...',
            created_at=timezone.make_aware(datetime(2025, 2, 5, 12, 0, 0))
        )
        with self.assertRaises(ValidationError) as context:
            event.clean()

        self.assertIn("Event name cannot be empty.", str(context.exception))

        # Test whitespace-only name
        event.name = '   '
        with self.assertRaises(ValidationError) as context:
            event.clean()

        self.assertIn("Event name cannot be empty.", str(context.exception))
    
    def test_event_time_validation(self):
        """Test validation for valid event start time (can't have past time)"""
        self.event.event_time = timezone.now() - timedelta(days=1)
        with self.assertRaises(ValidationError):
            self.event.clean()
    
    def test_duplicate_event(self):
        """Test that an event with same time and name cannot be created at same bar."""
        with self.assertRaises(ValidationError):
            duplicate_event = Event(bar=self.bar, event_name=self.event.event_name, event_time=self.event.event_time)
            duplicate_event.clean()

    def test_string_representation(self):
        """Test string representation of Events model"""
        self.assertEqual(str(self.event), 'Free Drinks at Test Bar')

class EventAttendeeModelTests(TestCase):
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
            # music_genre='rock',
            average_price='$$',
            location=Point(1.0, 2.0, srid=4326)
        )

        # Create a test event
        self.event = Event.objects.create(
            bar='Test Bar',
            event_name='Free Drinks',
            event_time=timezone.now() + timedelta(hours=5),
            event_description='Free Drinks if you buy...',
            created_at=timezone.make_aware(datetime(2025, 2, 5, 12, 0, 0))
        )

    def test_add_attendee_to_event(self):
        """Test that users can register for an event"""
        attendee = EventAttendee.objects.create(event=self.event, user=self.user)
        
        self.assertEqual(attendee.event, self.event)
        self.assertEqual(attendee.user, self.user)
        self.assertEqual(self.event.attendee_list.count(), 1)
        self.assertIn(self.user, self.event.attendees.all())

    def test_duplicate_attendee(self):
        """Test that a user cannot register for the same event twice."""
        EventAttendee.objects.create(event=self.event, user=self.user)

        with self.assertRaises(ValidationError):
            duplicate_attendee = EventAttendee(event=self.event, user=self.user)
            duplicate_attendee.clean()

    def test_strings_methods(self):
        """Test string representation of Event Attendees model"""
        attendee = EventAttendee.objects.create(event=self.event, user=self.user)
        
        self.assertEqual(str(self.event), 'Free Drinks at Test Bar')
        self.assertEqual(str(attendee), 'testuser attending Free Drinks')
