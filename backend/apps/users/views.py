from django.contrib.auth import get_user_model
from rest_framework import generics, permissions
from .serializers import UserSerializer

User = get_user_model()

# Signup endpoint
class SignupView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.AllowAny]

# User detail endpoint
class UserDetailView(generics.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
