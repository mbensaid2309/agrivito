from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.farm import Farm
from app.schemas.agriculture import FarmCreate
from app.services.agriculture.exceptions import ResourceConflictError


class FarmService:
    def create(self, db: Session, owner_id: str, payload: FarmCreate) -> Farm:
        farm = Farm(user_id=owner_id, **payload.model_dump())
        db.add(farm)
        try:
            db.commit()
        except IntegrityError as error:
            db.rollback()
            raise ResourceConflictError("Farm could not be created.") from error
        db.refresh(farm)
        return farm

    def list(self, db: Session, owner_id: str) -> list[Farm]:
        return list(
            db.scalars(
                select(Farm)
                .where(Farm.user_id == owner_id)
                .order_by(Farm.created_at)
            )
        )

    def get(self, db: Session, owner_id: str, farm_id: str) -> Farm | None:
        return db.scalar(
            select(Farm).where(Farm.farm_id == farm_id, Farm.user_id == owner_id)
        )
