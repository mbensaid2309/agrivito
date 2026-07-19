from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.ai_diagnosis import (
    AIDiagnosisRequest,
    AIDiagnosisResponse,
    InternalAIDiagnosisRequest,
)
from app.services.auth.dependencies import get_current_user
from app.services.auth.models import AuthenticatedUser
from app.services.ai.dependencies import get_ai_orchestrator
from app.services.ai.orchestrator import AIOrchestrator

router = APIRouter(prefix="/ai", tags=["ai"])


@router.post("/diagnosis", response_model=AIDiagnosisResponse)
def create_text_diagnosis(
    request: AIDiagnosisRequest,
    db: Session = Depends(get_db),
    orchestrator: AIOrchestrator = Depends(get_ai_orchestrator),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> AIDiagnosisResponse:
    internal_request = InternalAIDiagnosisRequest(
        **request.model_dump(exclude={"discovery_session_id"}),
        user_id=current_user.id,
    )
    return orchestrator.diagnose(db, internal_request)
