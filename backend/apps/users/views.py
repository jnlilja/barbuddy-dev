from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from django.db.models import Q

from rest_framework_simplejwt.authentication import JWTAuthentication
from apps.matches.models import Match
from apps.matches.serializers import MatchSerializer
from .serializers import UserSerializer, UserLocationUpdateSerializer
from .permissions import IsOwnerOrReadOnly
from .authentication import FirebaseAuthentication

from .models import FriendRequest
from .serializers import FriendRequestSerializer


User = get_user_model()

class UserViewSet(viewsets.ModelViewSet):
    authentication_classes = [JWTAuthentication, FirebaseAuthentication]
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]
    queryset = User.objects.all()
    serializer_class = UserSerializer

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
    
    @action(detail=False, methods=["post"])
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