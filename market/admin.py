from django.contrib import admin
from .models import Farmer, Crop, MarketPrice


class FarmerAdmin(admin.ModelAdmin):
    list_display = ('id', 'name')

class MarketPriceAdmin(admin.ModelAdmin):
    exclude = ('date_created', )
    list_display = ('crop', 'price', 'location')

admin.site.register(Farmer, FarmerAdmin)
admin.site.register(Crop)
admin.site.register(MarketPrice, MarketPriceAdmin)
