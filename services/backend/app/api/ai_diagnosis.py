from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.ai_diagnosis import AIDiagnosisRequest, AIDiagnosisResponse
from app.services.ai.dependencies import get_ai_orchestrator
from app.services.ai.orchestrator import AIOrchestrator

router = APIRouter(prefix="/ai", tags=["ai"])


@router.post("/diagnosis", response_model=AIDiagnosisResponse)
def create_text_diagnosis(
    request: AIDiagnosisRequest,
    db: Session = Depends(get_db),
    orchestrator: AIOrchestrator = Depends(get_ai_orchestrator),
) -> AIDiagnosisResponse:
    return orchestrator.diagnose(db, request)
