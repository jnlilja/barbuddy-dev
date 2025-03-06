# venue/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('venues/', views.venue_list, name='venue_list'),  # Example view
    path('transactions/', views.create_transaction, name='create_transaction'),  # Example transaction view
]

