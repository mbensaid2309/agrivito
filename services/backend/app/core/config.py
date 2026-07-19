import os
from dataclasses import dataclass
from functools import lru_cache

from dotenv import load_dotenv

load_dotenv()


@dataclass(frozen=True)
class Settings:
    app_env: str = "local"
    app_name: str = "agrivito-backend"
    aws_region: str = ""
    aws_s3_bucket: str = ""
    aws_cognito_user_pool_id: str = ""
    aws_cognito_client_id: str = ""
    database_url: str = ""
    openai_api_key: str = ""
    openai_model: str = ""
    openai_timeout_seconds: float = 30.0
    ai_provider: str = "openai"
    ai_mode: str = "mock"
    media_storage_provider: str = "local"
    media_local_path: str = "./data/media"
    media_max_size_mb: int = 10
    media_allowed_mime_types: tuple[str, ...] = (
        "image/jpeg",
        "image/png",
        "image/webp",
    )
    vision_provider: str = "openai"
    vision_mode: str = "mock"
    openai_vision_model: str = ""
    vision_timeout_seconds: float = 45.0
    photo_diagnosis_discovery_limit: int = 1
    log_level: str = "INFO"


def _read_env(name: str, default: str = "") -> str:
    value = os.getenv(name, default).strip()
    return value


def load_settings() -> Settings:
    app_name = _read_env("APP_NAME", "agrivito-backend")
    if not app_name:
        raise ValueError("APP_NAME must not be empty.")

    timeout_value = _read_env("OPENAI_TIMEOUT_SECONDS", "30") or "30"
    try:
        openai_timeout_seconds = float(timeout_value)
    except ValueError as error:
        raise ValueError("OPENAI_TIMEOUT_SECONDS must be a number.") from error
    if openai_timeout_seconds <= 0:
        raise ValueError("OPENAI_TIMEOUT_SECONDS must be greater than zero.")

    ai_provider = _read_env("AI_PROVIDER", "openai").lower() or "openai"
    if ai_provider != "openai":
        raise ValueError("AI_PROVIDER must be 'openai'.")

    ai_mode = _read_env("AI_MODE", "mock").lower() or "mock"
    if ai_mode not in {"mock", "live"}:
        raise ValueError("AI_MODE must be 'mock' or 'live'.")

    media_storage_provider = (
        _read_env("MEDIA_STORAGE_PROVIDER", "local").lower() or "local"
    )
    if media_storage_provider not in {"local", "s3"}:
        raise ValueError("MEDIA_STORAGE_PROVIDER must be 'local' or 's3'.")

    media_local_path = _read_env("MEDIA_LOCAL_PATH", "./data/media")
    if not media_local_path:
        raise ValueError("MEDIA_LOCAL_PATH must not be empty.")

    media_max_size_value = _read_env("MEDIA_MAX_SIZE_MB", "10") or "10"
    try:
        media_max_size_mb = int(media_max_size_value)
    except ValueError as error:
        raise ValueError("MEDIA_MAX_SIZE_MB must be an integer.") from error
    if media_max_size_mb <= 0:
        raise ValueError("MEDIA_MAX_SIZE_MB must be greater than zero.")

    supported_mime_types = {"image/jpeg", "image/png", "image/webp"}
    media_allowed_mime_types = tuple(
        item.strip().lower()
        for item in _read_env(
            "MEDIA_ALLOWED_MIME_TYPES", "image/jpeg,image/png,image/webp"
        ).split(",")
        if item.strip()
    )
    if not media_allowed_mime_types:
        raise ValueError("MEDIA_ALLOWED_MIME_TYPES must not be empty.")
    if not set(media_allowed_mime_types).issubset(supported_mime_types):
        raise ValueError("MEDIA_ALLOWED_MIME_TYPES contains an unsupported type.")

    aws_region = _read_env("AWS_REGION")
    aws_s3_bucket = _read_env("AWS_S3_BUCKET")
    if media_storage_provider == "s3" and (not aws_region or not aws_s3_bucket):
        raise ValueError(
            "AWS_REGION and AWS_S3_BUCKET are required for S3 media storage."
        )

    vision_provider = _read_env("VISION_PROVIDER", "openai").lower() or "openai"
    if vision_provider != "openai":
        raise ValueError("VISION_PROVIDER must be 'openai'.")

    vision_mode = _read_env("VISION_MODE", "mock").lower() or "mock"
    if vision_mode not in {"mock", "live"}:
        raise ValueError("VISION_MODE must be 'mock' or 'live'.")

    vision_timeout_value = _read_env("VISION_TIMEOUT_SECONDS", "45") or "45"
    try:
        vision_timeout_seconds = float(vision_timeout_value)
    except ValueError as error:
        raise ValueError("VISION_TIMEOUT_SECONDS must be a number.") from error
    if vision_timeout_seconds <= 0:
        raise ValueError("VISION_TIMEOUT_SECONDS must be greater than zero.")

    discovery_limit_value = (
        _read_env("PHOTO_DIAGNOSIS_DISCOVERY_LIMIT", "1") or "1"
    )
    try:
        photo_diagnosis_discovery_limit = int(discovery_limit_value)
    except ValueError as error:
        raise ValueError(
            "PHOTO_DIAGNOSIS_DISCOVERY_LIMIT must be an integer."
        ) from error
    if photo_diagnosis_discovery_limit <= 0:
        raise ValueError(
            "PHOTO_DIAGNOSIS_DISCOVERY_LIMIT must be greater than zero."
        )

    openai_api_key = _read_env("OPENAI_API_KEY")
    openai_vision_model = _read_env("OPENAI_VISION_MODEL")
    if vision_mode == "live" and not openai_api_key:
        raise ValueError("OPENAI_API_KEY is required when VISION_MODE is live.")
    if vision_mode == "live" and not openai_vision_model:
        raise ValueError(
            "OPENAI_VISION_MODEL is required when VISION_MODE is live."
        )

    return Settings(
        app_env=_read_env("APP_ENV", "local") or "local",
        app_name=app_name,
        aws_region=aws_region,
        aws_s3_bucket=aws_s3_bucket,
        aws_cognito_user_pool_id=_read_env("AWS_COGNITO_USER_POOL_ID"),
        aws_cognito_client_id=_read_env("AWS_COGNITO_CLIENT_ID"),
        database_url=_read_env("DATABASE_URL"),
        openai_api_key=openai_api_key,
        openai_model=_read_env("OPENAI_MODEL"),
        openai_timeout_seconds=openai_timeout_seconds,
        ai_provider=ai_provider,
        ai_mode=ai_mode,
        media_storage_provider=media_storage_provider,
        media_local_path=media_local_path,
        media_max_size_mb=media_max_size_mb,
        media_allowed_mime_types=media_allowed_mime_types,
        vision_provider=vision_provider,
        vision_mode=vision_mode,
        openai_vision_model=openai_vision_model,
        vision_timeout_seconds=vision_timeout_seconds,
        photo_diagnosis_discovery_limit=photo_diagnosis_discovery_limit,
        log_level=_read_env("LOG_LEVEL", "INFO") or "INFO",
    )


@lru_cache
def get_settings() -> Settings:
    return load_settings()
