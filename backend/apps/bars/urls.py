from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_nested.routers import NestedDefaultRouter

from .views import (
    BarViewSet, BarStatusViewSet, BarVoteViewSet,
    BarRatingViewSet, BarImageViewSet
)

router = DefaultRouter()
router.register(r'', BarViewSet,    basename='bar')
router.register(r'status', BarStatusViewSet,  basename='bar-status')
router.register(r'votes',  BarVoteViewSet,    basename='bar-vote')
router.register(r'ratings',BarRatingViewSet,  basename='bar-rating')

# nested under the “bar” prefix
bars_router = NestedDefaultRouter(router, r'', lookup='bar')
bars_router.register(r'images', BarImageViewSet, basename='bar-images')

urlpatterns = [
    path('', include(router.urls)),
    path('', include(bars_router.urls)),
]
