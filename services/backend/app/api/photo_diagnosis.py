from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.photo_diagnosis import (
    PhotoDiagnosisRequest,
    PhotoDiagnosisResponse,
)
from app.services.photo_diagnosis.dependencies import (
    get_photo_diagnosis_orchestrator,
)
from app.services.photo_diagnosis.orchestrator import PhotoDiagnosisOrchestrator

router = APIRouter(prefix="/ai", tags=["ai"])


@router.post("/photo-diagnosis", response_model=PhotoDiagnosisResponse)
def create_photo_diagnosis(
    request: PhotoDiagnosisRequest,
    db: Session = Depends(get_db),
    orchestrator: PhotoDiagnosisOrchestrator = Depends(
        get_photo_diagnosis_orchestrator
    ),
) -> PhotoDiagnosisResponse:
    return orchestrator.diagnose(db, request)
