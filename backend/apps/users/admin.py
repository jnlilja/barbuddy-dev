from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth import get_user_model

User = get_user_model()

admin.site.register(User, UserAdmin)
# Compare this snippet from backend/barbuddy_api/urls.py:
