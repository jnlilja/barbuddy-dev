from django.contrib import admin
from .models import Bar, BarStatus, BarRating

# Register your models here.
# Django admin site, makes the models manageable through the admin interface ya feel me 
admin.site.register(Bar)
admin.site.register(BarStatus)
admin.site.register(BarRating)

