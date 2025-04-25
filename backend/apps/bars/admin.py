# apps/bars/admin.py

from django import forms
from django.contrib import admin
from django.contrib.gis.geos import Point
from django.core.exceptions import ValidationError

from .models import Bar, BarStatus, BarRating, BarImage, BarHours

# Try to pick up the GeoDjango map widget; if it isn't installed, fall back:
try:
    from django.contrib.gis.admin import OSMGeoAdmin
    GeoAdminBase = OSMGeoAdmin
except ImportError:
    GeoAdminBase = admin.ModelAdmin


class BarAdminForm(forms.ModelForm):
    latitude = forms.FloatField(
        label="Latitude",
        required=True,  # Make required since location is required
        help_text="Decimal coordinates (e.g. 32.7157)"
    )
    longitude = forms.FloatField(
        label="Longitude",
        required=True,  # Make required since location is required
        help_text="Decimal coordinates (e.g. -117.1611)"
    )

    class Meta:
        model = Bar
        fields = (
            "name", "address", "average_price",
            "latitude", "longitude",
            "users_at_bar",
        )
        # Exclude the location field from the form
        exclude = ('location',)

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
            
        # Create Point object for the model's location field
        cleaned_data["location"] = Point(lon, lat, srid=4326)
        return cleaned_data


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
                "fields": ("image", "caption"),
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
    list_display = ("bar", "caption", "uploaded_at")
    readonly_fields = ("uploaded_at",)

@admin.register(BarHours)
class BarHoursAdmin(admin.ModelAdmin):
    list_display = ("bar", "day", "open_time", "close_time", "is_closed")
    list_filter = ("day", "is_closed")
    search_fields = ("bar__name",)
