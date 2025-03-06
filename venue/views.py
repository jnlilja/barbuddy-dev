from django.http import JsonResponse
from .models import Venue, Transaction
from django.views.decorators.csrf import csrf_exempt

def venue_list(request):
    venues = Venue.objects.all()
    return JsonResponse({'venues': list(venues.values())})

@csrf_exempt
def create_transaction(request):
    if request.method == "POST":
        data = request.json()
        venue = Venue.objects.get(id=data['venue_id'])
        transaction = Transaction.objects.create(
            venue=venue,
            user_id=data['user_id'],
            amount=data['amount']
        )
        return JsonResponse({'transaction_id': transaction.id})


def custom_404(request, exception):
    return JsonResponse({'error': 'Resource not found'}, status=404)

def custom_500(request):
    return JsonResponse({'error': 'Server error'}, status=500)
