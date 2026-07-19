from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.schemas.trust_score import TrustScoreResponse


class DiscoveryQuestionRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    session_id: str = Field(min_length=1)
    question: str = Field(min_length=1)
    language: Literal["fr", "ar", "darija", "en"] = "fr"

    @field_validator("session_id", "question", "language")
    @classmethod
    def strip_required_text(cls, value: str) -> str:
        stripped = value.strip()
        if not stripped:
            raise ValueError("Value must not be empty.")
        return stripped


class DiscoveryAnswer(BaseModel):
    summary: str
    response: str
    trust_score: TrustScoreResponse
    follow_up_questions: list[str]
    precautions: list[str]


class DiscoveryUsage(BaseModel):
    questions_used: int = Field(ge=0)
    questions_limit: int = Field(ge=1)
    remaining: int = Field(ge=0)


class DiscoveryQuestionResponse(BaseModel):
    answer: DiscoveryAnswer
    usage: DiscoveryUsage
