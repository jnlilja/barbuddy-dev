# apps/bars/admin.py

from django import forms
from django.contrib import admin
from django.contrib.gis.geos import Point
from django.core.exceptions import ValidationError

from .models import Bar, BarStatus, BarRating, BarImage

# Try to pick up the GeoDjango map widget; if it isn't installed, fall back:
try:
    from django.contrib.gis.admin import OSMGeoAdmin
    GeoAdminBase = OSMGeoAdmin
except ImportError:
    GeoAdminBase = admin.ModelAdmin


class BarAdminForm(forms.ModelForm):
    latitude = forms.FloatField(
        label="Latitude",
        required=True,
        help_text="Decimal coordinates (e.g. 40.7128)"
    )
    longitude = forms.FloatField(
        label="Longitude",
        required=True,
        help_text="Decimal coordinates (e.g. -74.0060)"
    )

    class Meta:
        model = Bar
        fields = (
            "name", "address", "average_price",
            "latitude", "longitude",
            "users_at_bar",
        )

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if self.instance and self.instance.location:
            self.fields["latitude"].initial = self.instance.location.y
            self.fields["longitude"].initial = self.instance.location.x

    def clean(self):
        cleaned_data = super().clean()
        lat = cleaned_data.get("latitude")
        lon = cleaned_data.get("longitude")
        
        if lat is None or lon is None:
            raise ValidationError("Both latitude and longitude are required")
            
        # Create Point object and add it to cleaned_data
        cleaned_data["location"] = Point(lon, lat, srid=4326)
        return cleaned_data

    def save(self, commit=True):
        instance = super().save(commit=False)
        instance.location = self.cleaned_data["location"]
        if commit:
            instance.save()
        return instance


@admin.register(Bar)
class BarAdmin(GeoAdminBase):
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
                "readonly_fields": ("uploaded_at",),
            },
        ),
    ]

@admin.register(BarStatus)
class BarStatusAdmin(admin.ModelAdmin):
    list_display = ("bar", "crowd_size", "wait_time", "last_updated")
    list_filter  = ("crowd_size", "wait_time")

@admin.register(BarRating)
class BarRatingAdmin(admin.ModelAdmin):
    list_display = ("bar", "user", "rating", "timestamp")
    list_filter  = ("rating",)

@admin.register(BarImage)
class BarImageAdmin(admin.ModelAdmin):
    list_display    = ("bar", "caption", "uploaded_at")
    readonly_fields = ("uploaded_at",)
