from __future__ import annotations

import logging
import time
from uuid import uuid4

from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError

from app.models.diagnosis import Diagnosis
from app.services.media.exceptions import MediaPersistenceError

from app.schemas.ai_diagnosis import (
    AIDiagnosisRequest,
    AIDiagnosisResponse,
    DiagnosisContent,
    DiagnosisUsage,
    ProviderDiagnosisContent,
    TrustScoreResponse,
)
from app.services.ai.context_builder import AgriculturalContextBuilder
from app.services.ai.prompts import SYSTEM_PROMPT, build_user_prompt
from app.services.ai.provider import AIProvider, AIProviderRequest
from app.services.ai.response_parser import AIResponseParser
from app.services.ai.trust_score import TrustScoreEngine
from app.services.discovery.usage_tracker import DiscoveryUsageTracker

logger = logging.getLogger(__name__)

_UNSUPPORTED_OBSERVATION_TERMS = (
    "analyse de sol",
    "image",
    "météo",
    "photo",
    "soil analysis",
    "weather",
)
_SENSITIVE_TERMS = (
    "dosage",
    "fongicide",
    "herbicide",
    "insecticide",
    "pesticide",
    "toxicité",
)
_HIGH_RISK_TERMS = (
    "dose exacte",
    "mélange de produits",
    "mélanger des produits",
    "sans protection",
)


class AIOrchestrator:
    def __init__(
        self,
        *,
        provider: AIProvider,
        usage_tracker: DiscoveryUsageTracker,
        context_builder: AgriculturalContextBuilder | None = None,
        response_parser: AIResponseParser | None = None,
        trust_score_engine: TrustScoreEngine | None = None,
    ) -> None:
        self._provider = provider
        self._usage_tracker = usage_tracker
        self._context_builder = context_builder or AgriculturalContextBuilder()
        self._response_parser = response_parser or AIResponseParser()
        self._trust_score_engine = trust_score_engine or TrustScoreEngine()

    def diagnose(
        self, db: Session, request: AIDiagnosisRequest
    ) -> AIDiagnosisResponse:
        started_at = time.monotonic()
        usage = self._build_usage(request)
        built_context = self._context_builder.build(db, request)
        provider_request = AIProviderRequest(
            system_prompt=SYSTEM_PROMPT,
            user_prompt=build_user_prompt(
                question=request.question,
                language=request.language,
                context=built_context.values,
            ),
            language=request.language,
        )

        raw_response = self._provider.generate_diagnosis(provider_request)
        parsed = self._response_parser.parse(raw_response)
        trust_score = self._trust_score_engine.calculate(
            question=request.question,
            context_used=built_context.used,
            provider_response_valid=True,
        )
        diagnosis = self._apply_guardrails(
            request=request,
            parsed=parsed,
            trust_score=trust_score,
        )
        self._persist_authenticated_diagnosis(db, request, diagnosis)
        duration_ms = round((time.monotonic() - started_at) * 1000)
        logger.info(
            "ai_diagnosis provider=%s duration_ms=%s success=true "
            "trust_score=%s response_mode=%s",
            self._provider.name,
            duration_ms,
            trust_score.score,
            diagnosis.response_mode,
        )
        return AIDiagnosisResponse(
            diagnosis=diagnosis,
            context_used=built_context.used,
            usage=usage,
        )

    def _build_usage(self, request: AIDiagnosisRequest) -> DiagnosisUsage:
        if getattr(request, "user_id", None) and not request.discovery_session_id:
            return DiagnosisUsage(mode="authenticated")
        snapshot = self._usage_tracker.consume(request.discovery_session_id)
        return DiagnosisUsage(
            mode="discovery",
            questions_used=snapshot.questions_used,
            questions_limit=snapshot.questions_limit,
            remaining=snapshot.remaining,
        )

    def _apply_guardrails(
        self,
        *,
        request: AIDiagnosisRequest,
        parsed: ProviderDiagnosisContent,
        trust_score: TrustScoreResponse,
    ) -> DiagnosisContent:
        normalized_question = request.question.lower()
        observations = [
            observation
            for observation in parsed.observations
            if not any(
                term in observation.lower()
                for term in _UNSUPPORTED_OBSERVATION_TERMS
            )
        ]
        if not observations:
            observations = [
                f"La question signale le problème suivant : {request.question[:240]}"
            ]

        precautions = list(dict.fromkeys(parsed.precautions))
        recommendations = list(parsed.recommendations)
        hypotheses = list(parsed.hypotheses)
        response_mode = parsed.response_mode

        is_sensitive = any(term in normalized_question for term in _SENSITIVE_TERMS)
        is_high_risk = any(term in normalized_question for term in _HIGH_RISK_TERMS)
        if is_sensitive:
            precautions.append(
                "Vérifier l'étiquette officielle et les règles locales avant toute utilisation."
            )
        if is_high_risk or response_mode == "refusal":
            response_mode = "refusal"
            recommendations = []
            precautions.append(
                "Consulter un conseiller agricole qualifié avant toute action à risque."
            )
        elif trust_score.score >= 80:
            response_mode = (
                response_mode
                if response_mode in {"hypotheses", "questions_required"}
                else "reliable"
            )
        elif trust_score.score >= 60:
            response_mode = (
                "questions_required"
                if response_mode == "questions_required"
                else "hypotheses"
            )
        else:
            response_mode = "questions_required"
            precautions.append(
                "Agrivito ne peut pas conclure sans informations supplémentaires."
            )
            if trust_score.score < 40:
                recommendations = []
                hypotheses = []

        return DiagnosisContent(
            summary=parsed.summary,
            observations=observations,
            hypotheses=hypotheses,
            recommendations=recommendations,
            follow_up_questions=parsed.follow_up_questions,
            precautions=list(dict.fromkeys(precautions)),
            trust_score=trust_score,
            response_mode=response_mode,
            language=request.language,
        )

    def _persist_authenticated_diagnosis(
        self,
        db: Session,
        request: AIDiagnosisRequest,
        diagnosis: DiagnosisContent,
    ) -> None:
        owner_id = getattr(request, "user_id", None)
        if not owner_id:
            return
        record = Diagnosis(
            id=str(uuid4()),
            media_id=None,
            user_id=owner_id,
            discovery_session_id=None,
            farm_id=request.farm_id,
            field_id=request.field_id,
            crop_id=request.crop_id,
            diagnosis_type="text",
            summary=diagnosis.summary,
            observations_json=diagnosis.observations,
            hypotheses_json=[item.model_dump() for item in diagnosis.hypotheses],
            recommendations_json=diagnosis.recommendations,
            follow_up_questions_json=diagnosis.follow_up_questions,
            precautions_json=diagnosis.precautions,
            photo_quality_score=None,
            photo_quality_level=None,
            trust_score=diagnosis.trust_score.score,
            trust_level=diagnosis.trust_score.level,
            response_mode=diagnosis.response_mode,
            language=diagnosis.language,
            provider=self._provider.name,
            model=getattr(self._provider, "model", None),
            status=(
                "insufficient"
                if diagnosis.trust_score.level == "insufficient"
                else "completed"
            ),
        )
        try:
            db.add(record)
            db.commit()
        except SQLAlchemyError as error:
            db.rollback()
            raise MediaPersistenceError() from error
