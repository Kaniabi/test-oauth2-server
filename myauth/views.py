from oauth2_provider.views import ProtectedResourceView


class UserProfileView(ProtectedResourceView):

    def get(self, request, *args, **kwargs):
        from django.http import JsonResponse
        return JsonResponse(
            dict(
                uid=request.user.id,
                username=request.user.username,
                email=request.user.email,
            )
        )
