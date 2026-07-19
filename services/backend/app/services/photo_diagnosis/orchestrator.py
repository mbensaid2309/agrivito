from __future__ import annotations

import logging
import re
import time
from uuid import uuid4

from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.models.diagnosis import Diagnosis
from app.models.media import Media
from app.schemas.photo_diagnosis import (
    PhotoDiagnosisContent,
    PhotoDiagnosisRequest,
    PhotoDiagnosisResponse,
    PhotoDiagnosisUsage,
    PhotoQualityResponse,
    ProviderPhotoDiagnosisContent,
)
from app.schemas.ai_diagnosis import TrustScoreResponse
from app.services.agriculture.exceptions import ResourceNotFoundError
from app.services.ai.context_builder import AgriculturalContextBuilder
from app.services.ai.exceptions import AIInvalidResponseError
from app.services.media.exceptions import (
    MediaPersistenceError,
    MediaStorageUnavailableError,
    MediaValidationError,
)
from app.services.photo_diagnosis.photo_quality import PhotoQualityEngine
from app.services.photo_diagnosis.prompts import build_vision_prompt
from app.services.photo_diagnosis.provider import (
    VisionProvider,
    VisionProviderRequest,
)
from app.services.photo_diagnosis.response_parser import VisionResponseParser
from app.services.photo_diagnosis.trust_score import VisualTrustScoreEngine
from app.services.photo_diagnosis.usage_tracker import (
    PhotoDiagnosisUsageTracker,
)
from app.storage.exceptions import MediaStorageError
from app.storage.provider import MediaStorageProvider

logger = logging.getLogger(__name__)
_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}


