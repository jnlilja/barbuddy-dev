from rest_framework import viewsets, permissions, serializers, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework import generics
from django.utils import timezone
from datetime import timedelta

from django.contrib.auth import get_user_model
from .models import Bar, BarStatus, BarRating, BarVote, BarImage, BarHours, BarCrowdSize
from .serializers import (
    BarSerializer, BarStatusSerializer, BarRatingSerializer,
    BarVoteSerializer, BarImageSerializer, BarHoursSerializer, BarCrowdSizeSerializer
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
        queryset = Bar.objects.all().select_related('status').prefetch_related(
            'users_at_bar', 'images'
        )
        latitude = self.request.query_params.get('latitude')
        longitude = self.request.query_params.get('longitude')
        radius = self.request.query_params.get('radius', 5)
        if latitude and longitude:
            try:
                user_location = Point(float(longitude), float(latitude), srid=4326)
                queryset = queryset.annotate(
                    distance=Distance('location', user_location)
                ).filter(
                    location__distance_lte=(user_location, D(km=float(radius)))
                ).order_by('distance')
            except (ValueError, TypeError):
                print(f"Invalid location parameters: lat={latitude}, lon={longitude}")
        return queryset



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
    ViewSet for retrieving and managing the current aggregated status of bars.
    Each bar has at most one status record which represents current conditions.
    """
    serializer_class = BarStatusSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = BarStatus.objects.all()

    def get_queryset(self):
        queryset = super().get_queryset()
        bar_id = self.request.query_params.get('bar')
        if bar_id:
            queryset = queryset.filter(bar_id=bar_id)
            # Update the status from latest votes on each request
            self.update_status_from_votes(bar_id)
        return queryset
    
    def update_status_from_votes(self, bar_id):
        """Update status from votes whenever endpoint is called"""
        from apps.bars.services.voting import aggregate_bar_votes
        from django.utils import timezone
        from datetime import timedelta
        
        # Use recent votes (last hour)
        result = aggregate_bar_votes(bar_id, lookback_hours=1)
        if not result['crowd_size'] and not result['wait_time']:
            return  # No votes to aggregate
            
        try:
            bar = Bar.objects.get(id=bar_id)
            
            # Calculate recent vote counts
            recent_crowd_votes = bar.crowd_size_votes.filter(
                timestamp__gte=timezone.now() - timedelta(hours=1)
            ).count()
            
            recent_wait_votes = bar.wait_time_votes.filter(
                timestamp__gte=timezone.now() - timedelta(hours=1)
            ).count()
            
            status, created = BarStatus.objects.get_or_create(
                bar_id=bar_id,
                defaults={
                    'crowd_size': result['crowd_size'] or 'moderate',
                    'wait_time': result['wait_time'] or '<5 min',
                    'crowd_size_votes': recent_crowd_votes,
                    'wait_time_votes': recent_wait_votes
                }
            )
            
            if not created:
                # Update with latest aggregated values
                if result['crowd_size']:
                    status.crowd_size = result['crowd_size']
                if result['wait_time']:
                    status.wait_time = result['wait_time']
                status.crowd_size_votes = recent_crowd_votes
                status.wait_time_votes = recent_wait_votes
                status.save()
        except Bar.DoesNotExist:
            pass
    
    def retrieve(self, request, *args, **kwargs):
        # Update status before retrieving detail view
        instance = self.get_object()
        self.update_status_from_votes(instance.bar_id)
        
        # Refresh from database after update
        instance.refresh_from_db()
        
        serializer = self.get_serializer(instance)
        
        # Include vote counts
        bar = instance.bar
        response_data = serializer.data
        response_data.update({
            'wait_time_vote_count': bar.wait_time_votes.count(),
            'crowd_size_vote_count': bar.crowd_size_votes.count()
        })
        
        return Response(response_data)


class BarRatingViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing bar ratings.
    Allows users to create, update, and delete their own ratings.
    """
    serializer_class = BarRatingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        qs = BarRating.objects.all()
        bar_id = self.request.query_params.get('bar')
        if bar_id:
            qs = qs.filter(bar__id=bar_id)
        return qs
    
    def perform_create(self, serializer):
        # Check if user already rated this bar
        bar = serializer.validated_data['bar']
        existing_rating = BarRating.objects.filter(
            bar=bar,
            user=self.request.user
        ).first()
        
        if existing_rating:
            # Update existing rating instead of creating a new one
            existing_rating.rating = serializer.validated_data['rating']
            existing_rating.review = serializer.validated_data.get('review', '')
            existing_rating.save()
            return existing_rating
        else:
            # Create new rating
            return serializer.save(user=self.request.user)
    
    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        # Only allow users to update their own ratings
        if instance.user != request.user:
            return Response(
                {"error": "You can only update your own ratings."},
                status=status.HTTP_403_FORBIDDEN
            )
        return super().update(request, *args, **kwargs)
    
    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        # Only allow users to delete their own ratings
        if instance.user != request.user:
            return Response(
                {"error": "You can only delete your own ratings."},
                status=status.HTTP_403_FORBIDDEN
            )
        return super().destroy(request, *args, **kwargs)


class BarVoteViewSet(viewsets.ModelViewSet):
    """
    ViewSet for submitting votes on wait time.
    Enforces one vote per user per 5-minute window.
    """
    serializer_class = BarVoteSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        qs = BarVote.objects.all()
        bar_id = self.request.query_params.get('bar')
        if bar_id:
            qs = qs.filter(bar__id=bar_id)
        return qs

    def perform_create(self, serializer):
        ##### DELETING COOLDOWN FOR NOW #####
        serializer.save(user=self.request.user)


        # # prevent re-vote within 5 minutes
        # cutoff = timezone.now() - timedelta(minutes=5)
        # recent = BarVote.objects.filter(
        #     bar=serializer.validated_data['bar'],
        #     user=self.request.user,
        #     timestamp__gte=cutoff
        # ).first()
        # if recent:
        #     raise serializers.ValidationError(
        #         "You can only vote once every 5 minutes for this bar's wait time."
        #     )
        # serializer.save(user=self.request.user)


class BarCrowdSizeViewSet(viewsets.ModelViewSet):
    """
    ViewSet for submitting votes on crowd size.
    Enforces one vote per user per 5-minute window.
    """
    serializer_class = BarCrowdSizeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        qs = BarCrowdSize.objects.all()
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
        })

    def perform_create(self, serializer):

        #### DELETING COOLDOWN FOR NOW ####
        serializer.save(user=self.request.user)
        # # prevent re-vote within 5 minutes
        # cutoff = timezone.now() - timedelta(minutes=5)
        # recent = BarCrowdSize.objects.filter(
        #     bar=serializer.validated_data['bar'],
        #     user=self.request.user,
        #     timestamp__gte=cutoff
        # ).first()
        # if recent:
        #     raise serializers.ValidationError(
        #         "You can only vote once every 5 minutes for this bar's crowd size."
        #     )
        # serializer.save(user=self.request.user)

