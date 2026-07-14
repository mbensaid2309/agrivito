import pytest

from app.core.config import get_settings, load_settings
from app.db.database import DatabaseConfigurationError, get_engine
from app.services.ai.dependencies import build_ai_provider
from app.services.ai.exceptions import AIConfigurationError
from app.services.ai.mock_provider import MockAIProvider


def test_minimal_configuration(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("APP_NAME", raising=False)
    monkeypatch.delenv("APP_ENV", raising=False)

    settings = load_settings()

    assert settings.app_env == "local"
    assert settings.app_name == "agrivito-backend"
    assert settings.log_level == "INFO"
    assert settings.ai_mode == "mock"
    assert settings.openai_timeout_seconds == 30
    assert settings.media_storage_provider == "local"
    assert settings.media_max_size_mb == 10
    assert settings.media_allowed_mime_types == (
        "image/jpeg",
        "image/png",
        "image/webp",
    )


def test_database_url_is_required(monkeypatch: pytest.MonkeyPatch) -> None:
    original_url = load_settings().database_url
    monkeypatch.delenv("DATABASE_URL", raising=False)
    get_settings.cache_clear()
    get_engine.cache_clear()

    with pytest.raises(DatabaseConfigurationError, match="DATABASE_URL is required"):
        get_engine()

    monkeypatch.setenv("DATABASE_URL", original_url)
    get_settings.cache_clear()
    get_engine.cache_clear()


def test_mock_mode_does_not_require_openai_key(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("AI_MODE", "mock")
    monkeypatch.delenv("OPENAI_API_KEY", raising=False)

    provider = build_ai_provider(load_settings())

    assert isinstance(provider, MockAIProvider)


def test_live_mode_requires_openai_configuration(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("AI_MODE", "live")
    monkeypatch.delenv("OPENAI_API_KEY", raising=False)
    monkeypatch.delenv("OPENAI_MODEL", raising=False)

    with pytest.raises(AIConfigurationError, match="OPENAI_API_KEY"):
        build_ai_provider(load_settings())


@pytest.mark.parametrize("value", ["0", "invalid"])
def test_openai_timeout_must_be_positive_number(
    monkeypatch: pytest.MonkeyPatch, value: str
) -> None:
    monkeypatch.setenv("OPENAI_TIMEOUT_SECONDS", value)

    with pytest.raises(ValueError, match="OPENAI_TIMEOUT_SECONDS"):
        load_settings()


def test_s3_mode_requires_region_and_bucket(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("MEDIA_STORAGE_PROVIDER", "s3")
    monkeypatch.delenv("AWS_REGION", raising=False)
    monkeypatch.delenv("AWS_S3_BUCKET", raising=False)

    with pytest.raises(ValueError, match="AWS_REGION and AWS_S3_BUCKET"):
        load_settings()


@pytest.mark.parametrize("value", ["0", "invalid"])
def test_media_size_must_be_positive_integer(
    monkeypatch: pytest.MonkeyPatch, value: str
) -> None:
    monkeypatch.setenv("MEDIA_MAX_SIZE_MB", value)

    with pytest.raises(ValueError, match="MEDIA_MAX_SIZE_MB"):
        load_settings()
