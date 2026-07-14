class MediaServiceError(RuntimeError):
    public_message = "Media service is unavailable."


class MediaValidationError(MediaServiceError):
    def __init__(self, public_message: str, status_code: int) -> None:
        super().__init__(public_message)
        self.public_message = public_message
        self.status_code = status_code


class MediaStorageUnavailableError(MediaServiceError):
    public_message = "Media storage is temporarily unavailable."


class MediaPersistenceError(MediaServiceError):
    public_message = "Media metadata service is temporarily unavailable."


class MediaDiscoveryLimitReachedError(MediaServiceError):
    public_message = "Discovery photo limit reached. Create an account to continue."
