from oauth2_provider.views import ProtectedResourceView


class UserProfileView(ProtectedResourceView):
    def get(self, request, *args, **kwargs):
        from django.http import JsonResponse

        return JsonResponse(
            dict(
                id=request.user.id,
                username=request.user.get_username(),
                email=request.user.email,
                fullname=request.user.get_full_name(),
                first_name=request.user.first_name,
                last_name=request.user.last_name,
            )
        )
