from django.http import HttpResponse, Http404
from django.shortcuts import render, get_object_or_404
from .models import MarketPrice

# Create your views here.
def index(request):
    prices = MarketPrice.objects.all() # select * from market_marketprice
    return render(request, 'market/index.html', {'MarketPrice':prices})

def detail(request, crop_id):
    crop_detail = get_object_or_404(MarketPrice, id = crop_id)
    return render(request, 'market/detail.html', {'crop_details':crop_detail})
