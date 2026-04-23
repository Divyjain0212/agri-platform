from django.db import models
from django.utils import timezone

class Farmer(models.Model):
    name = models.CharField(max_length=100)
    location = models.CharField(max_length=100)
    phone_no = models.CharField(max_length=15)
    def __str__(self):
        return self.name

class Crop(models.Model):
    name = models.CharField(max_length=100)
    def __str__(self):
        return self.name

class MarketPrice(models.Model):
    crop = models.ForeignKey(Crop,on_delete=models.CASCADE)
    price = models.FloatField()
    location = models.CharField(max_length=100)
    date_created = models.DateTimeField(default=timezone.now)