class PhotoDiagnosisOrchestrator:
    def __init__(
        self,
        *,
        provider: VisionProvider,
        storage: MediaStorageProvider,
        usage_tracker: PhotoDiagnosisUsageTracker,
        context_builder: AgriculturalContextBuilder | None = None,
        response_parser: VisionResponseParser | None = None,
        photo_quality_engine: PhotoQualityEngine | None = None,
        trust_score_engine: VisualTrustScoreEngine | None = None,
    ) -> None:
        self._provider = provider
        self._storage = storage
        self._usage_tracker = usage_tracker
        self._context_builder = context_builder or AgriculturalContextBuilder()
        self._response_parser = response_parser or VisionResponseParser()
        self._photo_quality_engine = photo_quality_engine or PhotoQualityEngine()
        self._trust_score_engine = trust_score_engine or VisualTrustScoreEngine()

    def diagnose(
        self, db: Session, request: PhotoDiagnosisRequest
    ) -> PhotoDiagnosisResponse:
        started_at = time.monotonic()
        media = self._load_and_validate_media(db, request)
        image_bytes = self._read_media(media)
        contextual_request = request.model_copy(
            update={
                "user_id": getattr(request, "user_id", None) or media.user_id,
                "farm_id": request.farm_id or media.farm_id,
                "field_id": request.field_id or media.field_id,
                "crop_id": request.crop_id or media.crop_id,
            }
        )
        built_context = self._context_builder.build(db, contextual_request)
        prompt = build_vision_prompt(
            question=request.question,
            language=request.language,
            context=built_context.values,
        )
        usage, consumed_session = self._consume_usage(request)
        try:
            parsed = self._call_and_parse(
                image_bytes=image_bytes,
                content_type=media.content_type,
                prompt=prompt,
                language=request.language,
            )
            parsed = self._apply_visual_guardrails(parsed)
            photo_quality = self._photo_quality_engine.calculate(
                signals=parsed.quality_signals,
                size_bytes=media.size_bytes,
            )
            trust_score = self._trust_score_engine.calculate(
                photo_quality=photo_quality,
                signals=parsed.quality_signals,
                context_used=built_context.used,
                question=request.question,
                provider_response_valid=True,
            )
            diagnosis = self._guard_and_persist(
                db=db,
                request=contextual_request,
                media=media,
                parsed=parsed,
                photo_quality=photo_quality,
                trust_score=trust_score,
            )
        except Exception:
            if consumed_session is not None:
                self._usage_tracker.release(consumed_session)
            raise

        duration_ms = round((time.monotonic() - started_at) * 1000)
        logger.info(
            "photo_diagnosis provider=%s duration_ms=%s success=true "
            "trust_score=%s response_mode=%s",
            self._provider.name,
            duration_ms,
            diagnosis.trust_score.score,
            diagnosis.response_mode,
        )
        return PhotoDiagnosisResponse(
            diagnosis=diagnosis,
            context_used=built_context.used,
            usage=usage,
        )

    def _load_and_validate_media(
        self, db: Session, request: PhotoDiagnosisRequest
    ) -> Media:
        media = db.get(Media, request.media_id)
        if media is None:
            raise ResourceNotFoundError("Media not found.")
        if media.status != "uploaded":
            raise ResourceNotFoundError("Media is not available for analysis.")
        if media.content_type not in _IMAGE_TYPES:
            raise MediaValidationError("Media must be an image.", 415)
        if media.storage_provider != self._storage.name:
            raise MediaStorageUnavailableError()
        if media.user_id and getattr(request, "user_id", None) != media.user_id:
            raise ResourceNotFoundError("Media not found.")
        if (
            media.discovery_session_id
            and not media.user_id
            and request.discovery_session_id != media.discovery_session_id
        ):
            raise ResourceNotFoundError("Media not found.")
        for requested, associated in (
            (request.farm_id, media.farm_id),
            (request.field_id, media.field_id),
            (request.crop_id, media.crop_id),
        ):
            if requested and associated and requested != associated:
                raise ResourceNotFoundError("Media context does not match.")
        return media

    def _read_media(self, media: Media) -> bytes:
        try:
            image_bytes = self._storage.read(media.storage_key)
        except MediaStorageError as error:
            raise MediaStorageUnavailableError() from error
        if (
            not image_bytes
            or self._detected_content_type(image_bytes) != media.content_type
        ):
            raise MediaValidationError("Stored media is not a valid image.", 415)
        return image_bytes

    def _call_and_parse(
        self,
        *,
        image_bytes: bytes,
        content_type: str,
        prompt: str,
        language: str,
    ) -> ProviderPhotoDiagnosisContent:
        request = VisionProviderRequest(
            image_bytes=image_bytes,
            content_type=content_type,
            prompt=prompt,
            language=language,
        )
        raw_response = self._provider.analyze(request)
        try:
            return self._response_parser.parse(raw_response)
        except AIInvalidResponseError:
            correction_request = VisionProviderRequest(
                image_bytes=image_bytes,
                content_type=content_type,
                prompt=(
                    f"{prompt}\nCorrection unique : retourne strictement le schéma demandé."
                ),
                language=language,
            )
            corrected = self._provider.analyze(correction_request)
            return self._response_parser.parse(corrected)

    def _consume_usage(
        self, request: PhotoDiagnosisRequest
    ) -> tuple[PhotoDiagnosisUsage, str | None]:
        if getattr(request, "user_id", None) and not request.discovery_session_id:
            return PhotoDiagnosisUsage(mode="authenticated"), None
        snapshot = self._usage_tracker.consume(request.discovery_session_id)
        return (
            PhotoDiagnosisUsage(
                mode="discovery",
                diagnoses_used=snapshot.diagnoses_used,
                diagnoses_limit=snapshot.diagnoses_limit,
                remaining=snapshot.remaining,
            ),
            request.discovery_session_id or "",
        )

    def _guard_and_persist(
        self,
        *,
        db: Session,
        request: PhotoDiagnosisRequest,
        media: Media,
        parsed: ProviderPhotoDiagnosisContent,
        photo_quality: PhotoQualityResponse,
        trust_score: TrustScoreResponse,
    ) -> PhotoDiagnosisContent:
        precautions = list(
            dict.fromkeys(
                [
                    *parsed.precautions,
                    "Une photo seule ne permet pas de confirmer une maladie.",
                    "L'agriculteur reste responsable de la décision finale.",
                ]
            )
        )
        hypotheses = list(parsed.hypotheses)
        recommendations = list(parsed.recommendations)
        response_mode = parsed.response_mode
        status = "completed"
        if photo_quality.level == "unusable" or trust_score.score < 40:
            hypotheses = []
            recommendations = []
            response_mode = "questions_required"
            status = "insufficient"
        elif photo_quality.retake_required or trust_score.score < 60:
            response_mode = "questions_required"
        elif trust_score.score < 80 or response_mode == "reliable":
            response_mode = "hypotheses"

        diagnosis_id = str(uuid4())
        record = Diagnosis(
            id=diagnosis_id,
            media_id=media.id,
            user_id=request.user_id,
            discovery_session_id=request.discovery_session_id,
            farm_id=request.farm_id,
            field_id=request.field_id,
            crop_id=request.crop_id,
            diagnosis_type="photo",
            summary=parsed.summary,
            observations_json=parsed.visual_observations,
            hypotheses_json=[item.model_dump() for item in hypotheses],
            recommendations_json=recommendations,
            follow_up_questions_json=parsed.follow_up_questions,
            precautions_json=precautions,
            photo_quality_score=photo_quality.score,
            photo_quality_level=photo_quality.level,
            trust_score=trust_score.score,
            trust_level=trust_score.level,
            response_mode=response_mode,
            language=request.language,
            provider=self._provider.name,
            model=self._provider.model,
            status=status,
        )
        try:
            db.add(record)
            db.flush()
            db.commit()
        except SQLAlchemyError as error:
            db.rollback()
            raise MediaPersistenceError() from error
        return PhotoDiagnosisContent(
            id=diagnosis_id,
            media_id=media.id,
            summary=parsed.summary,
            photo_quality=photo_quality,
            observations=parsed.visual_observations,
            hypotheses=hypotheses,
            recommendations=recommendations,
            follow_up_questions=parsed.follow_up_questions,
            precautions=precautions,
            trust_score=trust_score,
            response_mode=response_mode,
            language=request.language,
            status=status,
        )

    def _apply_visual_guardrails(
        self, parsed: ProviderPhotoDiagnosisContent
    ) -> ProviderPhotoDiagnosisContent:
        hypotheses = [
            hypothesis.model_copy(
                update={
                    "label": self._cautious_text(hypothesis.label),
                    "explanation": self._cautious_text(
                        hypothesis.explanation
                    ),
                }
            )
            for hypothesis in parsed.hypotheses
        ]
        recommendations = [
            self._cautious_text(item)
            for item in parsed.recommendations
            if not re.search(
                r"\b\d+(?:[.,]\d+)?\s*(?:ml|g|kg|l|litre|%)\b",
                item,
                flags=re.IGNORECASE,
            )
        ]
        return parsed.model_copy(
            update={
                "summary": self._cautious_text(parsed.summary),
                "visual_observations": [
                    self._cautious_text(item)
                    for item in parsed.visual_observations
                ],
                "hypotheses": hypotheses,
                "recommendations": recommendations,
            }
        )

    @staticmethod
    def _cautious_text(value: str) -> str:
        replacements = {
            "confirmée": "possible",
            "confirmé": "possible",
            "confirmed": "possible",
            "certainement": "possiblement",
            "certainty": "prudence",
        }
        cautious = value
        for unsafe, replacement in replacements.items():
            cautious = re.sub(
                unsafe,
                replacement,
                cautious,
                flags=re.IGNORECASE,
            )
        return cautious

    @staticmethod
    def _detected_content_type(content: bytes) -> str | None:
        if content.startswith(b"\xff\xd8\xff"):
            return "image/jpeg"
        if content.startswith(b"\x89PNG\r\n\x1a\n"):
            return "image/png"
        if (
            len(content) >= 12
            and content.startswith(b"RIFF")
            and content[8:12] == b"WEBP"
        ):
            return "image/webp"
        return None
