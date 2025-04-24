import logging
import time
from django.utils.deprecation import MiddlewareMixin

logger = logging.getLogger(__name__)

class RequestResponseLoggingMiddleware(MiddlewareMixin):
    def process_request(self, request):
        request.start_time = time.time()
        return None

    def process_response(self, request, response):
        duration = time.time() - request.start_time
        
        # Log request details
        logger.info(
            f"Method: {request.method} | "
            f"Path: {request.path} | "
            f"Status: {response.status_code} | "
            f"Duration: {duration:.2f}s | "
            f"User: {request.user.username if request.user.is_authenticated else 'Anonymous'} | "
            f"IP: {request.META.get('REMOTE_ADDR')}"
        )
        
        # Log request body for non-GET requests
        if request.method != 'GET' and request.body:
            try:
                logger.debug(f"Request Body: {request.body.decode('utf-8')}")
            except UnicodeDecodeError:
                logger.debug("Request Body: [Binary data]")
        
        # Log response for errors
        if response.status_code >= 400:
            try:
                logger.warning(f"Error Response: {response.content.decode('utf-8')}")
            except UnicodeDecodeError:
                logger.warning("Error Response: [Binary data]")
        
        return response 