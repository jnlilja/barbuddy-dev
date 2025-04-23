from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth import get_user_model
from .models import ProfilePicture

User = get_user_model()

@admin.register(User)
class CustomUserAdmin(UserAdmin):
    model = User
    list_display = ('username', 'email', 'account_type', 'is_staff', 'is_superuser')
    fieldsets = UserAdmin.fieldsets + (
        (None, {'fields': ('phone_number', 'date_of_birth', 'hometown', 'job_or_university',
                          'favorite_drink', 'location', 'account_type', 'vote_weight')}),
    )

@admin.register(ProfilePicture)
class ProfilePictureAdmin(admin.ModelAdmin):
    list_display = ('user', 'is_primary')
    list_filter = ('is_primary',)
    search_fields = ('user__username',)
