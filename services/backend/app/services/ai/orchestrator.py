from typing import Optional

from app.schemas.trust_score import TrustScoreResponse
from app.services.ai.trust_score_service import TrustScoreService


class AIOrchestrator:
    """Sprint 1 placeholder for backend-only AI orchestration."""

    def __init__(self, trust_score_service: Optional[TrustScoreService] = None) -> None:
        self._trust_score_service = trust_score_service or TrustScoreService()

    def get_mock_trust_score(self) -> TrustScoreResponse:
        return self._trust_score_service.get_mock_score()
