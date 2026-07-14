from datetime import datetime
from typing import Optional

from sqlalchemy import CheckConstraint, DateTime, ForeignKey, Integer, String, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Media(Base):
    __tablename__ = "media"
    __table_args__ = (
        CheckConstraint(
            "storage_provider IN ('local', 's3')",
            name="ck_media_storage_provider",
        ),
        CheckConstraint(
            "status IN ('uploaded', 'failed', 'deleted')",
            name="ck_media_status",
        ),
        CheckConstraint("size_bytes > 0", name="ck_media_size_bytes_positive"),
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[Optional[str]] = mapped_column(String(128), index=True)
    discovery_session_id: Mapped[Optional[str]] = mapped_column(
        String(128), index=True
    )
    farm_id: Mapped[Optional[str]] = mapped_column(
        ForeignKey("farms.id"), index=True
    )
    field_id: Mapped[Optional[str]] = mapped_column(
        ForeignKey("fields.id"), index=True
    )
    crop_id: Mapped[Optional[str]] = mapped_column(
        ForeignKey("crops.id"), index=True
    )
    storage_provider: Mapped[str] = mapped_column(String(16))
    storage_key: Mapped[str] = mapped_column(String(255), unique=True)
    original_filename: Mapped[str] = mapped_column(String(255))
    content_type: Mapped[str] = mapped_column(String(64))
    size_bytes: Mapped[int] = mapped_column(Integer)
    status: Mapped[str] = mapped_column(String(16), default="uploaded")
    width: Mapped[Optional[int]] = mapped_column(Integer)
    height: Mapped[Optional[int]] = mapped_column(Integer)
    checksum: Mapped[Optional[str]] = mapped_column(String(64))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )
