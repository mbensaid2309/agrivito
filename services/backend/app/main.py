from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from sqlalchemy.exc import SQLAlchemyError

from app.api.crops import router as crops_router
from app.api.discovery import router as discovery_router
from app.api.farmer import router as farmer_router
from app.api.farms import router as farms_router
from app.api.field_crops import router as field_crops_router
from app.api.fields import router as fields_router
from app.api.health import router as health_router
from app.core.config import get_settings
from app.db.database import DatabaseConfigurationError
from app.services.agriculture.exceptions import (
    ResourceConflictError,
    ResourceNotFoundError,
)


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

    @application.exception_handler(ResourceNotFoundError)
    async def resource_not_found_handler(
        request: Request, error: ResourceNotFoundError
    ) -> JSONResponse:
        return JSONResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            content={"detail": str(error)},
        )

    @application.exception_handler(ResourceConflictError)
    async def resource_conflict_handler(
        request: Request, error: ResourceConflictError
    ) -> JSONResponse:
        return JSONResponse(
            status_code=status.HTTP_409_CONFLICT,
            content={"detail": str(error)},
        )

    @application.exception_handler(DatabaseConfigurationError)
    @application.exception_handler(SQLAlchemyError)
    async def database_error_handler(
        request: Request, error: Exception
    ) -> JSONResponse:
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={"detail": "Agricultural data service is unavailable."},
        )
    return application


app = create_app()
