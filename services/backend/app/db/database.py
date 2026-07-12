from functools import lru_cache

from sqlalchemy import Engine, create_engine
from sqlalchemy.pool import StaticPool

from app.core.config import get_settings


class DatabaseConfigurationError(RuntimeError):
    pass


@lru_cache
def get_engine() -> Engine:
    database_url = get_settings().database_url
    if not database_url:
        raise DatabaseConfigurationError(
            "DATABASE_URL is required for agricultural persistence."
        )
    if database_url.startswith("sqlite"):
        return create_engine(
            database_url,
            connect_args={"check_same_thread": False},
            poolclass=StaticPool,
        )
    return create_engine(database_url, pool_pre_ping=True)
