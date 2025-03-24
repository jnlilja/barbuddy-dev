from rest_framework import serializers
from apps.swipes.models import Swipe

class SwipeSerializer(serializers.ModelSerializer):
    swiper_username = serializers.CharField(source='swiper.username', read_only=True)
    swiped_on_username = serializers.CharField(source='swiped_on.username', read_only=True)

    class Meta:
        model = Swipe
        fields = ['swiper', 'swiper_username', 'swiped_on', 'swiped_on_username', 'status', 'timestamp']

    def validate(self, data):
        if data['swiper'] == data['swiped_on']:
            raise serializers.ValidationError("You cannot swipe on yourself.")
        return data