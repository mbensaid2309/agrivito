from __future__ import annotations

import unicodedata

from app.schemas.ai_diagnosis import (
    DiagnosisContextUsed,
    TrustScoreResponse,
)

_CROP_TERMS = {
    "agrumes",
    "ble",
    "cereale",
    "fraise",
    "mais",
    "olivier",
    "oignon",
    "pomme",
    "tomate",
}
_SYMPTOM_TERMS = {
    "brun",
    "chute",
    "fletri",
    "jaune",
    "mort",
    "pourri",
    "seche",
    "tache",
}


def trust_level_for_score(score: int) -> str:
    if score < 0 or score > 100:
        raise ValueError("Trust Score must be between 0 and 100.")
    if score >= 80:
        return "high"
    if score >= 60:
        return "medium"
    if score >= 40:
        return "low"
    return "insufficient"


class TrustScoreEngine:
    def calculate(
        self,
        *,
        question: str,
        context_used: DiagnosisContextUsed,
        provider_response_valid: bool,
    ) -> TrustScoreResponse:
        normalized = self._normalize(question)
        words = [word for word in normalized.split() if word]

        question_clarity = 20 if len(words) >= 6 else 12 if len(words) >= 3 else 5
        context_count = sum(
            (
                context_used.farmer_profile,
                context_used.farm,
                context_used.field,
                context_used.crop,
            )
        )
        context_completeness = round((context_count / 4) * 20)
        crop_identified = 15 if (
            context_used.crop or any(term in normalized for term in _CROP_TERMS)
        ) else 0
        field_context = 10 if context_used.field else 0
        symptom_precision = 15 if any(
            term in normalized for term in _SYMPTOM_TERMS
        ) else 10 if len(words) >= 8 else 5
        provider_validity = 20 if provider_response_valid else 0

        score = min(
            100,
            question_clarity
            + context_completeness
            + crop_identified
            + field_context
            + symptom_precision
            + provider_validity,
        )
        level = trust_level_for_score(score)
        explanation = self._explanation(
            score=score,
            context_count=context_count,
            crop_identified=crop_identified > 0,
        )
        return TrustScoreResponse(
            score=score,
            level=level,
            explanation=explanation,
        )

    def _normalize(self, value: str) -> str:
        decomposed = unicodedata.normalize("NFKD", value.lower())
        return "".join(char for char in decomposed if not unicodedata.combining(char))

    def _explanation(
        self, *, score: int, context_count: int, crop_identified: bool
    ) -> str:
        if score >= 80:
            return "Question précise et contexte agricole suffisamment renseigné."
        if score >= 60:
            return "Question compréhensible, mais certains éléments de contexte manquent."
        if context_count == 0 and not crop_identified:
            return "Contexte agricole et culture insuffisamment renseignés."
        return "Informations partielles : des précisions sont nécessaires."
