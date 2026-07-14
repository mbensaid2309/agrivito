class MediaStorageError(RuntimeError):
    """Base exception that never exposes provider details to API clients."""


class MediaStorageConfigurationError(MediaStorageError):
    pass


class MediaStorageOperationError(MediaStorageError):
    pass
