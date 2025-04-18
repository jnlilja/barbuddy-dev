from django.contrib import admin
from .models import Event

#admin panel for events 
@admin.register(Event)
class EventAdmin(admin.ModelAdmin):
    list_display = ('event_name', 'bar', 'event_time', 'day_of_week', 'category')
    list_filter = ('day_of_week', 'category', 'bar')
    search_fields = ('event_name', 'bar__name')
