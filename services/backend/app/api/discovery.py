from fastapi import APIRouter

from app.schemas.discovery import DiscoveryQuestionRequest, DiscoveryQuestionResponse
from app.services.discovery.discovery_service import DiscoveryService

router = APIRouter(prefix="/discovery", tags=["discovery"])


@router.post("/question", response_model=DiscoveryQuestionResponse)
def ask_discovery_question(
    request: DiscoveryQuestionRequest,
) -> DiscoveryQuestionResponse:
    service = DiscoveryService()
    return service.answer_question(request)
