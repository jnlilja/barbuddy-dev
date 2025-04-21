from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import MessageViewSet, GroupChatViewSet, GroupMessageViewSet, PusherViewSet

router = DefaultRouter()
router.register(r'messages', MessageViewSet, basename='message')
router.register(r'group-chats', GroupChatViewSet, basename='group-chat')
router.register(r'group-messages', GroupMessageViewSet, basename='group-message')
router.register(r'pusher', PusherViewSet, basename='pusher')

urlpatterns = [
    path('', include(router.urls)),
] 