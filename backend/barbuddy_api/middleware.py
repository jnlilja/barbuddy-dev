import json
import logging
import time
from django.utils.deprecation import MiddlewareMixin

logger = logging.getLogger('barbuddy')

class RequestLoggingMiddleware(MiddlewareMixin):
    def process_request(self, request):
        # For debugging auth issues, log the full auth header
        auth_header = request.META.get('HTTP_AUTHORIZATION', '')
        if auth_header:
            # Safely log part of the token
            if len(auth_header) > 15:
                visible_part = auth_header[:15]
                logger.info(f"Authorization header present: {visible_part}...")
            else:
                logger.info("Authorization header present but malformed")
                
            # Add specific logging for Swift client
            user_agent = request.META.get('HTTP_USER_AGENT', '')
            if 'CFNetwork' in user_agent or 'Darwin' in user_agent:  # Common in iOS/Swift
                logger.info(f"Request from iOS client. User agent: {user_agent}")
        else:
            # Check alternate header locations used by some clients
            alt_headers = [
                request.META.get('HTTP_X_AUTHORIZATION', ''),
                request.headers.get('Authorization', ''),
                request.headers.get('X-Authorization', '')
            ]
            if any(alt_headers):
                logger.info("Auth header found in alternate location")
                
        # Log other important request details
        logger.info(f"Request path: {request.path}, Method: {request.method}")
        return None