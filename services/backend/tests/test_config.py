import pytest

from app.core.config import get_settings, load_settings
from app.db.database import DatabaseConfigurationError, get_engine


def test_minimal_configuration(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("APP_NAME", raising=False)
    monkeypatch.delenv("APP_ENV", raising=False)

    settings = load_settings()

    assert settings.app_env == "local"
    assert settings.app_name == "agrivito-backend"
    assert settings.log_level == "INFO"


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
