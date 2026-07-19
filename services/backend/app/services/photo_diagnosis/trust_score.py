from __future__ import annotations

from app.schemas.ai_diagnosis import DiagnosisContextUsed, TrustScoreResponse
from app.schemas.photo_diagnosis import (
    PhotoQualityResponse,
    PhotoQualitySignals,
)


class VisualTrustScoreEngine:
    def calculate(
        self,
        *,
        photo_quality: PhotoQualityResponse,
        signals: PhotoQualitySignals,
        context_used: DiagnosisContextUsed,
        question: str,
        provider_response_valid: bool,
    ) -> TrustScoreResponse:
        context_count = sum(
            (
                context_used.farmer_profile,
                context_used.farm,
                context_used.field,
                context_used.crop,
            )
        )
        score = round(
            photo_quality.score / 100 * 25
            + signals.subject_visibility * 15
            + signals.symptom_visibility * 15
            + signals.crop_identifiability * 10
            + context_count / 4 * 15
            + (10 if len(question.strip()) >= 10 else 4 if question.strip() else 0)
            + (10 if provider_response_valid else 0)
        )
        if photo_quality.level == "unusable":
            score = min(score, 39)
        elif photo_quality.level == "poor":
            score = min(score, 59)
        score = max(0, min(100, score))
        level = self.level_for(score)
        return TrustScoreResponse(
            score=score,
            level=level,
            explanation=(
                "Score calculé par Agrivito à partir de la qualité de la photo, "
                "de la visibilité du sujet, du contexte et de la question."
            ),
        )

    @staticmethod
    def level_for(score: int) -> str:
        if score >= 80:
            return "high"
        if score >= 60:
            return "medium"
        if score >= 40:
            return "low"
        return "insufficient"
