import logging
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from barbuddy_api.authentication import FirebaseAuthentication

logger = logging.getLogger(__name__)

class FirebaseAuthTestView(APIView):
    authentication_classes = [FirebaseAuthentication]
    permission_classes = [AllowAny]  # Temporarily allow any to debug

    def get(self, request):
        # Log the authentication status
        if request.user and request.user.is_authenticated:
            logger.info(f"User authenticated as: {request.user.username}")
            return Response({
                "message": "Authentication successful",
                "user": request.user.username,
                "authenticated": True
            })
        else:
            logger.warning("Authentication failed in test endpoint")
            # Return details about the request to help debug
            auth_header = request.META.get('HTTP_AUTHORIZATION', 'None')
            safe_auth = auth_header[:15] + "..." if len(auth_header) > 15 else auth_header
            
            return Response({
                "message": "Authentication failed",
                "authenticated": False,
                "debug_info": {
                    "auth_header_present": auth_header != 'None',
                    "auth_header_prefix": safe_auth[:15] if auth_header != 'None' else None,
                }
            }, status=401)