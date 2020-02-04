from django.contrib import admin
from django.urls import include, path, re_path

from .views import UserProfileView

# Admin interface.
urlpatterns = [
    path("admin/", admin.site.urls),
]

# Endpoints for oauth2 authentication.
urlpatterns += [
    re_path(r"^o/", include("oauth2_provider.urls", namespace="oauth2_provider")),
]

# User-profile API.
# * This api is used by oauth2 client to obtain details about the authenticated
#   user.
urlpatterns += [
    re_path(r"^api/user-profile/", UserProfileView.as_view()),
]
