from apps.bars.models import Bar, BarStatus
from apps.bars.services.voting import aggregate_bar_votes

def update_all_bar_statuses():
    """
    Periodic task to update all bar statuses based on recent votes
    Run this every few minutes via cron or Celery
    """
    for bar in Bar.objects.all():
        result = aggregate_bar_votes(bar.id)
        
        # Skip bars with no votes
        if not result['crowd_size'] and not result['wait_time']:
            continue
            
        status, created = BarStatus.objects.get_or_create(
            bar=bar,
            defaults={
                'crowd_size': result['crowd_size'] or 'moderate',
                'wait_time': result['wait_time'] or '<5 min',
                'crowd_size_votes': bar.crowd_size_votes.count(),
                'wait_time_votes': bar.wait_time_votes.count()
            }
        )
        
        if not created:
            # Update existing values if we have data
            if result['crowd_size']:
                status.crowd_size = result['crowd_size']
            if result['wait_time']: 
                status.wait_time = result['wait_time']
            status.crowd_size_votes = bar.crowd_size_votes.count()
            status.wait_time_votes = bar.wait_time_votes.count()
            status.save()