from django.test import TestCase
from django.core.exceptions import ValidationError
from apps.swipes.models import Swipe
from apps.matches.models import Match
from apps.users.models import User

class SwipeModelTest(TestCase):
    def setUp(self):
        # Create test users
        self.user1 = User.objects.create_user(
            username="user1",
            email="user1@example.com",
            password="password123"
        )
        self.user2 = User.objects.create_user(
            username="user2",
            email="user2@example.com",
            password="password123"
        )
        self.user3 = User.objects.create_user(
            username="user3",
            email="user3@example.com",
            password="password123"
        )

    def test_create_valid_swipe(self):
        """Test creating a valid swipe."""
        swipe = Swipe.objects.create(swiper=self.user1, swiped_on=self.user2, status="like")
        self.assertEqual(swipe.swiper, self.user1)
        self.assertEqual(swipe.swiped_on, self.user2)
        self.assertEqual(swipe.status, "like")

    def test_swipe_on_self_raises_error(self):
        """Test that a user cannot swipe on themselves."""
        swipe = Swipe(swiper=self.user1, swiped_on=self.user1, status="like")
        with self.assertRaises(ValidationError) as context:
            swipe.clean()
        self.assertIn("You cannot swipe on yourself.", str(context.exception))

    def test_duplicate_swipe_raises_error(self):
        """Test that duplicate swipes are not allowed."""
        Swipe.objects.create(swiper=self.user1, swiped_on=self.user2, status="like")
        with self.assertRaises(ValidationError):
            duplicate_swipe = Swipe(swiper=self.user1, swiped_on=self.user2, status="dislike")
            duplicate_swipe.full_clean()  # Validate the model before saving
            duplicate_swipe.save()

    def test_like_creates_match(self):
        """Test that a mutual 'like' creates a match."""
        # User1 likes User2
        Swipe.objects.create(swiper=self.user1, swiped_on=self.user2, status="like")
        # User2 likes User1
        Swipe.objects.create(swiper=self.user2, swiped_on=self.user1, status="like")

        # Check that a match was created
        match = Match.objects.filter(user1=self.user1, user2=self.user2, status="connected").exists()
        self.assertTrue(match)

    def test_dislike_does_not_create_match(self):
        """Test that a 'dislike' does not create a match."""
        # User1 dislikes User2
        Swipe.objects.create(swiper=self.user1, swiped_on=self.user2, status="dislike")
        # User2 likes User1
        Swipe.objects.create(swiper=self.user2, swiped_on=self.user1, status="like")

        # Check that no match was created
        match = Match.objects.filter(user1=self.user1, user2=self.user2, status="connected").exists()
        self.assertFalse(match)

    def test_str_representation(self):
        """Test the string representation of the Swipe model."""
        swipe = Swipe.objects.create(swiper=self.user1, swiped_on=self.user2, status="like")
        self.assertEqual(str(swipe), f"{self.user1} swiped like on {self.user2}")

