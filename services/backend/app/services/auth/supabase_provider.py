from __future__ import annotations

from typing import Any

import jwt
from jwt import PyJWKClient
from jwt.exceptions import InvalidTokenError, PyJWKClientError

from app.core.config import Settings
from app.services.auth.exceptions import (
    AuthConfigurationError,
    AuthProviderUnavailableError,
    InvalidAccessTokenError,
)
from app.services.auth.models import AuthenticatedUser
from app.services.auth.provider import AuthProvider


class SupabaseAuthProvider(AuthProvider):
    def __init__(
        self,
        settings: Settings,
        *,
        jwks_client: PyJWKClient | None = None,
    ) -> None:
        self._settings = settings
        self._jwks_client = jwks_client
        if not settings.auth_issuer or not settings.auth_audience:
            raise AuthConfigurationError()
        if settings.supabase_jwks_url and self._jwks_client is None:
            self._jwks_client = PyJWKClient(
                settings.supabase_jwks_url,
                cache_jwk_set=True,
                lifespan=600,
                timeout=settings.auth_timeout_seconds,
            )
        if self._jwks_client is None and not settings.supabase_jwt_secret:
            raise AuthConfigurationError()

    def verify_access_token(self, token: str) -> AuthenticatedUser:
        try:
            claims = self._decode(token)
        except PyJWKClientError as error:
            raise AuthProviderUnavailableError() from error
        except InvalidTokenError as error:
            raise InvalidAccessTokenError() from error
        subject = claims.get("sub")
        if not isinstance(subject, str) or not subject.strip():
            raise InvalidAccessTokenError()
        email = claims.get("email")
        role = claims.get("role")
        roles = (role,) if isinstance(role, str) and role else ()
        return AuthenticatedUser(
            id=subject,
            email=email if isinstance(email, str) else None,
            roles=roles,
            provider="supabase",
        )

    def _decode(self, token: str) -> dict[str, Any]:
        options = {"require": ["exp", "iss", "aud", "sub"]}
        if self._jwks_client is not None:
            key = self._jwks_client.get_signing_key_from_jwt(token).key
            return jwt.decode(
                token,
                key,
                algorithms=["RS256", "ES256"],
                audience=self._settings.auth_audience,
                issuer=self._settings.auth_issuer,
                options=options,
            )
        return jwt.decode(
            token,
            self._settings.supabase_jwt_secret,
            algorithms=["HS256"],
            audience=self._settings.auth_audience,
            issuer=self._settings.auth_issuer,
            options=options,
        )
