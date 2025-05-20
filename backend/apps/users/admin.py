from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth import get_user_model
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from django import forms
from django.contrib.gis.forms import OSMWidget
from django.contrib.gis.db import models as gis
from django.contrib.gis.geos import Point
from .models import ProfilePicture
from django.shortcuts import render, redirect
from django.urls import path
from .serializers import ProfilePictureSerializer

User = get_user_model()

class PointFieldWidget(forms.MultiWidget):
    def __init__(self, attrs=None):
        widgets = (
            forms.NumberInput(attrs={'placeholder': 'Latitude', 'step': 'any'}),
            forms.NumberInput(attrs={'placeholder': 'Longitude', 'step': 'any'})
        )
        super().__init__(widgets, attrs)

    def decompress(self, value):
        if value:
            return [value.y, value.x]  # Lat, Lon
        return [None, None]
    
    # def value_from_datadict(self, data, files, name):
    #     lat, lng = [w.value_from_datadict(data, files, name + '_%s' % i) for i, w in enumerate(self.widgets)]
    #     if lat and lng:
    #         try:
    #             return Point(float(lng), float(lat), srid=4326)
    #         except (ValueError, TypeError):
    #             return None
    #     return No

    def value_from_datadict(self, data, files, name):
        return [
            w.value_from_datadict(data, files, f'{name}_{i}')
            for i, w in enumerate(self.widgets)
        ]

class PointFieldFormField(forms.MultiValueField):
    widget = PointFieldWidget
    
    def __init__(self, **kwargs):
        fields = (
            forms.FloatField(required=False),
            forms.FloatField(required=False),
        )
        super().__init__(fields=fields, require_all_fields=False, **kwargs)
    
    def compress(self, data_list):
        if data_list and data_list[0] is not None and data_list[1] is not None:
            return Point(data_list[1], data_list[0], srid=4326)  # (lon, lat)
        return None

class CustomUserChangeForm(UserChangeForm):
    location = PointFieldFormField(required=False)
    
    class Meta(UserChangeForm.Meta):
        model = User
        fields = '__all__'

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
    form = CustomUserChangeForm
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
            path(
                '<path:object_id>/select-location/',
                self.admin_site.admin_view(self.select_location_view),
                name='users_user_select_location',
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
    
    def select_location_view(self, request, object_id):
        user = self.get_queryset(request).get(pk=object_id)
        
        # Define some popular bars as example locations
        popular_bars = [
            {"name": "The Local Pub", "lat": 37.7749, "lng": -122.4194},
            {"name": "Downtown Brewery", "lat": 40.7128, "lng": -74.0060},
            {"name": "Neighborhood Bar & Grill", "lat": 34.0522, "lng": -118.2437},
            {"name": "The Beer Garden", "lat": 41.8781, "lng": -87.6298},
            {"name": "Cocktail Lounge", "lat": 29.7604, "lng": -95.3698},
        ]
        
        if request.method == 'POST':
            selected_bar = request.POST.get('selected_bar')
            if selected_bar:
                bar_index = int(selected_bar)
                bar = popular_bars[bar_index]
                user.location = Point(bar["lng"], bar["lat"], srid=4326)
                user.save()
                self.message_user(request, f"User location set to {bar['name']}")
                return redirect('..')
            else:
                custom_lat = request.POST.get('custom_lat')
                custom_lng = request.POST.get('custom_lng')
                custom_name = request.POST.get('custom_name')
                if custom_lat and custom_lng:
                    user.location = Point(float(custom_lng), float(custom_lat), srid=4326)
                    user.save()
                    self.message_user(request, f"User location set to {custom_name or 'custom location'}")
                    return redirect('..')
        
        context = {
            'user': user,
            'popular_bars': popular_bars,
            'title': f'Select location for {user.username}',
            'opts': self.model._meta,
        }
        return render(request, 'admin/select_location.html', context)
    
    def change_view(self, request, object_id, form_url='', extra_context=None):
        extra_context = extra_context or {}
        extra_context['show_upload_button'] = True
        extra_context['upload_url'] = f'upload-picture/'
        extra_context['show_location_button'] = True
        extra_context['location_url'] = f'select-location/'
        return super().change_view(request, object_id, form_url, extra_context)