from rest_framework.test import APITestCase, APIClient
from django.urls import reverse
from apps.bars.models import Bar, BarVote
from apps.users.models import User
from django.contrib.gis.geos import Point


class BarVoteViewSetTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(username="voter", password="password123")
        self.bar = Bar.objects.create(
            name="Test Bar",
            address="123 Main St",
            average_price="$",
            location=Point(-122.4194, 37.7749, srid=4326)
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)

    def test_create_vote(self):
        url = reverse('barvote-list')
        data = {
            "bar": self.bar.id,
            "crowd_size": "moderate",
            "wait_time": "10-20 min"
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, 201)
        self.assertEqual(BarVote.objects.count(), 1)

    def test_prevent_duplicate_vote(self):
        BarVote.objects.create(bar=self.bar, user=self.user, crowd_size="low", wait_time="5-10 min")
        data = {
            "bar": self.bar.id,
            "crowd_size": "moderate",
            "wait_time": "10-20 min"
        }
        url = reverse('barvote-list')
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, 400)  # Should raise IntegrityError / validation

    def test_list_votes(self):
        BarVote.objects.create(bar=self.bar, user=self.user, crowd_size="busy", wait_time=">30 min")
        url = reverse('barvote-list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 1)

    def test_delete_vote(self):
        vote = BarVote.objects.create(bar=self.bar, user=self.user, crowd_size="low", wait_time="5-10 min")
        url = reverse('barvote-detail', args=[vote.id])
        response = self.client.delete(url)
        self.assertEqual(response.status_code, 204)
        self.assertEqual(BarVote.objects.count(), 0)
