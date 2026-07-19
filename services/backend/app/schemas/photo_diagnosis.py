from __future__ import annotations

from typing import Literal, Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.schemas.ai_diagnosis import (
    DiagnosisContextUsed,
    DiagnosisHypothesis,
    DiagnosisLanguage,
    ResponseMode,
    TrustScoreResponse,
)

PhotoQualityLevel = Literal["good", "acceptable", "poor", "unusable"]
PhotoDiagnosisStatus = Literal["completed", "failed", "insufficient"]


class PhotoDiagnosisRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    media_id: str = Field(min_length=1, max_length=128)
    question: str = Field(default="", max_length=4000)
    language: DiagnosisLanguage = "fr"
    farm_id: Optional[str] = Field(default=None, min_length=1, max_length=128)
    field_id: Optional[str] = Field(default=None, min_length=1, max_length=128)
    crop_id: Optional[str] = Field(default=None, min_length=1, max_length=128)
    discovery_session_id: Optional[str] = Field(
        default=None, min_length=1, max_length=128
    )

    @field_validator(
        "media_id",
        "question",
        "farm_id",
        "field_id",
        "crop_id",
        "discovery_session_id",
        mode="before",
    )
    @classmethod
    def strip_strings(cls, value: object) -> object:
        return value.strip() if isinstance(value, str) else value


class PhotoQualitySignals(BaseModel):
    model_config = ConfigDict(extra="forbid")

    brightness: float = Field(ge=0, le=1)
    sharpness: float = Field(ge=0, le=1)
    subject_visibility: float = Field(ge=0, le=1)
    distance: float = Field(ge=0, le=1)
    crop_identifiability: float = Field(ge=0, le=1)
    symptom_visibility: float = Field(ge=0, le=1)


class ProviderPhotoDiagnosisContent(BaseModel):
    model_config = ConfigDict(extra="ignore")

    summary: str = Field(min_length=1)
    visual_observations: list[str]
    hypotheses: list[DiagnosisHypothesis]
    recommendations: list[str]
    follow_up_questions: list[str]
    precautions: list[str]
    quality_signals: PhotoQualitySignals
    response_mode: ResponseMode


class PhotoQualityResponse(BaseModel):
    score: int = Field(ge=0, le=100)
    level: PhotoQualityLevel
    issues: list[str]
    retake_required: bool
    retake_instructions: list[str]


class PhotoDiagnosisContent(BaseModel):
    id: str
    media_id: str
    summary: str
    photo_quality: PhotoQualityResponse
    observations: list[str]
    hypotheses: list[DiagnosisHypothesis]
    recommendations: list[str]
    follow_up_questions: list[str]
    precautions: list[str]
    trust_score: TrustScoreResponse
    response_mode: ResponseMode
    language: DiagnosisLanguage
    status: PhotoDiagnosisStatus


class PhotoDiagnosisUsage(BaseModel):
    mode: Literal["discovery", "authenticated"]
    diagnoses_used: Optional[int] = Field(default=None, ge=0)
    diagnoses_limit: Optional[int] = Field(default=None, ge=1)
    remaining: Optional[int] = Field(default=None, ge=0)


class PhotoDiagnosisResponse(BaseModel):
    diagnosis: PhotoDiagnosisContent
    context_used: DiagnosisContextUsed
    usage: PhotoDiagnosisUsage


class InternalPhotoDiagnosisRequest(PhotoDiagnosisRequest):
    user_id: Optional[str] = Field(default=None, min_length=1, max_length=128)
