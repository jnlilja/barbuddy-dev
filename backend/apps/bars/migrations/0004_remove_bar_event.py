# Generated by Django 5.1.7 on 2025-03-17 12:49

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('bars', '0003_alter_bar_users_at_bar_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='bar',
            name='event',
        ),
    ]
