import os

import pytest

from app.services.discovery.usage_tracker import get_discovery_usage_tracker

os.environ.setdefault("DATABASE_URL", "sqlite+pysqlite:///:memory:")
os.environ.setdefault("AI_MODE", "mock")


@pytest.fixture(autouse=True)
def reset_discovery_usage() -> None:
    tracker = get_discovery_usage_tracker()
    tracker.reset()
    yield
    tracker.reset()
