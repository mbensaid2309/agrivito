from sqlalchemy.orm import Session

from app.schemas.ai_diagnosis import AIDiagnosisRequest
from app.schemas.discovery import (
    DiscoveryAnswer,
    DiscoveryQuestionRequest,
    DiscoveryQuestionResponse,
    DiscoveryUsage,
)
from app.schemas.trust_score import TrustScoreResponse
from app.services.ai.orchestrator import AIOrchestrator

_LEGACY_TRUST_LEVELS = {
    "high": "élevé",
    "medium": "moyen",
    "low": "faible",
    "insufficient": "insuffisant",
}


class DiscoveryService:
    questions_limit = 3

    def __init__(self, orchestrator: AIOrchestrator) -> None:
        self._orchestrator = orchestrator

    def answer_question(
        self, db: Session, request: DiscoveryQuestionRequest
    ) -> DiscoveryQuestionResponse:
        result = self._orchestrator.diagnose(
            db,
            AIDiagnosisRequest(
                question=request.question,
                language=request.language,
                discovery_session_id=request.session_id,
            ),
        )
        diagnosis = result.diagnosis
        response_parts = [
            hypothesis.explanation for hypothesis in diagnosis.hypotheses
        ] + diagnosis.recommendations
        response = " ".join(response_parts) or diagnosis.summary
        usage = result.usage

        return DiscoveryQuestionResponse(
            answer=DiscoveryAnswer(
                summary=diagnosis.summary,
                response=response,
                trust_score=TrustScoreResponse(
                    score=diagnosis.trust_score.score,
                    level=_LEGACY_TRUST_LEVELS[diagnosis.trust_score.level],
                    explanation=diagnosis.trust_score.explanation,
                ),
                follow_up_questions=diagnosis.follow_up_questions,
                precautions=diagnosis.precautions,
            ),
            usage=DiscoveryUsage(
                questions_used=usage.questions_used or 0,
                questions_limit=usage.questions_limit or self.questions_limit,
                remaining=usage.remaining or 0,
            ),
        )
