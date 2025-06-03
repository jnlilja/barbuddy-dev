from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from django.db.models import Q
from apps.swipes.models import Swipe
from django.db import transaction
from rest_framework_simplejwt.authentication import JWTAuthentication
from apps.matches.models import Match
from apps.matches.serializers import MatchSerializer
from .serializers import UserSerializer, UserLocationUpdateSerializer, ProfilePictureSerializer, UserRegistrationSerializer
from .permissions import IsOwnerOrReadOnly
from barbuddy_api.authentication import FirebaseAuthentication
from rest_framework.pagination import PageNumberPagination

from .models import FriendRequest, ProfilePicture
import logging
from django.core.exceptions import ValidationError
from firebase_admin import auth


logger = logging.getLogger(__name__)

User = get_user_model()

def create_firebase_token(uid):
    try:
        custom_token = auth.create_custom_token(uid)
        return custom_token.decode('utf-8')
    except Exception as e:
        logger.error(f"Error creating Firebase token: {str(e)}")
        raise

class SmallResultsSetPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100

class UserViewSet(viewsets.ModelViewSet):
    authentication_classes = [FirebaseAuthentication]
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_permissions(self):
        """
        Override to allow registration without authentication
        """
        if self.action == 'register_user':
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated(), IsOwnerOrReadOnly()]

    def list(self, request, *args, **kwargs):
        # return super().list(request, *args, **kwargs)
        return Response({"detail": "List endpoint is disabled"}, status=status.HTTP_405_METHOD_NOT_ALLOWED)



    def get_queryset(self):
        if getattr(self, 'swagger_fake_view', False):
            return User.objects.none()
            
        user = self.request.user
        if not user or not user.is_authenticated:
            print("User not authenticated in get_queryset") 
            return User.objects.none()
        # For detail view (GET /users/{id}/), allow accessing any user
        if self.action == 'retrieve':
            # if the username is empty, return "No user exists"
            if not user.username:
                print("No user exists")
                return User.objects.none()
            print("Retrieving specific user by ID")
            return User.objects.all()
            
        if user.is_superuser:
            print("Superuser accessing all users")
            return User.objects.all()
            
        # For list and other methods, only return the current user
        print(f"Regular user {user.username} accessing their own profile")
        return User.objects.filter(id=user.id)


    # GET /api/users/location
    @action(detail=False, methods=["get"], permission_classes=[permissions.IsAuthenticated])
    def location(self, request):
        """
        Retrieve the current user's location coordinates.
        Returns latitude and longitude as a JSON object.
        """
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
        """
        Retrieve all active matches for a specific user.
        Only matches with 'connected' status are returned.
        """
        user = self.get_object()
        matches = Match.objects.filter(
            (Q(user1=user) | Q(user2=user)) & Q(status="connected")
        )
        serializer = MatchSerializer(matches, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=["post"], permission_classes=[permissions.IsAuthenticated])
    def update_location(self, request):
        """
        Update the current user's geographic location.
        Expects latitude and longitude in the request body.
        """
        serializer = UserLocationUpdateSerializer(data=request.data)
        if serializer.is_valid():
            serializer.update(request.user, serializer.validated_data)
            return Response({"status": "Location updated successfully."})
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=["post"])
    def send_friend_request(self, request, pk=None):
        """
        Send a friend request to another user.
        The recipient user is identified by the URL parameter.
        """
        to_user = User.objects.get(pk=pk)
        if request.user == to_user:
            return Response({"error": "You cannot send a request to yourself."}, status=400)

        friend_request, created = FriendRequest.objects.get_or_create(from_user=request.user, to_user=to_user)
        if not created:
            return Response({"error": "Friend request already sent."}, status=400)

        return Response({"status": "Friend request sent."})

    @action(detail=True, methods=["post"])
    def respond_friend_request(self, request, pk=None):
        """
        Respond to a pending friend request.
        Expects an 'action' field in the request body with value 'accept' or 'decline'.
        """
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
        """
        List all friends of the current user.
        Returns serialized user data for each friend.
        """
        friends = request.user.friends.all()
        data = UserSerializer(friends, many=True).data
        return Response(data)

    @action(detail=False, methods=['POST'], permission_classes=[permissions.IsAuthenticated])
    def upload_picture(self, request):
        """
        Upload a new profile picture for the current user.
        Expects image data in the request body.
        """
        serializer = ProfilePictureSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['PUT'], permission_classes=[permissions.IsAuthenticated])
    def set_primary_picture(self, request):
        """
        Set a specific picture as the primary profile picture.
        Expects 'picture_id' field in the request body.
        """
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
        """
        Delete a profile picture.
        Expects 'picture_id' field in the request body.
        """
        picture_id = request.data.get('picture_id')
        try:
            picture = ProfilePicture.objects.get(id=picture_id, user=request.user)
            picture.delete()
            return Response({'status': 'Picture deleted successfully'})
        except ProfilePicture.DoesNotExist:
            return Response({'error': 'Picture not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=False, methods=['GET'], permission_classes=[permissions.IsAuthenticated])
    def get_pictures(self, request):
        """
        Get all profile pictures for the current user.
        Returns picture data including id, image URL, and primary status.
        """
        pictures = ProfilePicture.objects.filter(user=request.user)
        serializer = ProfilePictureSerializer(pictures, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['POST'], permission_classes=[permissions.AllowAny])
    def register_user(self, request):
        """
        Register a new user account.
        Creates a user and returns the user data with a Firebase token.
        """
        logger.info(f"Register user request data: {request.data}")
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            try:
                # Use transaction to ensure atomicity
                user = serializer.save()
                user.clean()  # Explicitly call the clean method
                
                # Create Firebase token with user's ID and set the UID
                firebase_token = create_firebase_token(str(user.id))
                # Extract UID from token and save to user
                user.firebase_uid = str(user.id)  # Using user ID as Firebase UID
                user.save()
                
                logger.info(f"User created successfully: {user.id}")
                return Response({
                    'user': UserSerializer(user).data,
                    'firebase_token': firebase_token,
                    'message': 'User registered successfully'
                }, status=status.HTTP_201_CREATED)
            except ValidationError as e:
                logger.error(f"Validation error: {e.message_dict}")
                return Response({'error': e.message_dict}, status=status.HTTP_400_BAD_REQUEST)
            except Exception as e:
                logger.error(f"Unexpected error: {str(e)}")
                return Response({'error': 'An unexpected error occurred.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        logger.error(f"Registration failed: {serializer.errors}")
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['GET'], permission_classes=[permissions.IsAuthenticated])
    def list_all_users(self, request):
        """
        Lists all users that the current user hasn't swiped on yet.
        Returns a paginated list including their profile pictures.
        """
        swiped_users = Swipe.objects.filter(swiper=request.user).values_list('swiped_on', flat=True)
        users = User.objects.exclude(id__in=swiped_users).exclude(id=request.user.id)
        
        paginator = SmallResultsSetPagination()
        result_page = paginator.paginate_queryset(users, request)
        
        simplified_data = []
        for user in result_page:
            pics = ProfilePicture.objects.filter(user=user)
            pics_data = ProfilePictureSerializer(pics, many=True).data
            simplified_data.append({
                "id": user.id,
                "username": user.username,
                "profile_pictures": pics_data,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "date_of_birth": user.date_of_birth,
                "favorite_drink": user.favorite_drink,
                "location": {
                    "latitude": user.location.y,
                    "longitude": user.location.x
                } if user.location else None,
            })

        return paginator.get_paginated_response(simplified_data)
