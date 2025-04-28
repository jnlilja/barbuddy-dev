from rest_framework import permissions

class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Allows users to edit/delete their own objects. Read-only for others.
    Superusers are always allowed.
    """
    def has_permission(self, request, view):
        # Allow all authenticated users to access the list view
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        if request.user and request.user.is_superuser:
            return True

        if request.method in permissions.SAFE_METHODS:
            return True

        return obj == request.user or getattr(obj, 'user', None) == request.user or getattr(obj, 'creator', None) == request.user
