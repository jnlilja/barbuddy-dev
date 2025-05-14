from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth import get_user_model
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from django import forms
from .models import ProfilePicture
from django.shortcuts import render, redirect
from django.urls import path
from .serializers import ProfilePictureSerializer

User = get_user_model()

class CustomUserCreationForm(UserCreationForm):
    email = forms.EmailField(required=True)
    
    class Meta(UserCreationForm.Meta):
        model = User
        fields = ('username', 'email')
    
    def clean_email(self):
        # Just return the email, we'll handle uniqueness in save()
        return self.cleaned_data.get('email')
        
    def save(self, commit=True):
        user = super().save(commit=False)
        user.email = self.cleaned_data['email']
        
        # Set a flag to skip email validation in the model's clean method
        user._skip_email_validation = True
        
        if commit:
            user.save()
        return user

class ProfilePictureInline(admin.TabularInline):
    model = ProfilePicture
    extra = 0  # Don't show empty forms by default
    readonly_fields = ('preview_image',)
    fields = ('image', 'is_primary', 'preview_image')
    
    def preview_image(self, obj):
        if obj.image:
            return f'<img src="{obj.image.url}" width="150" />'
        return "No image"
    preview_image.allow_tags = True
    preview_image.short_description = 'Preview'
    
    def get_queryset(self, request):
        # Only show existing profile pictures
        qs = super().get_queryset(request)
        return qs

class UploadPictureForm(forms.Form):
    image = forms.ImageField()

@admin.register(User)
class CustomUserAdmin(UserAdmin):
    form = UserChangeForm
    add_form = CustomUserCreationForm
    model = User
    list_display = ('username', 'email', 'account_type', 'is_staff', 'is_superuser')
    
    fieldsets = UserAdmin.fieldsets + (
        (None, {'fields': ('phone_number', 'date_of_birth', 'hometown', 
                          'job_or_university', 'favorite_drink', 'location', 
                          'account_type', 'vote_weight')}),
    )
    
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'password1', 'password2'),
        }),
    )
    
    inlines = [ProfilePictureInline]
    
    def get_inlines(self, request, obj=None):
        # Only show profile pictures for existing users
        if obj is None:  # obj is None when adding a new user
            return []
        return [ProfilePictureInline]
    
    def get_urls(self):
        urls = super().get_urls()
        custom_urls = [
            path(
                '<path:object_id>/upload-picture/',
                self.admin_site.admin_view(self.upload_picture_view),
                name='users_user_upload_picture',
            ),
        ]
        return custom_urls + urls
    
    def upload_picture_view(self, request, object_id):
        user = self.get_queryset(request).get(pk=object_id)
        
        if request.method == 'POST':
            form = UploadPictureForm(request.POST, request.FILES)
            if form.is_valid():
                # Use the same logic as your API endpoint
                serializer = ProfilePictureSerializer(data={'image': request.FILES['image']})
                if serializer.is_valid():
                    serializer.save(user=user)
                    self.message_user(request, "Profile picture uploaded successfully")
                    return redirect('..')
                else:
                    form.add_error('image', serializer.errors)
        else:
            form = UploadPictureForm()
            
        context = {
            'form': form,
            'title': f'Upload profile picture for {user.username}',
            'opts': self.model._meta,
        }
        return render(request, 'admin/upload_picture_form.html', context)
    
    def change_view(self, request, object_id, form_url='', extra_context=None):
        extra_context = extra_context or {}
        extra_context['show_upload_button'] = True
        extra_context['upload_url'] = f'upload-picture/'
        return super().change_view(request, object_id, form_url, extra_context)