from collections import defaultdict
from apps.bars.models import BarVote, BarCrowdSize
from django.utils import timezone
from datetime import timedelta

def aggregate_bar_votes(bar_id, lookback_hours=1):
    """
    Aggregate votes for a bar using weighted averages instead of simple vote counting
    Only consider votes from the past hour (configurable)
    """
    # Get cutoff time for recent votes (default: 1 hour ago)
    cutoff_time = timezone.now() - timedelta(hours=lookback_hours)
    
    # Get only recent votes
    wait_votes = BarVote.objects.filter(
        bar_id=bar_id, 
        timestamp__gte=cutoff_time
    )
    
    crowd_votes = BarCrowdSize.objects.filter(
        bar_id=bar_id, 
        timestamp__gte=cutoff_time
    )

    # Initialize default return values
    result = {"crowd_size": None, "wait_time": None}
    
    # Process wait time votes if they exist
    if wait_votes.exists():
        # Map wait times to numeric values for weighted average
        wait_time_values = {
            '<5 min': 0,
            '5-10 min': 1,
            '10-20 min': 2,
            '20-30 min': 3,
            '>30 min': 4
        }
        
        # Calculate weighted average for wait time
        total_weight = 0
        weighted_sum = 0
        
        for vote in wait_votes:
            user_weight = vote.user.vote_weight
            wait_value = wait_time_values[vote.wait_time]
            weighted_sum += wait_value * user_weight
            total_weight += user_weight
        
        if total_weight > 0:
            avg_wait = weighted_sum / total_weight
            # Convert back to category based on closest value
            wait_mapping = {0: '<5 min', 1: '5-10 min', 2: '10-20 min', 3: '20-30 min', 4: '>30 min'}
            closest_value = min(wait_mapping.keys(), key=lambda x: abs(x - avg_wait))
            result["wait_time"] = wait_mapping[closest_value]
    
    # Process crowd size votes if they exist
    if crowd_votes.exists():
        # Map crowd sizes to numeric values for weighted average
        crowd_size_values = {
            'empty': 0,
            'low': 1,
            'moderate': 2,
            'busy': 3,
            'crowded': 4,
            'packed': 5
        }
        
        # Calculate weighted average for crowd size
        total_weight = 0
        weighted_sum = 0
        
        for vote in crowd_votes:
            user_weight = vote.user.vote_weight
            crowd_value = crowd_size_values[vote.crowd_size]
            weighted_sum += crowd_value * user_weight
            total_weight += user_weight
        
        if total_weight > 0:
            avg_crowd = weighted_sum / total_weight
            # Convert back to category based on closest value
            crowd_mapping = {0: 'empty', 1: 'low', 2: 'moderate', 3: 'busy', 4: 'crowded', 5: 'packed'}
            closest_value = min(crowd_mapping.keys(), key=lambda x: abs(x - avg_crowd))
            result["crowd_size"] = crowd_mapping[closest_value]
    
    return result
