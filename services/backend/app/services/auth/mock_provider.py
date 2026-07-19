from app.services.auth.exceptions import InvalidAccessTokenError
from app.services.auth.models import AuthenticatedUser
from app.services.auth.provider import AuthProvider


class MockAuthProvider(AuthProvider):
    """Deterministic provider used locally and in CI without Supabase calls."""

    _USERS = {
        "mock-valid-token": ("00000000-0000-0000-0000-000000000001", "farmer@agrivito.test"),
        "mock-user-a": ("00000000-0000-0000-0000-00000000000a", "a@agrivito.test"),
        "mock-user-b": ("00000000-0000-0000-0000-00000000000b", "b@agrivito.test"),
    }

    def verify_access_token(self, token: str) -> AuthenticatedUser:
        identity = self._USERS.get(token)
        if identity is None:
            raise InvalidAccessTokenError()
        return AuthenticatedUser(
            id=identity[0],
            email=identity[1],
            roles=("authenticated",),
            provider="mock",
        )
