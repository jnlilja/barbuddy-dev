from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.gis.geos import Point
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import RefreshToken
from apps.matches.models import Match

User = get_user_model()

def get_auth_header_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {"HTTP_AUTHORIZATION": f"Bearer {str(refresh.access_token)}"}

class UserViewSetTests(APITestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(
            username="user1",
            email="user1@example.com",
            password="password123",
            location=Point(1.0, 2.0, srid=4326),
            sexual_preference="gay"
        )
        self.user2 = User.objects.create_user(
            username="user2",
            email="user2@example.com",
            password="password123",
            location=Point(3.0, 4.0, srid=4326),
            sexual_preference="straight"
        )

        self.match = Match.objects.create(user1=self.user1, user2=self.user2, status="connected")

        self.auth_headers_user1 = get_auth_header_for_user(self.user1)

    def test_get_user_location(self):
        response = self.client.get("/api/users/location/", **self.auth_headers_user1)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data, {"latitude": 2.0, "longitude": 1.0})

    def test_get_user_location_not_set(self):
        self.user1.location = None
        self.user1.save()
        response = self.client.get("/api/users/location/", **self.auth_headers_user1)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data, {"error": "Location not set."})

    def test_update_user_location(self):
        data = {"latitude": 5.0, "longitude": 6.0}
        response = self.client.post("/api/users/update_location/", data, **self.auth_headers_user1)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data, {"status": "Location updated successfully."})
        self.user1.refresh_from_db()
        self.assertEqual(self.user1.location.x, 6.0)
        self.assertEqual(self.user1.location.y, 5.0)

    def test_update_user_location_invalid(self):
        data = {"latitude": 5.0}  # Missing longitude
        response = self.client.post("/api/users/update_location/", data, **self.auth_headers_user1)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("longitude", response.data)

    def test_get_user_matches(self):
        response = self.client.get(f"/api/users/{self.user1.id}/matches/", **self.auth_headers_user1)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["id"], self.match.id)

    def test_get_user_matches_no_matches(self):
        user3 = User.objects.create_user(
            username="user3",
            email="user3@example.com",
            password="password123",
            sexual_preference="other"
        )
        response = self.client.get(
            f"/api/users/{user3.id}/matches/",
            **get_auth_header_for_user(user3)
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)

    def test_get_queryset_for_superuser(self):
        self.user1.is_superuser = True
        self.user1.save()
        response = self.client.get("/api/users/", **self.auth_headers_user1)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)

    def test_get_queryset_for_regular_user(self):
        response = self.client.get("/api/users/", **self.auth_headers_user1)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["username"], self.user1.username)
        self.assertEqual(response.data[0]["sexual_preference"], self.user1.sexual_preference)
