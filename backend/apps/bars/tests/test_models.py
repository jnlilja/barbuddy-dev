from django.test import TestCase
from django.core.exceptions import ValidationError
from django.contrib.gis.geos import Point
from apps.bars.models import Bar, BarStatus, BarRating
from apps.users.models import User

#python manage.py test bars.tests.test_models
class BarModelTests(TestCase):
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
            #music_genre='rock',
            average_price='$$',
            location=Point(1.0, 2.0, srid=4326)  # longitude, latitude
        )

    def test_create_valid_bar(self):
        """Test creating a valid bar"""
        self.assertEqual(self.bar.name, 'Test Bar')
        self.assertEqual(self.bar.address, '123 Test Street')
        #self.assertEqual(self.bar.music_genre, 'rock')
        self.assertEqual(self.bar.average_price, '$$')
        self.assertEqual(self.bar.location.x, 1.0)  # longitude
        self.assertEqual(self.bar.location.y, 2.0)  # latitude

    def test_empty_bar_name_validation(self):
        """Test validation for empty bar name"""
        bar = Bar(
            name='',
            address='123 Test Street',
            #music_genre='rock',
            average_price='$$',
            location=Point(1.0, 2.0, srid=4326)
        )
        with self.assertRaises(ValidationError):
            bar.clean()

        # Test whitespace-only name
        bar.name = '   '
        with self.assertRaises(ValidationError):
            bar.clean()

    def test_users_at_bar(self):
        """Test adding users to a bar"""
        self.bar.users_at_bar.add(self.user)
        self.assertEqual(self.bar.users_at_bar.count(), 1)
        self.assertEqual(self.bar.users_at_bar.first(), self.user)

        # Test user's reverse relationship
        self.assertEqual(self.user.bars_attended.count(), 1)
        self.assertEqual(self.user.bars_attended.first(), self.bar)

    def test_get_latest_status(self):
        """Test getting the latest status for a bar"""
        # Initially no status
        status = self.bar.get_latest_status()
        self.assertIsNone(status['crowd_size'])
        self.assertIsNone(status['wait_time'])
        self.assertIsNone(status['last_updated'])

        # Add a status
        bar_status = BarStatus.objects.create(
            bar=self.bar,
            crowd_size='moderate',
            wait_time='<5 min'
        )

        # Get updated status
        status = self.bar.get_latest_status()
        self.assertEqual(status['crowd_size'], 'moderate')
        self.assertEqual(status['wait_time'], '<5 min')
        self.assertIsNotNone(status['last_updated'])

    def test_string_representation(self):
        """Test string representation of Bar model"""
        self.assertEqual(str(self.bar), 'Test Bar')


class BarStatusModelTests(TestCase):
    def setUp(self):
        # Create a test bar
        self.bar = Bar.objects.create(
            name='Test Bar',
            address='123 Test Street',
            #music_genre='rock',
            average_price='$$',
            location=Point(1.0, 2.0, srid=4326)
        )

    def test_create_valid_status(self):
        """Test creating a valid bar status"""
        bar_status = BarStatus.objects.create(
            bar=self.bar,
            crowd_size='busy',
            wait_time='10-20 min'
        )

        self.assertEqual(bar_status.bar, self.bar)
        self.assertEqual(bar_status.crowd_size, 'busy')
        self.assertEqual(bar_status.wait_time, '10-20 min')
        self.assertIsNotNone(bar_status.last_updated)

    def test_missing_fields_validation(self):
        """Test validation for missing required fields"""
        # Test missing crowd_size
        bar_status = BarStatus(
            bar=self.bar,
            wait_time='5-10 min'
        )
        # Set crowd_size to empty string to trigger validation on save
        bar_status.crowd_size = ''
        with self.assertRaises(ValidationError):
            bar_status.clean()

        # Test missing wait_time
        bar_status = BarStatus(
            bar=self.bar,
            crowd_size='empty'
        )
        # Set wait_time to empty string to trigger validation on save
        bar_status.wait_time = ''
        with self.assertRaises(ValidationError):
            bar_status.clean()

    def test_string_representation(self):
        """Test string representation of BarStatus model"""
        bar_status = BarStatus.objects.create(
            bar=self.bar,
            crowd_size='low',
            wait_time='<5 min'
        )
        self.assertTrue(str(bar_status).startswith(f"{self.bar.name} Status -"))


class BarRatingModelTests(TestCase):
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
            #music_genre='rock',
            average_price='$$',
            location=Point(1.0, 2.0, srid=4326)
        )

    def test_create_valid_rating(self):
        """Test creating a valid bar rating"""
        rating = BarRating.objects.create(
            bar=self.bar,
            user=self.user,
            rating=4,
            review="Great place!"
        )

        self.assertEqual(rating.bar, self.bar)
        self.assertEqual(rating.user, self.user)
        self.assertEqual(rating.rating, 4)
        self.assertEqual(rating.review, "Great place!")
        self.assertIsNotNone(rating.timestamp)

    def test_rating_range_validation(self):
        """Test validation for rating range (1-5)"""
        # Test rating below range
        rating = BarRating(
            bar=self.bar,
            user=self.user,
            rating=0,
            review="Invalid rating"
        )
        with self.assertRaises(ValidationError):
            rating.clean()

        # Test rating above range
        rating.rating = 6
        with self.assertRaises(ValidationError):
            rating.clean()

        # Test valid ratings
        for valid_rating in range(1, 6):
            rating.rating = valid_rating
            rating.clean()  # Should not raise exception

    def test_unique_constraint(self):
        """Test that a user can only rate a bar once"""
        BarRating.objects.create(
            bar=self.bar,
            user=self.user,
            rating=4,
            review="First rating"
        )

        # Try to create another rating by the same user for the same bar
        with self.assertRaises(Exception):  # Could be IntegrityError but depends on database
            BarRating.objects.create(
                bar=self.bar,
                user=self.user,
                rating=5,
                review="Second rating"
            )

    def test_string_representation(self):
        """Test string representation of BarRating model"""
        rating = BarRating.objects.create(
            bar=self.bar,
            user=self.user,
            rating=3,
            review="It's okay"
        )
        expected_str = f"{self.user.username}'s rating for {self.bar.name}"
        self.assertEqual(str(rating), expected_str)
