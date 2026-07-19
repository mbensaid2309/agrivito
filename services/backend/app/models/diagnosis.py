from __future__ import annotations

from datetime import datetime
from typing import Any, Optional

from sqlalchemy import CheckConstraint, DateTime, ForeignKey, Integer, JSON, String, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Diagnosis(Base):
    __tablename__ = "diagnoses"
    __table_args__ = (
        CheckConstraint(
            "diagnosis_type IN ('text', 'photo')", name="ck_diagnoses_type"
        ),
        CheckConstraint(
            "photo_quality_score IS NULL OR photo_quality_score BETWEEN 0 AND 100",
            name="ck_diagnoses_photo_quality_score",
        ),
        CheckConstraint(
            "trust_score BETWEEN 0 AND 100", name="ck_diagnoses_trust_score"
        ),
        CheckConstraint(
            "status IN ('completed', 'failed', 'insufficient')",
            name="ck_diagnoses_status",
        ),
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    media_id: Mapped[Optional[str]] = mapped_column(
        ForeignKey("media.id", ondelete="CASCADE"), index=True
    )
    user_id: Mapped[Optional[str]] = mapped_column(String(128), index=True)
    discovery_session_id: Mapped[Optional[str]] = mapped_column(
        String(128), index=True
    )
    farm_id: Mapped[Optional[str]] = mapped_column(ForeignKey("farms.id"))
    field_id: Mapped[Optional[str]] = mapped_column(ForeignKey("fields.id"))
    crop_id: Mapped[Optional[str]] = mapped_column(ForeignKey("crops.id"))
    diagnosis_type: Mapped[str] = mapped_column(String(16), default="photo")
    summary: Mapped[str] = mapped_column(String(2000))
    observations_json: Mapped[list[Any]] = mapped_column(JSON)
    hypotheses_json: Mapped[list[Any]] = mapped_column(JSON)
    recommendations_json: Mapped[list[Any]] = mapped_column(JSON)
    follow_up_questions_json: Mapped[list[Any]] = mapped_column(JSON)
    precautions_json: Mapped[list[Any]] = mapped_column(JSON)
    photo_quality_score: Mapped[Optional[int]] = mapped_column(Integer)
    photo_quality_level: Mapped[Optional[str]] = mapped_column(String(16))
    trust_score: Mapped[int] = mapped_column(Integer)
    trust_level: Mapped[str] = mapped_column(String(16))
    response_mode: Mapped[str] = mapped_column(String(32))
    language: Mapped[str] = mapped_column(String(16))
    provider: Mapped[str] = mapped_column(String(32))
    model: Mapped[Optional[str]] = mapped_column(String(160))
    status: Mapped[str] = mapped_column(String(16))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )
