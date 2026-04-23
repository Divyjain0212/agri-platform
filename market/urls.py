from django.urls import path
from . import views

app_name = "market"

urlpatterns = [
    path('', views.index, name = 'index'),
    path('<int:crop_id>', views.detail, name = 'detail')
]