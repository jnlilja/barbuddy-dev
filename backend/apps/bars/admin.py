from django import forms
from django.contrib import admin
from django.contrib.gis.geos import Point
from django.core.exceptions import ValidationError
from django.contrib.gis.measure import D
from django.contrib.gis.db.models.functions import Distance
import certifi
import ssl
from geopy.geocoders import Nominatim

from .models import Bar, BarStatus, BarRating, BarImage, BarHours, BarVote, BarCrowdSize
from apps.users.models import User


# Optional fallback if GIS is not available
try:
    from django.contrib.gis.admin import OSMGeoAdmin
    GeoAdminBase = OSMGeoAdmin
except ImportError:
    GeoAdminBase = admin.ModelAdmin

from django.contrib.gis.forms import PointField as GISPointField
from django.forms import HiddenInput

class BarAdminForm(forms.ModelForm):
    latitude = forms.FloatField(required=False, label="Latitude")
    longitude = forms.FloatField(required=False, label="Longitude")

    class Meta:
        model = Bar
        fields = '__all__'

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if self.instance and self.instance.location:
            self.fields['latitude'].initial = self.instance.location.y
            self.fields['longitude'].initial = self.instance.location.x

    def clean(self):
        cleaned_data = super().clean()
        lat = cleaned_data.get('latitude')
        lon = cleaned_data.get('longitude')
        if lat is not None and lon is not None:
            from django.contrib.gis.geos import Point
            cleaned_data['location'] = Point(lon, lat)
            self.instance.location = Point(lon, lat)
        return cleaned_data


# Use regular ModelAdmin, not OSMGeoAdmin
@admin.register(Bar)
class BarAdmin(admin.ModelAdmin):
    form = BarAdminForm
    list_display = ("name", "address", "average_price")
    search_fields = ("name", "address")
    filter_horizontal = ("users_at_bar",)
    inlines = [
        type(
            "BarImageInline",
            (admin.TabularInline,),
            {
                "model": BarImage,
                "extra": 1,
                "fields": ("image", "caption"),
                "readonly_fields": ("uploaded_at",),
            },
        ),
    ]

    def formfield_for_manytomany(self, db_field, request, **kwargs):
        if db_field.name == 'users_at_bar':
            qs = User.objects.exclude(location__isnull=True)
            object_id = request.resolver_match.kwargs.get('object_id')
            if object_id:
                try:
                    bar = self.model.objects.get(pk=object_id)
                except Bar.DoesNotExist:
                    bar = None
                else:
                    qs = qs.annotate(
                        dist=Distance('location', bar.location)
                    ).filter(dist__lte=D(m=50))
            kwargs['queryset'] = qs
        return super().formfield_for_manytomany(db_field, request, **kwargs)

    def save_model(self, request, obj, form, change):
        super().save_model(request, obj, form, change)
        from apps.bars.services.proximity import update_users_at_bar
        update_users_at_bar(obj)

    def save_related(self, request, form, formsets, change):
        super().save_related(request, form, formsets, change)
        from apps.bars.services.proximity import update_users_at_bar
        update_users_at_bar(form.instance)


@admin.register(BarStatus)
class BarStatusAdmin(admin.ModelAdmin):
    list_display = ("bar", "crowd_size", "wait_time", "last_updated")
    list_filter = ("crowd_size", "wait_time")


@admin.register(BarRating)
class BarRatingAdmin(admin.ModelAdmin):
    list_display = ("bar", "user", "rating", "timestamp")
    list_filter = ("rating",)


@admin.register(BarImage)
class BarImageAdmin(admin.ModelAdmin):
    list_display = ("bar", "caption", "uploaded_at")
    readonly_fields = ("uploaded_at",)


@admin.register(BarHours)
class BarHoursAdmin(admin.ModelAdmin):
    list_display = ("bar", "day", "open_time", "close_time", "is_closed")
    list_filter = ("day", "is_closed")
    search_fields = ("bar__name",)


@admin.register(BarVote)
class BarVoteAdmin(admin.ModelAdmin):
    list_display = ("bar", "user", "wait_time", "timestamp")
    list_filter = ("wait_time",)
    search_fields = ("bar__name", "user__username")


@admin.register(BarCrowdSize)
class BarCrowdSizeAdmin(admin.ModelAdmin):
    list_display = ("bar", "user", "crowd_size", "timestamp")
    list_filter = ("crowd_size",)
    search_fields = ("bar__name", "user__username")
