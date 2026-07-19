from abc import ABC, abstractmethod

from app.services.auth.models import AuthenticatedUser


class AuthProvider(ABC):
    @abstractmethod
    def verify_access_token(self, token: str) -> AuthenticatedUser:
        """Validate a token and return a provider-neutral user."""
