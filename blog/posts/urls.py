from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('post/<int:pk>/', views.post, name='post'),
    path('edit-post/<int:pk>/', views.edit_post, name='edit_post'),
]