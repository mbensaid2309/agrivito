from __future__ import annotations

from typing import Literal, Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator

DiagnosisLanguage = Literal["fr", "ar", "darija", "en"]
ResponseMode = Literal["reliable", "hypotheses", "questions_required", "refusal"]
TrustLevel = Literal["high", "medium", "low", "insufficient"]
UsageMode = Literal["discovery", "authenticated"]


class AIDiagnosisRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    question: str = Field(min_length=1, max_length=4000)
    language: DiagnosisLanguage = "fr"
    farm_id: Optional[str] = Field(default=None, min_length=1, max_length=128)
    field_id: Optional[str] = Field(default=None, min_length=1, max_length=128)
    crop_id: Optional[str] = Field(default=None, min_length=1, max_length=128)
    discovery_session_id: Optional[str] = Field(
        default=None, min_length=1, max_length=128
    )

    @field_validator("question", mode="before")
    @classmethod
    def strip_question(cls, value: object) -> object:
        return value.strip() if isinstance(value, str) else value

    @field_validator(
        "farm_id",
        "field_id",
        "crop_id",
        "discovery_session_id",
        mode="before",
    )
    @classmethod
    def strip_optional_identifier(cls, value: object) -> object:
        return value.strip() if isinstance(value, str) else value


class DiagnosisHypothesis(BaseModel):
    label: str = Field(min_length=1)
    explanation: str = Field(min_length=1)


class ProviderDiagnosisContent(BaseModel):
    model_config = ConfigDict(extra="ignore")

    summary: str = Field(min_length=1)
    observations: list[str]
    hypotheses: list[DiagnosisHypothesis]
    recommendations: list[str]
    follow_up_questions: list[str]
    precautions: list[str]
    response_mode: ResponseMode


class TrustScoreResponse(BaseModel):
    score: int = Field(ge=0, le=100)
    level: TrustLevel
    explanation: str = Field(min_length=1)


class DiagnosisContent(ProviderDiagnosisContent):
    trust_score: TrustScoreResponse
    language: DiagnosisLanguage


class DiagnosisContextUsed(BaseModel):
    farmer_profile: bool = False
    farm: bool = False
    field: bool = False
    crop: bool = False


class DiagnosisUsage(BaseModel):
    mode: UsageMode
    questions_used: Optional[int] = Field(default=None, ge=0)
    questions_limit: Optional[int] = Field(default=None, ge=1)
    remaining: Optional[int] = Field(default=None, ge=0)


class AIDiagnosisResponse(BaseModel):
    diagnosis: DiagnosisContent
    context_used: DiagnosisContextUsed
    usage: DiagnosisUsage


class InternalAIDiagnosisRequest(AIDiagnosisRequest):
    user_id: Optional[str] = Field(default=None, min_length=1, max_length=128)


class AgriculturalContext(BaseModel):
    model_config = ConfigDict(extra="forbid")

    user_type: Optional[str] = None
    country: Optional[str] = None
    region: Optional[str] = None
    preferred_language: Optional[str] = None
    farm_name: Optional[str] = None
    farm_locality: Optional[str] = None
    total_area: Optional[float] = None
    area_unit: Optional[str] = None
    field_name: Optional[str] = None
    field_area: Optional[float] = None
    soil_type: Optional[str] = None
    water_access: Optional[str] = None
    irrigation_type: Optional[str] = None
    crop_name: Optional[str] = None
    crop_category: Optional[str] = None
    variety: Optional[str] = None
    season: Optional[str] = None
    planting_date: Optional[str] = None
    growth_stage: Optional[str] = None
