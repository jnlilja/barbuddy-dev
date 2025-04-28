from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from django.db.models import Q

from rest_framework_simplejwt.authentication import JWTAuthentication
from apps.matches.models import Match
from apps.matches.serializers import MatchSerializer
from .serializers import UserSerializer, UserLocationUpdateSerializer, ProfilePictureSerializer, UserRegistrationSerializer
from .permissions import IsOwnerOrReadOnly
from barbuddy_api.authentication import FirebaseAuthentication

from .models import FriendRequest, ProfilePicture

User = get_user_model()

class UserViewSet(viewsets.ModelViewSet):
    authentication_classes = [FirebaseAuthentication]
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]
    queryset = User.objects.all()
    serializer_class = UserSerializer

    # def get_permissions(self):
    #     if self.action == 'create':
    #         return [permissions.AllowAny()]
    #     return [permissions.IsAuthenticated(), IsOwnerOrReadOnly()]

    def get_queryset(self):
        user = self.request.user
        if not user or not user.is_authenticated:
            print("❌ User not authenticated in get_queryset")
            return User.objects.none()
        if user.is_superuser:
            print("✅ Superuser accessing all users")
            return User.objects.all()
        print(f"✅ Regular user {user.username} accessing their own profile")
        return User.objects.filter(id=user.id)

    def list(self, request, *args, **kwargs):
        print("📝 Request headers:", dict(request.headers))
        print("📝 Request META:", {k: v for k, v in request.META.items() if k.startswith('HTTP_')})
        return super().list(request, *args, **kwargs)

    # GET /api/users/location
    @action(detail=False, methods=["get"], permission_classes=[permissions.IsAuthenticated])
    def location(self, request):
        user = request.user
        if user.location:
            return Response({
                "latitude": user.location.y,
                "longitude": user.location.x
            })
        return Response({"error": "Location not set."}, status=400)

    # GET /api/users/{id}/matches/
    @action(detail=True, methods=["get"], permission_classes=[permissions.IsAuthenticated])
    def matches(self, request, pk=None):
        user = self.get_object()
        matches = Match.objects.filter(
            (Q(user1=user) | Q(user2=user)) & Q(status="connected")
        )
        serializer = MatchSerializer(matches, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=["post"], permission_classes=[permissions.IsAuthenticated])
    def update_location(self, request):
        serializer = UserLocationUpdateSerializer(data=request.data)
        if serializer.is_valid():
            serializer.update(request.user, serializer.validated_data)
            return Response({"status": "Location updated successfully."})
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=["post"])
    def send_friend_request(self, request, pk=None):
        to_user = User.objects.get(pk=pk)
        if request.user == to_user:
            return Response({"error": "You cannot send a request to yourself."}, status=400)

        friend_request, created = FriendRequest.objects.get_or_create(from_user=request.user, to_user=to_user)
        if not created:
            return Response({"error": "Friend request already sent."}, status=400)

        return Response({"status": "Friend request sent."})

    @action(detail=True, methods=["post"])
    def respond_friend_request(self, request, pk=None):
        action = request.data.get("action")
        try:
            fr = FriendRequest.objects.get(pk=pk, to_user=request.user)
        except FriendRequest.DoesNotExist:
            return Response({"error": "Friend request not found."}, status=404)

        if action == "accept":
            fr.status = "accepted"
            fr.save()
            request.user.friends.add(fr.from_user)
            fr.from_user.friends.add(request.user)
            return Response({"status": "Friend request accepted."})
        elif action == "decline":
            fr.status = "declined"
            fr.save()
            return Response({"status": "Friend request declined."})
        return Response({"error": "Invalid action."}, status=400)

    @action(detail=False, methods=["get"])
    def friends(self, request):
        friends = request.user.friends.all()
        data = UserSerializer(friends, many=True).data
        return Response(data)

    @action(detail=False, methods=['POST'], permission_classes=[permissions.IsAuthenticated])
    def upload_picture(self, request):
        """Upload a new profile picture"""
        serializer = ProfilePictureSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['PUT'], permission_classes=[permissions.IsAuthenticated])
    def set_primary_picture(self, request):
        """Set a picture as primary"""
        picture_id = request.data.get('picture_id')
        try:
            picture = ProfilePicture.objects.get(id=picture_id, user=request.user)
            picture.is_primary = True
            picture.save()
            return Response({'status': 'Primary picture updated successfully'})
        except ProfilePicture.DoesNotExist:
            return Response({'error': 'Picture not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=False, methods=['DELETE'], permission_classes=[permissions.IsAuthenticated])
    def delete_picture(self, request):
        """Delete a profile picture"""
        picture_id = request.data.get('picture_id')
        try:
            picture = ProfilePicture.objects.get(id=picture_id, user=request.user)
            picture.delete()
            return Response({'status': 'Picture deleted successfully'})
        except ProfilePicture.DoesNotExist:
            return Response({'error': 'Picture not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=False, methods=['GET'], permission_classes=[permissions.IsAuthenticated])
    def get_pictures(self, request):
        """Get all profile pictures for the current user"""
        pictures = ProfilePicture.objects.filter(user=request.user)
        serializer = ProfilePictureSerializer(pictures, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['POST'], permission_classes=[permissions.AllowAny])
    def register_user(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response({
                'user': UserSerializer(user).data,
                'message': 'User registered successfully'
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
