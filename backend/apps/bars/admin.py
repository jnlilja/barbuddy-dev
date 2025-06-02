# apps/bars/admin.py

from django import forms
from django.contrib import admin
from django.contrib.gis.geos import Point
from django.core.exceptions import ValidationError
from django.contrib.gis.measure import D
from django.contrib.gis.db.models.functions import Distance

from .models import Bar, BarStatus, BarRating, BarImage, BarHours, BarVote, BarCrowdSize
from apps.users.models import User

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
    list_display   = ("name", "address", "average_price")
    search_fields  = ("name", "address")
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
            # base queryset = only users with a location
            qs = User.objects.exclude(location__isnull=True)
            # if we’re editing an existing Bar, grab its instance so we can filter by distance
            object_id = request.resolver_match.kwargs.get('object_id')
            if object_id:
                try:
                    bar = self.model.objects.get(pk=object_id)
                except Bar.DoesNotExist:
                    bar = None
                else:
                    # only users within 50m of bar.location
                    qs = qs.annotate(
                        dist=Distance('location', bar.location)
                    ).filter(dist__lte=D(m=50))
            kwargs['queryset'] = qs
        return super().formfield_for_manytomany(db_field, request, **kwargs)

    def save_model(self, request, obj, form, change):
        # this saves obj.location (and fires the model.save hook)
        super().save_model(request, obj, form, change)
        from apps.bars.services.proximity import update_users_at_bar
        update_users_at_bar(obj)

    def save_related(self, request, form, formsets, change):
        # admin now writes the users_at_bar M2M
        super().save_related(request, form, formsets, change)
        from apps.bars.services.proximity import update_users_at_bar
        update_users_at_bar(form.instance)


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
