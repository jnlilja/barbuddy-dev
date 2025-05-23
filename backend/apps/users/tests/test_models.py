from django.test import TestCase
from django.core.exceptions import ValidationError
from django.contrib.auth import get_user_model
from django.contrib.gis.geos import Point
from datetime import date

User = get_user_model()

class UserModelTest(TestCase):
    def setUp(self):
        self.valid_user_data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'securepassword123',
            'first_name': 'Test',
            'last_name': 'User',
            'date_of_birth': date(1999, 1, 15),  # 25 years old
            'hometown': 'Test City',
            'job_or_university': 'Test Company',
            'favorite_drink': 'Water',
            'location': Point(0, 0, srid=4326),
            'profile_pictures': ['pic1.jpg', 'pic2.jpg'],
            'account_type': 'trusted',
            'sexual_preference': 'bisexual'
        }

    def test_create_user_with_valid_data(self):
        """Test creating a user with valid data."""
        user = User.objects.create_user(**self.valid_user_data)
        self.assertEqual(user.username, 'testuser')
        self.assertEqual(user.email, 'test@example.com')
        self.assertEqual(user.first_name, 'Test')
        self.assertEqual(user.last_name, 'User')
        self.assertEqual(user.hometown, 'Test City')
        self.assertEqual(user.job_or_university, 'Test Company')
        self.assertEqual(user.favorite_drink, 'Water')
        self.assertEqual(user.location, Point(0, 0, srid=4326))
        self.assertEqual(user.profile_pictures, ['pic1.jpg', 'pic2.jpg'])
        self.assertEqual(user.account_type, 'trusted')
        self.assertEqual(user.vote_weight, 2)  # Based on account type
        self.assertEqual(user.sexual_preference, 'bisexual')

    def test_user_get_age(self):
        """Test the get_age method."""
        user = User.objects.create_user(**self.valid_user_data)
        expected_age = date.today().year - 1999 - ((date.today().month, date.today().day) < (1, 15))
        self.assertEqual(user.get_age(), expected_age)

        # If date_of_birth is None, get_age should return None
        user.date_of_birth = None
        user.save()
        self.assertIsNone(user.get_age())

    def test_user_age_validation_too_young(self):
        """Test validation for users under the minimum age."""
        data = self.valid_user_data.copy()
        data['date_of_birth'] = date.today().replace(year=date.today().year - 17)

        user = User(**data)
        with self.assertRaises(ValidationError):
            user.clean()

    def test_user_age_validation_too_old(self):
        """Test validation for users over the maximum age."""
        data = self.valid_user_data.copy()
        data['date_of_birth'] = date.today().replace(year=date.today().year - 121)

        user = User(**data)
        with self.assertRaises(ValidationError):
            user.clean()

    def test_user_phone_number_unique(self):
        """Test that phone numbers must be unique."""
        user1 = User.objects.create_user(**self.valid_user_data)
        user1.phone_number = '1234567890'
        user1.save()

        data = self.valid_user_data.copy()
        data['username'] = 'testuser2'
        data['email'] = 'test2@example.com'
        user2 = User.objects.create_user(**data)

        user2.phone_number = '1234567890'
        with self.assertRaises(Exception):
            user2.save()

    def test_user_save_method_assigns_vote_weight(self):
        """Test that the save method assigns vote weight based on account type."""
        user = User.objects.create_user(**self.valid_user_data)
        self.assertEqual(user.vote_weight, 2)  # 'trusted' account type

        user.account_type = 'moderator'
        user.save()
        self.assertEqual(user.vote_weight, 3)

        user.account_type = 'admin'
        user.save()
        self.assertEqual(user.vote_weight, 5)

    def test_user_location_is_point_field(self):
        """Test that the location field is a PointField."""
        user = User.objects.create_user(**self.valid_user_data)
        self.assertIsInstance(user.location, Point)
        self.assertEqual(user.location.x, 0)
        self.assertEqual(user.location.y, 0)

    def test_user_profile_pictures_is_json_field(self):
        user = User.objects.create_user(**self.valid_user_data)
        self.assertIsInstance(user.profile_pictures, list)
        self.assertEqual(len(user.profile_pictures), 2)
        self.assertEqual(user.profile_pictures[0], 'pic1.jpg')

    def test_user_blank_fields(self):
        """Test creating a user with minimal required fields."""
        minimal_data = {
            'username': 'minimaluser',
            'email': 'minimal@example.com',
            'password': 'securepassword123',
            'date_of_birth': date(1999, 1, 15)
        }

        user = User.objects.create_user(**minimal_data)
        self.assertEqual(user.username, 'minimaluser')
        self.assertIsNone(user.phone_number)
        self.assertEqual(user.hometown, '')
        self.assertEqual(user.job_or_university, '')
        self.assertEqual(user.favorite_drink, '')
        self.assertIsNone(user.location)
        self.assertEqual(user.profile_pictures, [])
        self.assertEqual(user.vote_weight, 1)  # Default value
        self.assertEqual(user.account_type, 'regular')  # Default account type
        self.assertEqual(user.sexual_preference, None)  # Default is None
