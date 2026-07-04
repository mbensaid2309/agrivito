from fastapi import FastAPI

from app.api.discovery import router as discovery_router
from app.api.health import router as health_router
from app.core.config import get_settings


def create_app() -> FastAPI:
    settings = get_settings()
    application = FastAPI(
        title="Agrivito Backend",
        version="0.1.0",
        description="Backend API initiale du MVP Agrivito.",
    )
    application.state.settings = settings
    application.include_router(health_router)
    application.include_router(discovery_router)
    return application


app = create_app()
