from typing import Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.db.session import get_db
from app.schemas.media import MediaMetadata, MediaUploadResponse
from app.services.media.media_service import MediaService
from app.services.media.usage_tracker import (
    DiscoveryPhotoUsageTracker,
    get_discovery_photo_usage_tracker,
)
from app.storage.dependencies import get_media_storage_provider
from app.storage.provider import MediaStorageProvider
from app.services.auth.dependencies import get_current_user
from app.services.auth.models import AuthenticatedUser

router = APIRouter(prefix="/media", tags=["media"])


def get_media_service(
    storage: MediaStorageProvider = Depends(get_media_storage_provider),
    settings: Settings = Depends(get_settings),
    usage_tracker: DiscoveryPhotoUsageTracker = Depends(
        get_discovery_photo_usage_tracker
    ),
) -> MediaService:
    return MediaService(storage, settings, usage_tracker)


@router.post(
    "/upload",
    response_model=MediaUploadResponse,
    status_code=status.HTTP_201_CREATED,
)
async def upload_media(
    file: UploadFile = File(...),
    farm_id: Optional[str] = Form(default=None),
    field_id: Optional[str] = Form(default=None),
    crop_id: Optional[str] = Form(default=None),
    db: Session = Depends(get_db),
    service: MediaService = Depends(get_media_service),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> MediaUploadResponse:
    media = await service.upload(
        db=db,
        file=file,
        user_id=current_user.id,
        discovery_session_id=None,
        farm_id=farm_id,
        field_id=field_id,
        crop_id=crop_id,
    )
    return MediaUploadResponse(media=media)


@router.get("/{media_id}", response_model=MediaMetadata)
def get_media_metadata(
    media_id: str,
    db: Session = Depends(get_db),
    service: MediaService = Depends(get_media_service),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> MediaMetadata:
    media = service.get(db, media_id, current_user.id)
    if media is None:
        raise HTTPException(status_code=404, detail="Media not found.")
    return MediaMetadata.model_validate(media)
