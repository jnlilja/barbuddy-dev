from django.contrib import admin
from .models import Match
from apps.users.models import User

@admin.register(Match)
class MatchAdmin(admin.ModelAdmin):
    list_display = ('id', 'user1', 'user2', 'status', 'created_at', 'disconnected_by')
    list_filter = ('status', 'created_at')
    search_fields = ('user1__username', 'user2__username', 'user1__email', 'user2__email')
    # Remove raw_id_fields to use the standard select widget instead
    # raw_id_fields = ('user1', 'user2', 'disconnected_by')
    date_hierarchy = 'created_at'
    list_per_page = 25
    
    fieldsets = (
        ('Match Information', {
            'fields': ('user1', 'user2', 'status')
        }),
        ('Additional Information', {
            'fields': ('disconnected_by', 'created_at')
        }),
    )
    readonly_fields = ('created_at',)
    
    def get_readonly_fields(self, request, obj=None):
        # Make disconnected_by read-only if status isn't disconnected
        if obj and obj.status != 'disconnected':
            return self.readonly_fields + ('disconnected_by',)
        return self.readonly_fields
    
    def formfield_for_foreignkey(self, db_field, request, **kwargs):
        # For new objects, provide all users in the dropdown
        if db_field.name in ["user1", "user2"]:
            kwargs["queryset"] = User.objects.all().order_by('username')
        
        # For existing objects, limit disconnected_by choices to only user1 and user2
        if db_field.name == "disconnected_by" and request.resolver_match.kwargs.get('object_id'):
            match_id = request.resolver_match.kwargs.get('object_id')
            try:
                match = Match.objects.get(id=match_id)
                kwargs["queryset"] = User.objects.filter(
                    id__in=[match.user1_id, match.user2_id]
                )
            except Match.DoesNotExist:
                pass
        return super().formfield_for_foreignkey(db_field, request, **kwargs)