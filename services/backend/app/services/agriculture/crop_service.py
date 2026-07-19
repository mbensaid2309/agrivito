from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.crop import Crop
from app.schemas.agriculture import CropCreate
from app.services.agriculture.exceptions import ResourceConflictError


class CropService:
    def create(self, db: Session, owner_id: str, payload: CropCreate) -> Crop:
        crop = Crop(user_id=owner_id, **payload.model_dump())
        db.add(crop)
        try:
            db.commit()
        except IntegrityError as error:
            db.rollback()
            raise ResourceConflictError("Crop could not be created.") from error
        db.refresh(crop)
        return crop

    def list(self, db: Session, owner_id: str) -> list[Crop]:
        return list(
            db.scalars(
                select(Crop)
                .where(Crop.user_id == owner_id)
                .order_by(Crop.created_at)
            )
        )

    def get(self, db: Session, owner_id: str, crop_id: str) -> Crop | None:
        return db.scalar(
            select(Crop).where(Crop.crop_id == crop_id, Crop.user_id == owner_id)
        )
