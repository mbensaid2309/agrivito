from fastapi import FastAPI

from app.main import create_app


def test_application_loads() -> None:
    application = create_app()

    assert isinstance(application, FastAPI)
    assert application.title == "Agrivito Backend"
