from django.contrib.auth import get_user_model
from django.core.management import BaseCommand
from django.urls import reverse
from django.conf import settings
from oauth2_provider.models import Application


class Command(BaseCommand):
    """Database initialization command."""

    def create_admin_user(self):
        user_cls = get_user_model()
        user = user_cls.objects.get_or_create(
            username=settings.TEST_USERNAME,
            email=settings.TEST_EMAIL,
            is_superuser=True,
            is_staff=True,
            is_active=True,
        )[0]
        user.set_password(settings.TEST_PASSWORD)
        user.save()
        return user

    @staticmethod
    def create_app():
        result = Application.objects.get(client_id=settings.TEST_CLIENT_ID)
        if result is None:
            result = Application.objects.get_or_create(
                client_id=settings.TEST_CLIENT_ID,
                name=settings.TEST_CLIENT_NAME,
                client_secret=settings.TEST_CLIENT_SECRET,
                redirect_uris=settings.TEST_REDIRECT_URIS,
                client_type=Application.CLIENT_CONFIDENTIAL,
                authorization_grant_type=Application.GRANT_AUTHORIZATION_CODE,
            )[0]
        else:
            result.name = settings.TEST_CLIENT_NAME
            result.client_secret = settings.TEST_CLIENT_SECRET
            result.redirect_uris = settings.TEST_REDIRECT_URIS
            result.client_type = Application.CLIENT_CONFIDENTIAL
            result.authorization_grant_type = Application.GRANT_AUTHORIZATION_CODE
            result.save()
        return result

    def print_hello(self, user, app: Application):
        separator = '-' * 79
        host = 'http://127.0.0.1:8880'
        message = (
            f'\n'
            f'{separator}\n'
            f'\n'
            f'OAuth 2.0 test server initialized.\n'
            f'\n'
            f'Admin UI URL:       {host}/admin\n'
            f'Username:           {settings.TEST_USERNAME}\n'
            f'Password:           {settings.TEST_PASSWORD}\n'
            f'\n'
            f'Application Credentials:\n'
            f'Client ID:          {app.client_id}\n'
            f'Client Secret:      {app.client_secret}\n'
            f'\n'
            f'OAuth 2.0 endpoints:\n'
            f'Authorize URL:      {host}{reverse("oauth2_provider:authorize")}\n'
            f'Token URL:          {host}{reverse("oauth2_provider:token")}\n'
            f'Revoke Token URL:   {host}{reverse("oauth2_provider:revoke-token")}\n'
            f'Introspect URL:     {host}{reverse("oauth2_provider:introspect")}\n'
            f'\n'
            f'Before the application can be used, you need to go to the '
            f'admin interface and configure whitelisted redirect URIs.'
            f'\n'
            f'{separator}\n'
            f'\n'
        )
        self.stdout.write(message)

    def handle(self, *args, **options):
        user = self.create_admin_user()
        app = self.create_app()
        self.print_hello(user=user, app=app)
