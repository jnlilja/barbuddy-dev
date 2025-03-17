from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from apps.users.views import UserViewSet
from apps.bars.views import BarViewSet, BarStatusViewSet
from apps.events.views import EventViewSet
from apps.matches.views import MatchViewSet
from apps.messaging.views import MessageViewSet, GroupChatViewSet

# Initialize the router
router = DefaultRouter()

# Register endpoints using the actual ViewSet classes
router.register(r'users', UserViewSet, basename="users")
router.register(r'bars', BarViewSet, basename="bars")
router.register(r'bar-status', BarStatusViewSet, basename="bar-status")
router.register(r'events', EventViewSet, basename="events")
router.register(r'matches', MatchViewSet, basename="matches")
router.register(r'messages', MessageViewSet, basename="messages")
router.register(r'group-chats', GroupChatViewSet, basename="group-chats")

urlpatterns = [
    path("admin/", admin.site.urls),
    path('api/', include(router.urls)),  # Make sure this is included
    path('api/auth/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]
