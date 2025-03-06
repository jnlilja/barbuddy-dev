# from django.http import JsonResponse
# from django.views.decorators.csrf import csrf_exempt
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Venue, Transaction
from .serializers import VenueSerializer, TransactionSerializer

# def venue_list(request):
#     venues = Venue.objects.all()
#     return JsonResponse({'venues': list(venues.values())})

# @csrf_exempt
# def create_transaction(request):
#     if request.method == "POST":
#         data = request.json()
#         venue = Venue.objects.get(id=data['venue_id'])
#         transaction = Transaction.objects.create(
#             venue=venue,
#             user_id=data['user_id'],
#             amount=data['amount']
#         )
#         return JsonResponse({'transaction_id': transaction.id})

class VenueListView(APIView):
    """
    API View to get all venues.
    """
    def get(self, request):
        venues = Venue.objects.all()
        serializer = VenueSerializer(venues, many=True)
        return Response(serializer.data)

class TransactionListView(APIView):
    """
    API View to get all transactions.
    """
    def get(self, request):
        transactions = Transaction.objects.all()
        serializer = TransactionSerializer(transactions, many=True)
        return Response(serializer.data)

# class VenueViewSet(viewsets.ModelViewSet):
#     queryset = Venue.objects.all()
#     serializer_class = VenueSerializer

# class TransactionViewSet(viewsets.ModelViewSet):
#     queryset = Transaction.objects.all()
#     serializer_class = TransactionSerializer

def custom_404(request, exception):
    return JsonResponse({'error': 'Page not found'}, status=404)

def custom_500(request):
    return JsonResponse({'error': 'Server error'}, status=500)
