# barbuddy_api/authentication.py

import firebase_admin
from firebase_admin import auth, credentials
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from django.contrib.auth import get_user_model
import os
import logging
from datetime import datetime

# Set up logging
logger = logging.getLogger(__name__)

# Get the absolute path to the service account file
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SERVICE_ACCOUNT_PATH = os.path.join(BASE_DIR, 'firebase', 'service-account.json')

# Only initialize once
if not firebase_admin._apps:
    logger.info(f"Initializing Firebase Admin with service account at: {SERVICE_ACCOUNT_PATH}")
    if not os.path.exists(SERVICE_ACCOUNT_PATH):
        logger.error(f"Service account file not found at: {SERVICE_ACCOUNT_PATH}")
        raise FileNotFoundError(f"Service account file not found at: {SERVICE_ACCOUNT_PATH}")
    
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)
    logger.info("Firebase Admin initialized successfully")

class FirebaseAuthentication(BaseAuthentication):
    def authenticate(self, request):
        # Log all headers for debugging
        logger.info(f"All request headers: {dict(request.headers)}")
        logger.info(f"All META data: {dict(request.META)}")
        
        # Try different header names for Authorization
        auth_header = None
        header_names = [
            'Authorization',
            'HTTP_AUTHORIZATION',
            'HTTP_AUTH',
            'HTTP_X_AUTHORIZATION',
            'X-Authorization',
            'authorization'  # Add lowercase version
        ]
        
        for header_name in header_names:
            # Try direct header access
            auth_header = request.headers.get(header_name)
            if auth_header:
                logger.info(f"Found Authorization header in headers[{header_name}]: {auth_header}")
                break
                
            # Try META access
            auth_header = request.META.get(header_name)
            if auth_header:
                logger.info(f"Found Authorization header in META[{header_name}]: {auth_header}")
                break
                
            # Try HTTP_ prefixed META access
            http_header = f"HTTP_{header_name.upper()}"
            auth_header = request.META.get(http_header)
            if auth_header:
                logger.info(f"Found Authorization header in META[{http_header}]: {auth_header}")
                break

        if not auth_header:
            logger.warning("No Authorization header found in any location")
            # Log all available headers and META data for debugging
            logger.info("Available headers:")
            for key, value in request.headers.items():
                logger.info(f"  {key}: {value}")
            logger.info("Available META data:")
            for key, value in request.META.items():
                if key.startswith('HTTP_'):
                    logger.info(f"  {key}: {value}")
            return None

        # Clean up the header value
        auth_header = auth_header.strip()
        if not auth_header.startswith("Bearer "):
            logger.warning(f"Authorization header does not start with 'Bearer ': {auth_header}")
            return None

        try:
            id_token = auth_header.split(" ")[1]  # Get the token part after "Bearer "
            logger.info(f"Extracted token: {id_token[:10]}...")  # Log first 10 chars for security

            logger.info("Attempting to verify Firebase ID token")
            decoded_token = auth.verify_id_token(id_token)
            uid = decoded_token['uid']
            logger.info(f"Successfully verified token for user: {uid}")
        except Exception as e:
            logger.error(f"Token verification failed: {str(e)}")
            raise AuthenticationFailed(f'Invalid Firebase ID token: {str(e)}')

        User = get_user_model()
        try:
            user = User.objects.get(username=uid)
            logger.info(f"Found existing user with UID: {uid}")
            
            # If this is a POST request to /api/users/, update the user's profile
            if request.method == 'POST' and request.path == '/api/users/':
                try:
                    data = request.data
                    logger.info(f"Updating user profile with data: {data}")
                    
                    # Update user fields
                    if 'username' in data:
                        user.username = data['username']
                    if 'first_name' in data:
                        user.first_name = data['first_name']
                    if 'last_name' in data:
                        user.last_name = data['last_name']
                    if 'email' in data:
                        user.email = data['email']
                    if 'date_of_birth' in data:
                        # Convert string date to date object
                        date_str = data['date_of_birth']
                        try:
                            date_obj = datetime.strptime(date_str, '%Y-%m-%d').date()
                            user.date_of_birth = date_obj
                        except ValueError as e:
                            logger.error(f"Invalid date format: {date_str}")
                            raise AuthenticationFailed(f'Invalid date format: {date_str}')
                    if 'hometown' in data:
                        user.hometown = data['hometown']
                    if 'job_or_university' in data:
                        user.job_or_university = data['job_or_university']
                    if 'favorite_drink' in data:
                        user.favorite_drink = data['favorite_drink']
                    if 'sexual_preference' in data:
                        user.sexual_preference = data['sexual_preference']
                    if 'account_type' in data:
                        user.account_type = data['account_type']
                    
                    user.save()
                    logger.info(f"Successfully updated user profile for UID: {uid}")
                except Exception as e:
                    logger.error(f"Error updating user profile: {str(e)}")
                    raise AuthenticationFailed(f'Error updating user profile: {str(e)}')
        except User.DoesNotExist:
            # If this is a POST request to /api/users/, create a new user with profile data
            if request.method == 'POST' and request.path == '/api/users/':
                try:
                    data = request.data
                    logger.info(f"Creating new user with data: {data}")
                    
                    # Create user with profile data
                    user = User.objects.create(
                        username=data.get('username', uid),  # Use provided username or UID
                        first_name=data.get('first_name', ''),
                        last_name=data.get('last_name', ''),
                        email=data.get('email', ''),
                        hometown=data.get('hometown', ''),
                        job_or_university=data.get('job_or_university', ''),
                        favorite_drink=data.get('favorite_drink', ''),
                        sexual_preference=data.get('sexual_preference', ''),
                        account_type=data.get('account_type', '')
                    )
                    
                    # Handle date_of_birth separately
                    if 'date_of_birth' in data:
                        date_str = data['date_of_birth']
                        try:
                            date_obj = datetime.strptime(date_str, '%Y-%m-%d').date()
                            user.date_of_birth = date_obj
                        except ValueError as e:
                            logger.error(f"Invalid date format: {date_str}")
                            raise AuthenticationFailed(f'Invalid date format: {date_str}')
                    
                    user.save()
                    logger.info(f"Successfully created new user with UID: {uid}")
                except Exception as e:
                    logger.error(f"Error creating user: {str(e)}")
                    raise AuthenticationFailed(f'Error creating user: {str(e)}')
            else:
                # For non-POST requests, create a basic user with UID
                user = User.objects.create(username=uid)
                logger.info(f"Created new user with UID: {uid}")
            
        return (user, None)
