

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('bars', '0012_barhours'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='BarCrowdSize',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('crowd_size', models.CharField(choices=[('empty', 'Empty'), ('low', 'Low'), ('moderate', 'Moderate'), ('busy', 'Busy'), ('crowded', 'Crowded'), ('packed', 'Packed')], max_length=50)),
                ('timestamp', models.DateTimeField(auto_now_add=True)),
            ],
        ),
        migrations.RemoveConstraint(
            model_name='barvote',
            name='unique_vote_per_bar_user',
        ),
        migrations.RemoveField(
            model_name='barvote',
            name='crowd_size',
        ),
        migrations.AlterField(
            model_name='barvote',
            name='bar',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='wait_time_votes', to='bars.bar'),
        ),
        migrations.AlterField(
            model_name='barvote',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='wait_time_votes', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddConstraint(
            model_name='barvote',
            constraint=models.UniqueConstraint(fields=('bar', 'user'), name='unique_wait_time_vote_per_bar_user'),
        ),
        migrations.AddField(
            model_name='barcrowdsize',
            name='bar',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='crowd_size_votes', to='bars.bar'),
        ),
        migrations.AddField(
            model_name='barcrowdsize',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='crowd_size_votes', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddIndex(
            model_name='barcrowdsize',
            index=models.Index(fields=['bar'], name='bars_barcro_bar_id_72931d_idx'),
        ),
        migrations.AddIndex(
            model_name='barcrowdsize',
            index=models.Index(fields=['user'], name='bars_barcro_user_id_6c2272_idx'),
        ),
        migrations.AddIndex(
            model_name='barcrowdsize',
            index=models.Index(fields=['timestamp'], name='bars_barcro_timesta_19db3b_idx'),
        ),
        migrations.AddConstraint(
            model_name='barcrowdsize',
            constraint=models.UniqueConstraint(fields=('bar', 'user'), name='unique_crowd_size_vote_per_bar_user'),
        ),
    ]
