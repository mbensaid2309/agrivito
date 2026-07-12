from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING, Optional
from uuid import uuid4

from sqlalchemy import DateTime, Float, ForeignKey, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.farm import Farm
    from app.models.field_crop import FieldCrop


class Field(Base):
    __tablename__ = "fields"

    field_id: Mapped[str] = mapped_column(
        "id", String(36), primary_key=True, default=lambda: str(uuid4())
    )
    farm_id: Mapped[str] = mapped_column(
        ForeignKey("farms.id", ondelete="CASCADE"), index=True
    )
    name: Mapped[str] = mapped_column(String(160))
    area: Mapped[float] = mapped_column(Float)
    area_unit: Mapped[str] = mapped_column(String(24))
    soil_type: Mapped[Optional[str]] = mapped_column(String(120))
    water_access: Mapped[str] = mapped_column(String(16), default="unknown")
    irrigation_type: Mapped[str] = mapped_column(String(16), default="unknown")
    notes: Mapped[Optional[str]] = mapped_column(String(1000))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )
    farm: Mapped["Farm"] = relationship(back_populates="fields")
    field_crops: Mapped[list["FieldCrop"]] = relationship(
        back_populates="field", cascade="all, delete-orphan"
    )
