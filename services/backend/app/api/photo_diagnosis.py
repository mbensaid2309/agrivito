from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.photo_diagnosis import (
    PhotoDiagnosisRequest,
    PhotoDiagnosisResponse,
    InternalPhotoDiagnosisRequest,
)
from app.services.auth.dependencies import get_current_user
from app.services.auth.models import AuthenticatedUser
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
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> PhotoDiagnosisResponse:
    internal_request = InternalPhotoDiagnosisRequest(
        **request.model_dump(exclude={"discovery_session_id"}),
        user_id=current_user.id,
    )
    return orchestrator.diagnose(db, internal_request)
