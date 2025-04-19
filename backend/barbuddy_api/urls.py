from django.contrib import admin
from django.urls import path, include, re_path
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from apps.users.views import UserViewSet
from apps.bars.views import BarViewSet, BarStatusViewSet, BarRatingViewSet, BarImageViewSet
from apps.events.views import EventViewSet
from apps.matches.views import MatchViewSet
from apps.messaging.views import MessageViewSet, GroupChatViewSet, PusherViewSet, GroupMessageViewSet
from apps.swipes.views import SwipeViewSet
from django.shortcuts import redirect
# from .views import BarVoteViewSet
from apps.bars.views import BarVoteViewSet
from rest_framework_nested.routers import NestedDefaultRouter
from django.conf import settings
from django.conf.urls.static import static



from .views import FirebaseAuthTestView
# Initialize the router
router = DefaultRouter()

# Register endpoints using the actual ViewSet classes

### Router registration
# Endpoints names, these must match viewset names
router.register(r'bars', BarViewSet, basename="bars")
router.register(r'bar-status', BarStatusViewSet, basename="bar-status")
router.register(r'bar-votes', BarVoteViewSet, basename='barvote')  
router.register(r'events', EventViewSet, basename="events")

# MUST DO: MATCHES
router.register(r'matches', MatchViewSet, basename="matches")

#MUST DO: MESSAGING
router.register(r'messages', MessageViewSet, basename='message')
router.register(r'group-chats', GroupChatViewSet, basename='group-chat')
router.register(r'group-messages', GroupMessageViewSet, basename='group-message')

# MUST DO: SWIPES
router.register(r'swipes', SwipeViewSet, basename='swipe')

# MUST DO: Users
router.register(r'users', UserViewSet, basename="users")

# MUST DO: Pusher
router.register(r'pusher', PusherViewSet, basename="pusher")


from django.urls import path, re_path
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi
from django.urls import path


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

bars_router = NestedDefaultRouter(router, r'bars', lookup='bar')
bars_router.register(r'images', BarImageViewSet, basename='bar-images')

urlpatterns = [
    # Admin panel
    path("admin/", admin.site.urls),
    path('api/', include(router.urls)),
    path('api/', include(bars_router.urls)),
    # Firebase url
    path('api/test-auth/', FirebaseAuthTestView.as_view(), name='firebase-test'),



    # Include the URLs for the apps

    ##


    # Swagger / Redoc Docs
    re_path(r'^swagger(?P<format>\.json|\.yaml)$', schema_view.without_ui(cache_timeout=0), name='schema-json'),
    path('swagger/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    path('redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),


    # Root path handler 
    path('', lambda request: redirect('schema-swagger-ui', permanent=False)),
]+ static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

