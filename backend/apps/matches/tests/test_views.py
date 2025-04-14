from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from django.contrib.auth import get_user_model
from apps.matches.models import Match

User = get_user_model()

class MatchViewSetTests(APITestCase):
    def setUp(self):
        # Create users
        self.user1 = User.objects.create_user(username="user1", password="password123")
        self.user2 = User.objects.create_user(username="user2", password="password123")
        self.user3 = User.objects.create_user(username="user3", password="password123")
        self.user4 = User.objects.create_user(username="user4", password="password123")  # ✅ New

        # Auth user1
        self.client.force_authenticate(user=self.user1)

        # Create some matches
        self.match1 = Match.objects.create(user1=self.user1, user2=self.user2, status="connected")
        self.match2 = Match.objects.create(user1=self.user1, user2=self.user3, status="pending")
        self.match3 = Match.objects.create(user1=self.user2, user2=self.user3, status="connected")

    def test_get_matches_list_only_user_matches(self):
        url = reverse('matches-list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        match_ids = [match["id"] for match in response.data]
        self.assertIn(self.match1.id, match_ids)
        self.assertIn(self.match2.id, match_ids)
        self.assertNotIn(self.match3.id, match_ids)

    def test_get_mutual_matches(self):
        url = reverse('matches-mutual')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        match_ids = [match["id"] for match in response.data]
        self.assertIn(self.match1.id, match_ids)
        self.assertNotIn(self.match2.id, match_ids)
        self.assertNotIn(self.match3.id, match_ids)

    def test_create_match(self):
        url = reverse('matches-list')
        data = {
            "user1": self.user1.id,
            "user2": self.user4.id,  # ✅ use user4 who is not already matched
            "status": "pending"
        }
        response = self.client.post(url, data)
        print("RESPONSE DATA:", response.data)  # Optional: helpful if it fails again
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        created = Match.objects.get(id=response.data["id"])
        self.assertEqual(created.user1, self.user1)
        self.assertEqual(created.user2, self.user4)
        self.assertEqual(created.status, "pending")

    def test_unauthenticated_access_denied(self):
        self.client.force_authenticate(user=None)
        url = reverse('matches-list')
        response = self.client.get(url)
        self.assertIn(response.status_code, [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN])
