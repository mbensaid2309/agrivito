from __future__ import annotations

from functools import lru_cache
from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.config import Settings, get_settings
from app.services.auth.exceptions import (
    AuthConfigurationError,
    AuthProviderUnavailableError,
    InvalidAccessTokenError,
)
from app.services.auth.mock_provider import MockAuthProvider
from app.services.auth.models import AuthenticatedUser
from app.services.auth.provider import AuthProvider
from app.services.auth.supabase_provider import SupabaseAuthProvider

bearer_scheme = HTTPBearer(auto_error=False)


@lru_cache
def _build_auth_provider(settings: Settings) -> AuthProvider:
    if settings.auth_mode == "mock":
        return MockAuthProvider()
    return SupabaseAuthProvider(settings)


def get_auth_provider(settings: Settings = Depends(get_settings)) -> AuthProvider:
    return _build_auth_provider(settings)


def _unauthorized() -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Authentication required.",
        headers={"WWW-Authenticate": "Bearer"},
    )


def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(bearer_scheme),
    provider: AuthProvider = Depends(get_auth_provider),
) -> AuthenticatedUser:
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise _unauthorized()
    try:
        return provider.verify_access_token(credentials.credentials)
    except (InvalidAccessTokenError, AuthConfigurationError):
        raise _unauthorized() from None
    except AuthProviderUnavailableError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Authentication service is temporarily unavailable.",
        ) from None


def get_optional_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(bearer_scheme),
    provider: AuthProvider = Depends(get_auth_provider),
) -> Optional[AuthenticatedUser]:
    if credentials is None:
        return None
    return get_current_user(credentials, provider)
