from functools import lru_cache

from app.core.config import get_settings
from app.storage.local_storage import LocalMediaStorage
from app.storage.provider import MediaStorageProvider
from app.storage.s3_storage import S3MediaStorage


@lru_cache
def get_media_storage_provider() -> MediaStorageProvider:
    settings = get_settings()
    if settings.media_storage_provider == "s3":
        return S3MediaStorage(
            bucket=settings.aws_s3_bucket,
            region=settings.aws_region,
        )
    return LocalMediaStorage(settings.media_local_path)
