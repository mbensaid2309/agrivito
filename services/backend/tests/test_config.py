import pytest

from app.core.config import load_settings


def test_minimal_configuration(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("APP_NAME", raising=False)
    monkeypatch.delenv("APP_ENV", raising=False)

    settings = load_settings()

    assert settings.app_env == "local"
    assert settings.app_name == "agrivito-backend"
    assert settings.log_level == "INFO"
