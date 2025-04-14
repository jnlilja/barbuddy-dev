from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from django.urls import reverse
from apps.swipes.models import Swipe
from apps.users.models import User

class SwipeViewSetTests(APITestCase):
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

        # Authenticate user1
        self.client = APIClient()
        self.client.force_authenticate(user=self.user1)

        # Create a swipe
        self.swipe = Swipe.objects.create(swiper=self.user1, swiped_on=self.user2, status="like")

    def test_list_swipes(self):
        """Test listing swipes."""
        url = reverse("swipe-list")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["swiper_username"], self.user1.username)
        self.assertEqual(response.data[0]["swiped_on_username"], self.user2.username)

    def test_create_swipe(self):
        """Test creating a swipe."""
        url = reverse("swipe-list")
        data = {
            "swiped_on": self.user3.id,
            "status": "like"
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["swiper_username"], self.user1.username)
        self.assertEqual(response.data["swiped_on_username"], self.user3.username)
        self.assertEqual(response.data["status"], "like")

    def test_create_swipe_on_self(self):
        """Test creating a swipe on oneself."""
        url = reverse("swipe-list")
        data = {
            "swiped_on": self.user1.id,
            "status": "like"
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("non_field_errors", response.data)
        self.assertEqual(response.data["non_field_errors"][0], "You cannot swipe on yourself.")

    def test_retrieve_swipe(self):
        """Test retrieving a single swipe."""
        url = reverse("swipe-detail", args=[self.swipe.id])
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["swiper_username"], self.user1.username)
        self.assertEqual(response.data["swiped_on_username"], self.user2.username)

    def test_update_swipe(self):
        """Test updating a swipe."""
        url = reverse("swipe-detail", args=[self.swipe.id])
        data = {
            "swiped_on": self.user2.id,  # Include required field
            "status": "dislike"
        }
        response = self.client.patch(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.swipe.refresh_from_db()
        self.assertEqual(self.swipe.status, "dislike")

    def test_delete_swipe(self):
        """Test deleting a swipe."""
        url = reverse("swipe-detail", args=[self.swipe.id])
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Swipe.objects.filter(id=self.swipe.id).exists())

    def test_unauthenticated_access(self):
        """Test that unauthenticated users cannot access the endpoint."""
        self.client.logout()
        url = reverse("swipe-list")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

