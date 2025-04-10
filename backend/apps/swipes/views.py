from rest_framework import viewsets, permissions
from .models import Swipe
from .serializers import SwipeSerializer

class SwipeViewSet(viewsets.ModelViewSet):
    """
    Allows authenticated users to create swipes (like/dislike other users).
    """
    queryset = Swipe.objects.all()
    serializer_class = SwipeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Only return swipes made by the logged-in user
        
        #swagger schma generation
        if getattr(self, 'swagger_fake_view', False):
            return Swipe.objects.none()
        return self.queryset.filter(swiper=self.request.user)

    def perform_create(self, serializer):
        # Automatically assign swiper to the logged-in user
        serializer.save(swiper=self.request.user)
