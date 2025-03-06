from django.urls import path, include
from .views import VenueListView, TransactionListView
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r'venues', VenueListView)
router.register(r'transactions', TransactionListView)

urlpatterns = [
    path('api/', include(router.urls)),
]


