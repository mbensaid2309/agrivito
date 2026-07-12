from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.farmer_profile import FarmerProfile
from app.schemas.agriculture import FarmerProfileCreate
from app.services.agriculture.exceptions import ResourceConflictError


class FarmerService:
    def create(self, db: Session, payload: FarmerProfileCreate) -> FarmerProfile:
        existing = db.scalar(
            select(FarmerProfile).where(FarmerProfile.user_id == payload.user_id)
        )
        if existing is not None:
            raise ResourceConflictError("Farmer profile already exists.")
        profile = FarmerProfile(**payload.model_dump())
        db.add(profile)
        try:
            db.commit()
        except IntegrityError as error:
            db.rollback()
            raise ResourceConflictError("Farmer profile already exists.") from error
        db.refresh(profile)
        return profile

    def get(self, db: Session) -> FarmerProfile | None:
        return db.scalar(select(FarmerProfile).order_by(FarmerProfile.created_at))
