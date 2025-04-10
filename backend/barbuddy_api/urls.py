from django.contrib import admin
from django.urls import path, include, re_path
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from apps.users.views import UserViewSet
from apps.bars.views import BarViewSet, BarStatusViewSet
from apps.events.views import EventViewSet
from apps.matches.views import MatchViewSet
from apps.messaging.views import MessageViewSet, GroupChatViewSet
from apps.swipes.views import SwipeViewSet
from django.shortcuts import redirect
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
router.register(r'swipes', SwipeViewSet, basename='swipe')


from django.urls import path, re_path
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi
from django.urls import path
from apps.messaging.views import send_pusher_message


schema_view = get_schema_view(
    openapi.Info(
        title="My API",
        default_version='v1',
        description="API documentation for My API",
        terms_of_service="https://www.example.com/terms/",
        contact=openapi.Contact(email="contact@example.com"),
        license=openapi.License(name="BSD License"),
    ),
    public=True,
    permission_classes=(permissions.AllowAny,),
)


urlpatterns = [
    path("admin/", admin.site.urls),
    path('api/', include(router.urls)),
    path('api/auth/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('trigger/', send_pusher_message, name='trigger-message'),

    # Swagger / Redoc Docs
    re_path(r'^swagger(?P<format>\.json|\.yaml)$', schema_view.without_ui(cache_timeout=0), name='schema-json'),
    path('swagger/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    path('redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),


    # Root path handler 
    path('', lambda request: redirect('schema-swagger-ui', permanent=False)),
]