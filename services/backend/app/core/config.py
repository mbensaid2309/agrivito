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
    log_level: str = "INFO"


def _read_env(name: str, default: str = "") -> str:
    value = os.getenv(name, default).strip()
    return value


def load_settings() -> Settings:
    app_name = _read_env("APP_NAME", "agrivito-backend")
    if not app_name:
        raise ValueError("APP_NAME must not be empty.")

    return Settings(
        app_env=_read_env("APP_ENV", "local") or "local",
        app_name=app_name,
        aws_region=_read_env("AWS_REGION"),
        aws_s3_bucket=_read_env("AWS_S3_BUCKET"),
        aws_cognito_user_pool_id=_read_env("AWS_COGNITO_USER_POOL_ID"),
        aws_cognito_client_id=_read_env("AWS_COGNITO_CLIENT_ID"),
        database_url=_read_env("DATABASE_URL"),
        openai_api_key=_read_env("OPENAI_API_KEY"),
        log_level=_read_env("LOG_LEVEL", "INFO") or "INFO",
    )


@lru_cache
def get_settings() -> Settings:
    return load_settings()
