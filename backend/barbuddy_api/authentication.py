# barbuddy_api/authentication.py

import firebase_admin
from firebase_admin import auth, credentials
from firebase_admin.exceptions import FirebaseError
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from django.contrib.auth import get_user_model
from django.core.exceptions import FieldError
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
    logger.info(f"Initializing Firebase Admin with service account")
    if not os.path.exists(SERVICE_ACCOUNT_PATH):
        logger.error("Service account file not found")
        raise FileNotFoundError("Service account file not found")
    
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)
    logger.info("Firebase Admin initialized successfully")

class FirebaseAuthentication(BaseAuthentication):
    def authenticate(self, request):
        # Add more specific logging for troubleshooting
        logger.info(f"Processing authentication request for path: {request.path}")
        
        # Skip authentication for certain paths
        if request.path.endswith('/register_user/') or 'swagger' in request.path or request.path == '/api/auth-test/':
            logger.info(f"Skipping auth requirement for path: {request.path}")
            return None
        
        # Log all available headers for debugging
        headers = dict(request.headers.items())
        safe_headers = {k: v for k, v in headers.items() if k.lower() not in 
                       ['authorization', 'cookie', 'x-csrf-token']}
        logger.info(f"Request headers: {safe_headers}")
        
        # Check all possible header locations
        auth_header = None
        header_locations = [
            ('direct', request.headers.get('Authorization')),
            ('direct_lower', request.headers.get('authorization')),
            ('x_prefix', request.headers.get('X-Authorization')),
            ('meta', request.META.get('HTTP_AUTHORIZATION')),
            ('meta_lower', request.META.get('HTTP_AUTHORIZATION'.lower())),
            ('meta_x', request.META.get('HTTP_X_AUTHORIZATION'))
        ]
        
        for location_name, header_value in header_locations:
            if header_value:
                auth_header = header_value
                logger.info(f"Found auth header in {location_name}")
                break
        
        if not auth_header:
            logger.warning("No Authorization header found in any location")
            return None

        # Clean up the header value
        auth_header = auth_header.strip()
        if not auth_header.startswith("Bearer "):
            logger.warning("Authorization header does not start with 'Bearer'")
            return None

        try:
            id_token = auth_header.split(" ")[1]  # Get the token part after "Bearer "
            logger.info(f"Token starts with: {id_token[:15]}...")

            # Print more detailed token structure for debugging
            token_parts = id_token.split('.')
            logger.info(f"Token has {len(token_parts)} parts")
            
            # Specific Firebase token verification exceptions
            try:
                logger.info("Attempting to verify Firebase ID token")
                decoded_token = auth.verify_id_token(id_token)
                
                # Log token details (but not the sensitive parts)
                logger.info(f"Token verified. Auth time: {decoded_token.get('auth_time')}, Provider: {decoded_token.get('firebase', {}).get('sign_in_provider')}")
                
                uid = decoded_token.get('uid')
                if not uid:
                    logger.error("No UID found in decoded token")
                    raise AuthenticationFailed('Invalid token format')
                logger.info(f"Successfully verified token")
            except auth.InvalidIdTokenError:
                logger.warning("Invalid token")
                raise AuthenticationFailed('Invalid token')
            except auth.ExpiredIdTokenError:
                logger.warning("Expired token")
                raise AuthenticationFailed('Token expired')
            except auth.RevokedIdTokenError:
                logger.warning("Revoked token")
                raise AuthenticationFailed('Token revoked')
            except FirebaseError as e:
                logger.error(f"Firebase error: {str(e)}")
                raise AuthenticationFailed('Authentication error')

            User = get_user_model()
            try:
                # Try looking up by firebase_uid field first (assuming you added this field to your User model)
                try:
                    user = User.objects.get(firebase_uid=uid)
                    logger.info(f"Found existing user by firebase_uid")
                except (User.DoesNotExist, FieldError):
                    # Fall back to username lookup if firebase_uid field doesn't exist
                    user = User.objects.get(username=uid)
                    logger.info(f"Found existing user by username")
            
                # Add specific iOS client logs
                user_agent = request.META.get('HTTP_USER_AGENT', '')
                if 'CFNetwork' in user_agent or 'Darwin' in user_agent:
                    logger.info(f"iOS client successfully authenticated: {user.username}")
                
                # If this is a POST request to /api/users/, update the user's profile
                if request.method == 'POST' and request.path == '/api/users/':
                    try:
                        data = request.data
                        logger.info("Updating user profile")
                        
                        # Update user fields - don't log the data
                        self._update_user_fields(user, data)
                        
                        user.save()
                        logger.info(f"Successfully updated user profile")
                    except ValueError as e:
                        logger.error(f"Value error: {str(e)}")
                        raise AuthenticationFailed(f'Value error: {str(e)}')
                    except Exception as e:
                        logger.error(f"Error updating user profile: {str(e)}")
                        raise AuthenticationFailed('Error updating user profile')
            except User.DoesNotExist:
                # If this is a POST request to /api/users/, create a new user with profile data
                if request.method == 'POST' and request.path == '/api/users/':
                    try:
                        data = request.data
                        logger.info("Creating new user")
                        
                        # Create user with profile data
                        user = self._create_user_with_data(uid, data)
                        
                        logger.info("Successfully created new user")
                    except ValueError as e:
                        logger.error(f"Value error: {str(e)}")
                        raise AuthenticationFailed(f'Value error: {str(e)}')
                    except Exception as e:
                        logger.error(f"Error creating user: {str(e)}")
                        raise AuthenticationFailed('Error creating user')
                else:
                    # For non-POST requests, create a basic user with UID
                    user = User.objects.create(username=uid)
                    logger.info("Created new user with basic info")
                
            return (user, None)
        except IndexError:
            logger.warning("Malformed Authorization header")
            return None
        except Exception as e:
            logger.error(f"Unexpected authentication error: {type(e).__name__}")
            raise AuthenticationFailed('Authentication failed')

    def _update_user_fields(self, user, data):
        """Helper method to update user fields from data"""
        fields = [
            'username', 'first_name', 'last_name', 'email', 
            'hometown', 'job_or_university', 'favorite_drink', 
            'sexual_preference', 'account_type'
        ]
        
        for field in fields:
            if field in data:
                setattr(user, field, data[field])
                
        # Handle date_of_birth separately
        if 'date_of_birth' in data:
            date_str = data['date_of_birth']
            try:
                date_obj = datetime.strptime(date_str, '%Y-%m-%d').date()
                user.date_of_birth = date_obj
            except ValueError:
                raise ValueError(f'Invalid date format. Use YYYY-MM-DD format.')
    
    def _create_user_with_data(self, uid, data):
        """Helper method to create a user with the given data"""
        user = get_user_model().objects.create(
            username=data.get('username', uid),
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
            except ValueError:
                raise ValueError(f'Invalid date format. Use YYYY-MM-DD format.')
        
        user.save()
        return user