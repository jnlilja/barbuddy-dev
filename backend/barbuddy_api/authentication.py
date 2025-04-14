# barbuddy_api/authentication.py

import firebase_admin
from firebase_admin import auth, credentials
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from django.contrib.auth import get_user_model

import os

# Only initialize once
if not firebase_admin._apps:
    cred = credentials.Certificate("firebase/service-account.json")
    firebase_admin.initialize_app(cred)

class FirebaseAuthentication(BaseAuthentication):
    def authenticate(self, request):

        auth_header = request.headers.get('Authorization')

        if not auth_header or not auth_header.startswith("Bearer "):
            return None  # triggers "Authentication credentials were not provided"

        id_token = auth_header.split(" ").pop()

        try:
            decoded_token = auth.verify_id_token(id_token)
            uid = decoded_token['uid']
        except Exception as e:
            raise AuthenticationFailed(f'Invalid Firebase ID token: {str(e)}')

        User = get_user_model()
        user, _ = User.objects.get_or_create(username=uid)
        return (user, None)
