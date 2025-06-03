from collections import defaultdict
from apps.bars.models import BarVote, BarCrowdSize

def aggregate_bar_votes(bar_id):
    wait_votes = BarVote.objects.filter(bar_id=bar_id)
    crowd_votes = BarCrowdSize.objects.filter(bar_id=bar_id)

    # Initialize default return values
    result = {"crowd_size": None, "wait_time": None}
    
    # Process wait time votes if they exist
    if wait_votes.exists():
        wait_weights = defaultdict(int)
        wait_timestamps = defaultdict(list)
        
        for vote in wait_votes:
            weight = vote.user.vote_weight if hasattr(vote.user, 'vote_weight') else 1
            wait_weights[vote.wait_time] += weight
            wait_timestamps[vote.wait_time].append(vote.timestamp)
        
        # Find most popular wait time, breaking ties with most recent vote
        if wait_weights:
            result["wait_time"] = resolve_tie(wait_weights, wait_timestamps)
    
    # Process crowd size votes if they exist
    if crowd_votes.exists():
        crowd_weights = defaultdict(int)
        crowd_timestamps = defaultdict(list)
        
        for vote in crowd_votes:
            weight = vote.user.vote_weight if hasattr(vote.user, 'vote_weight') else 1
            crowd_weights[vote.crowd_size] += weight
            crowd_timestamps[vote.crowd_size].append(vote.timestamp)
        
        # Find most popular crowd size, breaking ties with most recent vote
        if crowd_weights:
            result["crowd_size"] = resolve_tie(crowd_weights, crowd_timestamps)
    
    return result

def resolve_tie(weight_dict, timestamp_dict):
    if not weight_dict:
        return None
        
    max_weight = max(weight_dict.values())
    tied_items = [key for key, weight in weight_dict.items() if weight == max_weight]

    if len(tied_items) == 1:
        return tied_items[0]

    # Break tie by most recent vote
    most_recent = None
    chosen = None
    for item in tied_items:
        latest_time = max(timestamp_dict[item])
        if not most_recent or latest_time > most_recent:
            most_recent = latest_time
            chosen = item
    return chosen
