from collections.abc import Generator

from sqlalchemy.orm import Session, sessionmaker

from app.db.database import get_engine

SessionLocal = sessionmaker(autocommit=False, autoflush=False, expire_on_commit=False)


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal(bind=get_engine())
    try:
        yield db
    finally:
        db.close()
