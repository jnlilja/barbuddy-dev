from rest_framework import permissions

class IsSenderOrReceiver(permissions.BasePermission):
    """
    Allows access only to sender or receiver of the message.
    Superusers always have access.
    """
    def has_object_permission(self, request, view, obj):
        if request.user and request.user.is_superuser:
            return True

        return obj.sender == request.user or obj.receiver == request.user


class IsGroupMember(permissions.BasePermission):
    """
    Allows access to group chat only for members.
    Superusers are always allowed.
    """
    def has_object_permission(self, request, view, obj):
        if request.user and request.user.is_superuser:
            return True

        return request.user in obj.users.all()