from django.db import models
from tastypie import fields
from tastypie.resources import ModelResource
from market.models import MarketPrice

# Create your models here.
class MarketResource(ModelResource):
    crop = fields.CharField(attribute='crop__name')
    class Meta:
        queryset = MarketPrice.objects.all()
        resource_name = "market_price"
        excludes = ["date_created"]