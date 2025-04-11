from django.urls import path, include 
from rest_framework.routers import DefaultRouter
from .views import BarViewSet, BarStatusViewSet


router = DefaultRouter() 
router.register(r'', BarViewSet, basename='bar')
router.register(r'status', BarStatusViewSet, basename='barstatus')



# urlpatterns = [
urlpatterns = [
    path('', include(router.urls)),
]