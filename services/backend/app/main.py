from fastapi import FastAPI

from app.api.crops import router as crops_router
from app.api.discovery import router as discovery_router
from app.api.farmer import router as farmer_router
from app.api.farms import router as farms_router
from app.api.field_crops import router as field_crops_router
from app.api.fields import router as fields_router
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
    application.include_router(farmer_router)
    application.include_router(farms_router)
    application.include_router(fields_router)
    application.include_router(crops_router)
    application.include_router(field_crops_router)
    return application


app = create_app()
