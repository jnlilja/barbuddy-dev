from django.contrib import admin
from .models import Event

#admin panel for events 
@admin.register(Event)
class EventAdmin(admin.ModelAdmin):
    list_display = ('event_name', 'bar', 'event_time', 'created_at')
    search_fields = ('event_name', 'bar__name')
    list_filter = ('bar', 'event_time')
    ordering = ('-event_time',)
