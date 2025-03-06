from django.db import models

class Venue(models.Model):
    name = models.CharField(max_length=100)
    location = models.CharField(max_length=200)
    status = models.CharField(max_length=50, choices=[('open', 'Open'), ('closed', 'Closed')])
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.name

class Transaction(models.Model):
    venue = models.ForeignKey(Venue, on_delete=models.CASCADE, related_name='transactions')
    user_id = models.CharField(max_length=100)  # Or replace with ForeignKey to the User model
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.user_id} - {self.amount} at {self.venue.name}"

