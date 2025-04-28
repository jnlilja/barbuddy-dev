from rest_framework import viewsets, permissions, serializers, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from datetime import timedelta

from django.contrib.auth import get_user_model
from .models import Bar, BarStatus, BarRating, BarVote, BarImage, BarHours
from .serializers import (
    BarSerializer, BarStatusSerializer, BarRatingSerializer,
    BarVoteSerializer, BarImageSerializer, BarHoursSerializer
)
from apps.bars.services.voting import aggregate_bar_votes
from barbuddy_api.authentication import FirebaseAuthentication

from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D

User = get_user_model()


class BarViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing bars.
    Supports listing, creating, retrieving, updating, and deleting bars.
    """
    queryset = Bar.objects.all()
    serializer_class = BarSerializer

    def get_queryset(self):
        queryset = Bar.objects.all()
        
        # Get location parameters
        latitude = self.request.query_params.get('latitude')
        longitude = self.request.query_params.get('longitude')
        radius = self.request.query_params.get('radius', 5)  # Default 5km
        
        if latitude and longitude:
            try:
                user_location = Point(
                    float(longitude),  # x coordinate
                    float(latitude),   # y coordinate
                    srid=4326
                )
                # Annotate with distance and filter within radius
                queryset = queryset.annotate(
                    distance=Distance('location', user_location)
                ).filter(
                    location__distance_lte=(user_location, D(km=float(radius)))
                ).order_by('distance')
            except (ValueError, TypeError):
                pass
        
        return queryset

    @action(detail=True, methods=['get'], url_path='aggregated-vote')
    def aggregated_vote(self, request, pk=None):
        bar = self.get_object()
        return Response(bar.get_aggregated_vote_status())

    @action(detail=False, methods=['get'])
    def most_active(self, request):
        """Return the most active bars based on current user count"""
        limit = int(request.query_params.get('limit', 10))
        active_bars = Bar.get_most_active_bars(limit=limit)
        
        data = [{
            'id': bar.id,
            'name': bar.name,
            'user_count': bar.current_user_count,
            'activity_level': bar.get_activity_level(),
            'location': {
                'latitude': bar.location.y,
                'longitude': bar.location.x
            }
        } for bar in active_bars]
        
        return Response(data)


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

class BarHoursViewSet(viewsets.ModelViewSet):
    authentication_classes = [FirebaseAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = BarHoursSerializer
    queryset = BarHours.objects.all()

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy', 'bulk_update']:
            return [permissions.IsAdminUser()]
        return [permissions.IsAuthenticated()]

    def get_queryset(self):
        bar_id = self.request.query_params.get('bar_id')
        if bar_id:
            return self.queryset.filter(bar_id=bar_id)
        return self.queryset

    @action(detail=False, methods=['get'])
    def by_bar(self, request):
        bar_id = request.query_params.get('bar_id')
        if not bar_id:
            return Response(
                {"error": "bar_id parameter is required"},
                status=status.HTTP_400_BAD_REQUEST
            )
        hours = self.get_queryset().filter(bar_id=bar_id)
        serializer = self.get_serializer(hours, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['post'])
    def bulk_update(self, request):
        if not request.user.is_staff:
            return Response(
                {"error": "Only admin users can update bar hours"},
                status=status.HTTP_403_FORBIDDEN
            )
        bar_id = request.data.get('bar_id')
        if not bar_id:
            return Response(
                {"error": "bar_id is required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            bar = Bar.objects.get(id=bar_id)
        except Bar.DoesNotExist:
            return Response(
                {"error": "Bar not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        hours_data = request.data.get('hours', [])
        created_hours = []
        errors = []

        for hour_data in hours_data:
            hour_data['bar'] = bar_id
            serializer = self.get_serializer(data=hour_data)
            if serializer.is_valid():
                hour = serializer.save()
                created_hours.append(hour)
            else:
                errors.append(serializer.errors)

        if errors:
            return Response(
                {"errors": errors},
                status=status.HTTP_400_BAD_REQUEST
            )

        return Response(
            self.get_serializer(created_hours, many=True).data,
            status=status.HTTP_201_CREATED
        )
