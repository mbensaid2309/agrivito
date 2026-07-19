from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from sqlalchemy.exc import SQLAlchemyError

from app.api.ai_diagnosis import router as ai_diagnosis_router
from app.api.crops import router as crops_router
from app.api.discovery import router as discovery_router
from app.api.farmer import router as farmer_router
from app.api.farms import router as farms_router
from app.api.field_crops import router as field_crops_router
from app.api.fields import router as fields_router
from app.api.health import router as health_router
from app.api.media import router as media_router
from app.api.photo_diagnosis import router as photo_diagnosis_router
from app.core.config import get_settings
from app.db.database import DatabaseConfigurationError
from app.services.agriculture.exceptions import (
    ResourceConflictError,
    ResourceNotFoundError,
)
from app.services.ai.exceptions import (
    AIConfigurationError,
    AIInvalidResponseError,
    AIProviderRateLimitError,
    AIProviderTimeoutError,
    AIProviderUnavailableError,
    AIServiceError,
    DiscoveryLimitReachedError,
)
from app.services.media.exceptions import (
    MediaDiscoveryLimitReachedError,
    MediaPersistenceError,
    MediaStorageUnavailableError,
    MediaValidationError,
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
    application.include_router(ai_diagnosis_router)
    application.include_router(discovery_router)
    application.include_router(farmer_router)
    application.include_router(farms_router)
    application.include_router(fields_router)
    application.include_router(crops_router)
    application.include_router(field_crops_router)
    application.include_router(media_router)
    application.include_router(photo_diagnosis_router)

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

    @application.exception_handler(DiscoveryLimitReachedError)
    async def discovery_limit_handler(
        request: Request, error: DiscoveryLimitReachedError
    ) -> JSONResponse:
        return JSONResponse(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            content={"detail": error.public_message},
        )

    @application.exception_handler(MediaValidationError)
    async def media_validation_handler(
        request: Request, error: MediaValidationError
    ) -> JSONResponse:
        return JSONResponse(
            status_code=error.status_code,
            content={"detail": error.public_message},
        )

    @application.exception_handler(MediaDiscoveryLimitReachedError)
    async def media_discovery_limit_handler(
        request: Request, error: MediaDiscoveryLimitReachedError
    ) -> JSONResponse:
        return JSONResponse(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            content={"detail": error.public_message},
        )

    @application.exception_handler(MediaStorageUnavailableError)
    @application.exception_handler(MediaPersistenceError)
    async def media_unavailable_handler(
        request: Request, error: Exception
    ) -> JSONResponse:
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={"detail": getattr(error, "public_message", "Media unavailable.")},
        )

    @application.exception_handler(AIProviderTimeoutError)
    async def ai_timeout_handler(
        request: Request, error: AIProviderTimeoutError
    ) -> JSONResponse:
        return JSONResponse(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            content={"detail": error.public_message},
        )

    @application.exception_handler(AIInvalidResponseError)
    async def ai_invalid_response_handler(
        request: Request, error: AIInvalidResponseError
    ) -> JSONResponse:
        return JSONResponse(
            status_code=status.HTTP_502_BAD_GATEWAY,
            content={"detail": error.public_message},
        )

    @application.exception_handler(AIConfigurationError)
    @application.exception_handler(AIProviderRateLimitError)
    @application.exception_handler(AIProviderUnavailableError)
    async def ai_unavailable_handler(
        request: Request, error: AIServiceError,
    ) -> JSONResponse:
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={"detail": error.public_message},
        )
    return application


app = create_app()
