from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_nested.routers import SimpleRouter, NestedSimpleRouter

from .views import (
    BarViewSet, BarStatusViewSet, BarVoteViewSet,
    BarRatingViewSet, BarImageViewSet, BarHoursViewSet, BarCrowdSizeViewSet
)

router = DefaultRouter()
router.register(r'', BarViewSet, basename='bar')
router.register(r'status', BarStatusViewSet, basename='bar-status')

router.register(r'votes', BarVoteViewSet, basename='bar-vote')
router.register(r'crowd-size', BarCrowdSizeViewSet, basename='bar-crowd-size')
router.register(r'ratings', BarRatingViewSet, basename='bar-rating')
router.register(r'hours', BarHoursViewSet, basename='bar-hours')

# Changed to NestedSimpleRouter
bars_router = NestedSimpleRouter(router, r'bars', lookup='bar')
bars_router.register(r'images', BarImageViewSet, basename='bar-images')

urlpatterns = [
    path('', include(router.urls)),
    path('', include(bars_router.urls)),
]
