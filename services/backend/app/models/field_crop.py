from __future__ import annotations

from datetime import date, datetime
from typing import TYPE_CHECKING, Optional
from uuid import uuid4

from sqlalchemy import Date, DateTime, ForeignKey, Index, String, text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.crop import Crop
    from app.models.field import Field


class FieldCrop(Base):
    __tablename__ = "field_crops"
    __table_args__ = (
        Index(
            "uq_field_crops_active_field",
            "field_id",
            unique=True,
            postgresql_where=text("status = 'active'"),
        ),
    )

    field_crop_id: Mapped[str] = mapped_column(
        "id", String(36), primary_key=True, default=lambda: str(uuid4())
    )
    field_id: Mapped[str] = mapped_column(
        ForeignKey("fields.id", ondelete="CASCADE"), index=True
    )
    crop_id: Mapped[str] = mapped_column(ForeignKey("crops.id"), index=True)
    status: Mapped[str] = mapped_column(String(16), default="active")
    start_date: Mapped[Optional[date]] = mapped_column(Date)
    end_date: Mapped[Optional[date]] = mapped_column(Date)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )
    field: Mapped["Field"] = relationship(back_populates="field_crops")
    crop: Mapped["Crop"] = relationship(back_populates="field_crops")
