from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from app.api.media import get_media_service
from app.db.session import get_db
from app.schemas.media import MediaUploadResponse
from app.schemas.photo_diagnosis import (
    InternalPhotoDiagnosisRequest,
    PhotoDiagnosisRequest,
    PhotoDiagnosisResponse,
)
from app.services.media.media_service import MediaService
from app.services.photo_diagnosis.dependencies import get_photo_diagnosis_orchestrator
from app.services.photo_diagnosis.orchestrator import PhotoDiagnosisOrchestrator

router = APIRouter(prefix="/discovery", tags=["discovery"])


@router.post(
    "/media/upload",
    response_model=MediaUploadResponse,
    status_code=status.HTTP_201_CREATED,
)
async def upload_discovery_media(
    file: UploadFile = File(...),
    discovery_session_id: str = Form(...),
    db: Session = Depends(get_db),
    service: MediaService = Depends(get_media_service),
) -> MediaUploadResponse:
    media = await service.upload(
        db=db,
        file=file,
        user_id=None,
        discovery_session_id=discovery_session_id,
    )
    return MediaUploadResponse(media=media)


@router.post("/photo-diagnosis", response_model=PhotoDiagnosisResponse)
def create_discovery_photo_diagnosis(
    request: PhotoDiagnosisRequest,
    db: Session = Depends(get_db),
    orchestrator: PhotoDiagnosisOrchestrator = Depends(
        get_photo_diagnosis_orchestrator
    ),
) -> PhotoDiagnosisResponse:
    if not request.discovery_session_id:
        raise HTTPException(status_code=422, detail="Discovery session is required.")
    if any((request.farm_id, request.field_id, request.crop_id)):
        raise HTTPException(
            status_code=422,
            detail="Agricultural context requires authentication.",
        )
    internal_request = InternalPhotoDiagnosisRequest(**request.model_dump())
    return orchestrator.diagnose(db, internal_request)
