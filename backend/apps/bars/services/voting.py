from collections import defaultdict
from apps.bars.models import BarVote

def aggregate_bar_votes(bar_id):
    votes = BarVote.objects.filter(bar_id=bar_id)

    if not votes.exists():
        return {"crowd_size": None, "wait_time": None}

    crowd_weights = defaultdict(int)
    wait_weights = defaultdict(int)
    crowd_timestamps = defaultdict(list)
    wait_timestamps = defaultdict(list)

    for vote in votes:
        weight = vote.user.vote_weight
        crowd_weights[vote.crowd_size] += weight
        wait_weights[vote.wait_time] += weight
        crowd_timestamps[vote.crowd_size].append(vote.timestamp)
        wait_timestamps[vote.wait_time].append(vote.timestamp)

    def resolve_tie(weight_dict, timestamp_dict):
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

    return {
        "crowd_size": resolve_tie(crowd_weights, crowd_timestamps),
        "wait_time": resolve_tie(wait_weights, wait_timestamps),
    }
