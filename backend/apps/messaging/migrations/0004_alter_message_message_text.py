# Generated by Django 5.1.7 on 2025-03-17 12:49

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('messaging', '0003_groupchat_creator_groupchat_name'),
    ]

    operations = [
        migrations.AlterField(
            model_name='message',
            name='message_text',
            field=models.TextField(max_length=5000),
        ),
    ]
