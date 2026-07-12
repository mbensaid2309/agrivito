from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING, Optional
from uuid import uuid4

from sqlalchemy import DateTime, Float, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.field import Field


class Farm(Base):
    __tablename__ = "farms"

    farm_id: Mapped[str] = mapped_column(
        "id", String(36), primary_key=True, default=lambda: str(uuid4())
    )
    user_id: Mapped[str] = mapped_column(String(128), index=True)
    name: Mapped[str] = mapped_column(String(160))
    country: Mapped[str] = mapped_column(String(100))
    region: Mapped[str] = mapped_column(String(120))
    locality: Mapped[str] = mapped_column(String(160))
    total_area: Mapped[Optional[float]] = mapped_column(Float)
    area_unit: Mapped[str] = mapped_column(String(24), default="unknown")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )
    fields: Mapped[list["Field"]] = relationship(
        back_populates="farm", cascade="all, delete-orphan"
    )
