from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from django.db.models import Q
from rest_framework.throttling import AnonRateThrottle, UserRateThrottle

from rest_framework_simplejwt.authentication import JWTAuthentication
from apps.matches.models import Match
from apps.matches.serializers import MatchSerializer
from .serializers import UserSerializer, UserLocationUpdateSerializer
from .permissions import IsOwnerOrReadOnly
from .authentication import FirebaseAuthentication

from .models import FriendRequest, ProfilePicture
from .serializers import FriendRequestSerializer, ProfilePictureSerializer

import logging

logger = logging.getLogger(__name__)

User = get_user_model()

class UserViewSet(viewsets.ModelViewSet):
    authentication_classes = [JWTAuthentication, FirebaseAuthentication]
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]
    queryset = User.objects.all()
    serializer_class = UserSerializer
    throttle_classes = [AnonRateThrottle, UserRateThrottle]

    def get_throttles(self):
        if self.action == 'create':
            return [AnonRateThrottle()]
        return super().get_throttles()

    def get_permissions(self):
        if self.action == 'create':
            return []
        return super().get_permissions()

    def get_queryset(self):
        user = self.request.user
        if not user or not user.is_authenticated:
            return User.objects.none()
        if user.is_superuser:
            return User.objects.all()
        return User.objects.filter(id=user.id)

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
    
    @action(detail=False, methods=["post"], permission_classes=[permissions.IsAuthenticated])
    def update_profile_pictures(self, request):
        user = request.user
        pics = request.data.get("profile_pictures", [])
        if not isinstance(pics, list):
            return Response({"error": "Expected a list of image URLs."}, status=400)

        user.profile_pictures = pics
        user.save()
        return Response({"status": "Profile pictures updated."})
    
    @action(detail=False, methods=["delete"])
    def delete_profile_picture(self, request):
        user = request.user
        url_to_remove = request.data.get("url")

        if not url_to_remove:
            return Response({"error": "No URL provided."}, status=400)

        if url_to_remove not in user.profile_pictures:
            return Response({"error": "URL not found in profile pictures."}, status=404)

        user.profile_pictures.remove(url_to_remove)
        user.save()
        return Response({"status": "Profile picture removed."})

    @action(detail=False, methods=["post"], permission_classes=[permissions.IsAuthenticated])
    def upload_profile_picture(self, request):
        serializer = ProfilePictureSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=["patch"], permission_classes=[permissions.IsAuthenticated])
    def set_primary_picture(self, request, pk=None):
        try:
            picture = ProfilePicture.objects.get(pk=pk, user=request.user)
            picture.is_primary = True
            picture.save()
            return Response({"status": "Primary picture updated."})
        except ProfilePicture.DoesNotExist:
            return Response({"error": "Picture not found."}, status=404)

    @action(detail=True, methods=["delete"], permission_classes=[permissions.IsAuthenticated])
    def delete_profile_picture(self, request, pk=None):
        try:
            picture = ProfilePicture.objects.get(pk=pk, user=request.user)
            picture.delete()
            return Response({"status": "Picture deleted."})
        except ProfilePicture.DoesNotExist:
            return Response({"error": "Picture not found."}, status=404)

    def create(self, request, *args, **kwargs):
        logger.info(f"Attempting to create new user with email: {request.data.get('email')}")
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        logger.info(f"Successfully created user with email: {request.data.get('email')}")
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    @action(detail=True, methods=['post'])
    def update_profile_pictures(self, request, pk=None):
        user = self.get_object()
        url = request.data.get('url')
        
        if not url:
            logger.warning(f"Missing URL in profile picture update request for user: {user.id}")
            return Response(
                {'error': 'URL is required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
            
        try:
            user.add_profile_picture(url)
            logger.info(f"Successfully added profile picture for user: {user.id}")
            return Response(
                {'message': 'Profile picture added successfully'}, 
                status=status.HTTP_200_OK
            )
        except Exception as e:
            logger.error(f"Error adding profile picture for user {user.id}: {str(e)}")
            return Response(
                {'error': str(e)}, 
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=True, methods=['delete'])
    def delete_profile_picture(self, request, pk=None):
        user = self.get_object()
        url = request.data.get('url')
        
        if not url:
            logger.warning(f"Missing URL in profile picture deletion request for user: {user.id}")
            return Response(
                {'error': 'URL is required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
            
        try:
            user.remove_profile_picture(url)
            logger.info(f"Successfully removed profile picture for user: {user.id}")
            return Response(
                {'message': 'Profile picture removed successfully'}, 
                status=status.HTTP_200_OK
            )
        except Exception as e:
            logger.error(f"Error removing profile picture for user {user.id}: {str(e)}")
            return Response(
                {'error': str(e)}, 
                status=status.HTTP_400_BAD_REQUEST
            )