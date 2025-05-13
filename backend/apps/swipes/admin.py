from django.contrib import admin
from .models import Swipe

@admin.register(Swipe)
class SwipeAdmin(admin.ModelAdmin):
    list_display = ('id', 'swiper', 'swiped_on', 'status', 'timestamp')
    list_filter = ('status', 'timestamp')
    search_fields = ('swiper__username', 'swiped_on__username', 'swiper__email', 'swiped_on__email')
    raw_id_fields = ('swiper', 'swiped_on')
    date_hierarchy = 'timestamp'
    list_per_page = 25
    
    fieldsets = (
        ('Swipe Information', {
            'fields': ('swiper', 'swiped_on', 'status')
        }),
        ('Additional Information', {
            'fields': ('timestamp',)
        }),
    )
    readonly_fields = ('timestamp',)
    
    def save_model(self, request, obj, form, change):
        """
        Custom save to ensure match creation happens as it would in the model's save method.
        This ensures admin-created swipes trigger matches correctly.
        """
        super().save_model(request, obj, form, change)
        
        # Display a helpful message after creating a "like" swipe
        if obj.status == 'like':
            # Check if this created a match
            from apps.matches.models import Match
            user1, user2 = sorted([obj.swiper, obj.swiped_on], key=lambda u: u.id)
            match_exists = Match.objects.filter(user1=user1, user2=user2).exists()
            
            if match_exists:
                self.message_user(
                    request, 
                    f"A match was created between {obj.swiper.username} and {obj.swiped_on.username}!"
                )
            else:
                self.message_user(
                    request,
                    f"Swipe recorded, but no match created yet. Waiting for {obj.swiped_on.username} to like {obj.swiper.username}."
                )