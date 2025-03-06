from django.db import models

class Venue(models.Model):
    name = models.CharField(max_length=255)
    location = models.CharField(max_length=255)
    wait_time = models.CharField(max_length=50)
    crowd_size = models.CharField(max_length=50, choices=[('empty', 'Empty'), ('low', 'Low'), ('moderate', 'Moderate'), ('busy', 'Busy'), ('crowded', 'Crowded'), ('packed', 'Packed')])
    status = models.CharField(max_length=50, choices=[('open', 'Open'), ('closed', 'Closed')])
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.name

class Transaction(models.Model):
    user = models.ForeignKey('auth.User', on_delete=models.CASCADE)
    venue = models.ForeignKey(Venue, on_delete=models.CASCADE, related_name='transactions')
    action_type = models.CharField(max_length=100) # Example: swipe, message, etc.
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.username} - {self.action_type} at {self.venue.name}"

