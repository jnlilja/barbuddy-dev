from loguru import logger
from django.http import JsonResponse

class ErrorHandlingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        try:
            response = self.get_response(request)
            return response
        except Exception as e:
            logger.error(f"Error occurred: {str(e)}")
            return JsonResponse({'error': 'Something went wrong'}, status=500)
