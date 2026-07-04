from pydantic import BaseModel, Field


class TrustScoreResponse(BaseModel):
    score: int = Field(ge=0, le=100)
    level: str
    explanation: str
