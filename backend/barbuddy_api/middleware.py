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
            # Only show first 10 chars of token for security
            if len(auth_header) > 15:
                visible_part = auth_header[:15]
                logger.info(f"Authorization header present: {visible_part}...")
            else:
                logger.info("Authorization header present but malformed")
        else:
            logger.info("No Authorization header in request")

        # Log other important request details
        logger.info(f"Request path: {request.path}, Method: {request.method}")
        return None