class BarImageViewSet(viewsets.ModelViewSet):
    """
    ViewSet for uploading, listing & deleting images for a bar.
    Supports both /api/bars/{bar_pk}/images/ and /api/bar-images/?bar={bar_id}
    """
    serializer_class = BarImageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Print debug information - see what's actually being received
        print(f"DEBUG: all kwargs={self.kwargs}")
        
        # In nested routes with NestedSimpleRouter and lookup='bar', 
        # the parameter is named 'bar' not 'bar_pk'
        bar_id = self.kwargs.get('bar')
        
        if bar_id:
            return BarImage.objects.filter(bar_id=bar_id)
        
        # Fallback to query parameter
        bar_id = self.request.query_params.get('bar')
        if bar_id:
            return BarImage.objects.filter(bar_id=bar_id)
            
        # Default fallback - all images (consider removing this)
        return BarImage.objects.all()

    def perform_create(self, serializer):
        # Handle creation from nested URL
        bar_pk = self.kwargs.get('bar_pk')
        if bar_pk:
            bar = Bar.objects.get(pk=bar_pk)
            serializer.save(bar=bar)
        else:
            # For non-nested URL, bar should be in the request data
            serializer.save()


class BarHoursViewSet(viewsets.ModelViewSet):
    authentication_classes = [FirebaseAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = BarHoursSerializer
    queryset = BarHours.objects.all()

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [permissions.IsAdminUser()]
        return [permissions.IsAuthenticated()]

    def get_queryset(self):
        bar_id = self.request.query_params.get('bar_id')
        if bar_id:
            return self.queryset.filter(bar_id=bar_id)
        return self.queryset


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


class BarImageListView(generics.ListAPIView):
    """View for retrieving all images for a specific bar by ID"""
    serializer_class = BarImageSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        bar_id = self.kwargs['bar_id']
        return BarImage.objects.filter(bar_id=bar_id)
