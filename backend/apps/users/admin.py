from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth import get_user_model
from .models import ProfilePicture

User = get_user_model()

class ProfilePictureInline(admin.TabularInline):
    model = ProfilePicture
    extra = 1

@admin.register(User)
class CustomUserAdmin(UserAdmin):
    model = User
    list_display = ('username', 'email', 'account_type', 'is_staff', 'is_superuser')
    fieldsets = UserAdmin.fieldsets + (
        (None, {'fields': ('phone_number', 'date_of_birth', 'hometown', 
                          'job_or_university', 'favorite_drink', 'location', 
                          'account_type', 'vote_weight')}),  # Removed profile_picture
    )
    inlines = [ProfilePictureInline]
