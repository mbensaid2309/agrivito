from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.discovery import DiscoveryQuestionRequest, DiscoveryQuestionResponse
from app.services.ai.dependencies import get_ai_orchestrator
from app.services.ai.orchestrator import AIOrchestrator
from app.services.discovery.discovery_service import DiscoveryService

router = APIRouter(prefix="/discovery", tags=["discovery"])


@router.post("/question", response_model=DiscoveryQuestionResponse)
def ask_discovery_question(
    request: DiscoveryQuestionRequest,
    db: Session = Depends(get_db),
    orchestrator: AIOrchestrator = Depends(get_ai_orchestrator),
) -> DiscoveryQuestionResponse:
    service = DiscoveryService(orchestrator)
    return service.answer_question(db, request)
