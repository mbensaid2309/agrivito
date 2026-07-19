class AuthenticationError(Exception):
    """Base error safe to translate to an HTTP 401."""


class InvalidAccessTokenError(AuthenticationError):
    pass


class AuthProviderUnavailableError(AuthenticationError):
    pass


class AuthConfigurationError(AuthenticationError):
    pass
