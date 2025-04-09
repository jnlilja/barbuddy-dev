from rest_framework import serializers
from .models import Bar, BarStatus
from django.contrib.gis.geos import Point
from django.db.models import Avg
from django.contrib.auth import get_user_model
from .models import BarRating


User = get_user_model()

class BarSerializer(serializers.ModelSerializer):
    location = serializers.SerializerMethodField()

    #BarBuddy APP users that are currently at the bar
    users_at_bar = serializers.PrimaryKeyRelatedField(many=True, queryset=User.objects.all(), required=False)
    current_status = serializers.SerializerMethodField()
    average_rating = serializers.SerializerMethodField()

    class Meta:
        model = Bar
        #removed music_genre
        fields = ['id', 'name', 'address', 'average_price',
                  'location', 'users_at_bar', 'current_status', 'average_rating']

    def get_location(self, obj):
        return {"latitude": obj.location.y, "longitude": obj.location.x} if obj.location else None

    def get_current_status(self, obj):
        status = obj.get_latest_status()
        return status if status else None

    
    #Moving this to BarRatingSerializer
    def get_average_rating(self, obj):
        """Optimize rating retrieval using aggregate()."""
        average = obj.ratings.aggregate(Avg("rating"))["rating__avg"]
        return round(average, 2) if average else None 
    

    #MOST LIKELY NOT NEEDED, CHECK WITH TEAM ON THIS 
    def validate_users_at_bar(self, value):
        return value

    def to_internal_value(self, data):
        """Convert latitude/longitude dictionary into a GIS Point object."""
        internal_value = super().to_internal_value(data)

        if "location" in data and isinstance(data["location"], dict):
            try:
                lat = float(data["location"].get("latitude"))
                lon = float(data["location"].get("longitude"))
                if lat is None or lon is None:
                    raise ValueError()
                # Store the Point object in internal_value
                internal_value["location"] = Point(lon, lat, srid=4326)
            except (TypeError, ValueError):
                raise serializers.ValidationError({"location": "Latitude and longitude must be valid numbers."})

        return internal_value

    def update(self, instance, validated_data):
        # Handle users_at_bar separately if present
        users_data = validated_data.pop('users_at_bar', None)

        # Update all other fields, including location
        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        # Update many-to-many relationship if users_data is provided
        if users_data is not None:
            instance.users_at_bar.set(users_data)

        instance.save()
        return instance


class BarStatusSerializer(serializers.ModelSerializer):
    bar = serializers.PrimaryKeyRelatedField(queryset=Bar.objects.all())

    class Meta:
        model = BarStatus
        fields = "__all__"

#added a serializer for BarRating
class BarRatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = BarRating
        fields = ['id', 'bar', 'user', 'rating', 'review', 'timestamp']
