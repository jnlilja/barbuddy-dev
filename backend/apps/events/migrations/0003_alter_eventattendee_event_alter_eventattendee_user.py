# Generated by Django 5.1.7 on 2025-03-15 05:01

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('events', '0002_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AlterField(
            model_name='eventattendee',
            name='event',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='attendee_list', to='events.event'),
        ),
        migrations.AlterField(
            model_name='eventattendee',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='event_participation', to=settings.AUTH_USER_MODEL),
        ),
    ]
