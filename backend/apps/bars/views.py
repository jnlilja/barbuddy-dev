from rest_framework import viewsets, permissions, serializers
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from datetime import timedelta

from django.contrib.auth import get_user_model
from .models import Bar, BarStatus, BarRating, BarVote, BarImage
from .serializers import (
    BarSerializer, BarStatusSerializer, BarRatingSerializer,
    BarVoteSerializer, BarImageSerializer
)
from apps.bars.services.voting import aggregate_bar_votes

User = get_user_model()


class BarViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing bars.
    Supports listing, creating, retrieving, updating, and deleting bars.
    """
    queryset = Bar.objects.all()
    serializer_class = BarSerializer

    def get_queryset(self):
        # You can hook in location- or preference-based filtering here
        return Bar.objects.all()

    @action(detail=True, methods=['get'], url_path='aggregated-vote')
    def aggregated_vote(self, request, pk=None):
        bar = self.get_object()
        return Response(bar.get_aggregated_vote_status())


class BarStatusViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing bar status updates.
    """
    queryset = BarStatus.objects.all()
    serializer_class = BarStatusSerializer


class BarRatingViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing bar ratings.
    """
    serializer_class = BarRatingSerializer

    def get_queryset(self):
        qs = BarRating.objects.all()
        bar_id = self.request.query_params.get('bar')
        if bar_id:
            qs = qs.filter(bar__id=bar_id)
        return qs


class BarVoteViewSet(viewsets.ModelViewSet):
    """
    ViewSet for submitting votes on crowd size & wait time.
    Enforces one vote per user per 24h window.
    """
    serializer_class = BarVoteSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        qs = BarVote.objects.all()
        bar_id = self.request.query_params.get('bar')
        if bar_id:
            qs = qs.filter(bar__id=bar_id)
        return qs

    @action(detail=False, methods=['get'], url_path='summary')
    def vote_summary(self, request):
        bar_id = request.query_params.get("bar")
        if not bar_id:
            return Response({"error": "Bar ID is required."}, status=400)
        summary = aggregate_bar_votes(bar_id)
        return Response({
            "bar": bar_id,
            "aggregated_crowd_size": summary["crowd_size"],
            "aggregated_wait_time": summary["wait_time"],
        })

    def perform_create(self, serializer):
        # prevent re-vote within 24h
        cutoff = timezone.now() - timedelta(hours=24)
        recent = BarVote.objects.filter(
            bar=serializer.validated_data['bar'],
            user=self.request.user,
            timestamp__gte=cutoff
        ).first()
        if recent:
            raise serializers.ValidationError(
                "You can only vote once every 24 hours for this bar."
            )
        serializer.save(user=self.request.user)


class BarImageViewSet(viewsets.ModelViewSet):
    """
    ViewSet for uploading, listing & deleting images for a bar.
    Nested by bar_pk in the URL.
    """
    serializer_class = BarImageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # If you register this as /api/bars/{bar_pk}/images/
        bar_pk = self.kwargs.get('bar_pk')
        return BarImage.objects.filter(bar__pk=bar_pk)

    def perform_create(self, serializer):
        bar_pk = self.kwargs.get('bar_pk')
        bar = Bar.objects.get(pk=bar_pk)
        serializer.save(bar=bar)
