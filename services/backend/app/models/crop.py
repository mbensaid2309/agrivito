from __future__ import annotations

from datetime import date, datetime
from typing import TYPE_CHECKING, Optional
from uuid import uuid4

from sqlalchemy import Date, DateTime, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.field_crop import FieldCrop


class Crop(Base):
    __tablename__ = "crops"

    crop_id: Mapped[str] = mapped_column(
        "id", String(36), primary_key=True, default=lambda: str(uuid4())
    )
    name: Mapped[str] = mapped_column(String(160), index=True)
    category: Mapped[str] = mapped_column(String(32))
    variety: Mapped[Optional[str]] = mapped_column(String(160))
    season: Mapped[Optional[str]] = mapped_column(String(80))
    planting_date: Mapped[Optional[date]] = mapped_column(Date)
    growth_stage: Mapped[str] = mapped_column(String(32), default="unknown")
    notes: Mapped[Optional[str]] = mapped_column(String(1000))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )
    field_crops: Mapped[list["FieldCrop"]] = relationship(back_populates="crop")
