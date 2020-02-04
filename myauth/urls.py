from django.contrib import admin
from django.urls import path, re_path, include

from .views import UserProfileView

urlpatterns = [
    path('admin/', admin.site.urls),
]

urlpatterns += [
    re_path(
        r'^o/',
        include('oauth2_provider.urls', namespace='oauth2_provider')
    ),
]

urlpatterns += [
    re_path(r'^api/user-profile/', UserProfileView.as_view()),
]
