import firebase_admin
from firebase_admin import auth, credentials
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from django.contrib.auth import get_user_model

User = get_user_model()

# Only initialize once


class FirebaseAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')

        if not auth_header or not auth_header.startswith('Bearer '):
            return None

        id_token = auth_header.split(' ')[1]

        try:
            decoded_token = auth.verify_id_token(id_token)
            uid = decoded_token['uid']
        except Exception:
            raise AuthenticationFailed('Invalid Firebase ID token')

        try:
            # Look for user by firebase_uid instead of username
            user = User.objects.get(firebase_uid=uid)
        except User.DoesNotExist:
            # Don't auto-create users - this should be handled by registration
            raise AuthenticationFailed('User not found')

        return (user, None)
    
    
