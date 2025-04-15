from rest_framework import viewsets
from django.contrib.auth import get_user_model
from .serializers import BarSerializer, BarStatusSerializer, BarRatingSerializer
from .models import Bar, BarStatus, BarRating
from .models import BarVote
from .serializers import BarVoteSerializer
from rest_framework import permissions
from rest_framework import serializers
from rest_framework.decorators import action
from rest_framework.response import Response
from apps.bars.services.voting import aggregate_bar_votes
from django.utils import timezone
from datetime import timedelta

User = get_user_model()

class BarViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing bars.
    Supports listing, creating, retrieving, updating, and deleting bars.
    """
    queryset = Bar.objects.all()
    serializer_class = BarSerializer

    def get_queryset(self):
        """
        Optionally filter bars based on user location or preferences.
        """
        return Bar.objects.all()
    
    @action(detail=True, methods=['get'], url_path='aggregated-vote')
    def aggregated_vote(self, request, pk=None):
        bar = self.get_object()
        data = bar.get_aggregated_vote_status()
        return Response(data)
    
    
class BarStatusViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing bar status updates.
    """
    queryset = BarStatus.objects.all()
    serializer_class = BarStatusSerializer

#bars rating

class BarRatingViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing bar ratings.
    Supports optional filtering by bar.
    """
    serializer_class = BarRatingSerializer

    def get_queryset(self):
        queryset = BarRating.objects.all()
        bar_id = self.request.query_params.get('bar')
        if bar_id:
            queryset = queryset.filter(bar__id=bar_id)
        return queryset
        


class BarVoteViewSet(viewsets.ModelViewSet):
    """
    ViewSet for submitting votes on bar crowd size and wait time.
    """
    serializer_class = BarVoteSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = BarVote.objects.all()
        bar_id = self.request.query_params.get('bar')
        if bar_id:
            queryset = queryset.filter(bar__id=bar_id)
        return queryset



    @action(detail=False, methods=['get'], url_path='summary')
    def vote_summary(self, request):
        bar_id = request.query_params.get("bar")
        if not bar_id:
            return Response({"error": "Bar ID is required."}, status=400)

        summary = aggregate_bar_votes(bar_id)
        return Response({
            "bar": bar_id,
            "aggregated_crowd_size": summary["crowd_size"],
            "aggregated_wait_time": summary["wait_time"]
        })
    
    def perform_create(self, serializer):
        time_threshold = timezone.now() - timedelta(hours=24)
        recent_vote = BarVote.objects.filter(
            bar=serializer.validated_data['bar'],
            user=self.request.user,
            timestamp__gte=time_threshold  # make sure this matches your model's timestamp field
        ).first()

        if recent_vote:
            raise serializers.ValidationError("You can only vote once every 24 hours for this bar.")

        serializer.save(user=self.request.user)

    
