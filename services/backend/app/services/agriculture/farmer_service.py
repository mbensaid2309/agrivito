from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.farmer_profile import FarmerProfile
from app.schemas.agriculture import FarmerProfileCreate
from app.services.agriculture.exceptions import ResourceConflictError


class FarmerService:
    def create(
        self, db: Session, owner_id: str, payload: FarmerProfileCreate
    ) -> FarmerProfile:
        existing = db.scalar(
            select(FarmerProfile).where(FarmerProfile.user_id == owner_id)
        )
        if existing is not None:
            raise ResourceConflictError("Farmer profile already exists.")
        profile = FarmerProfile(user_id=owner_id, **payload.model_dump())
        db.add(profile)
        try:
            db.commit()
        except IntegrityError as error:
            db.rollback()
            raise ResourceConflictError("Farmer profile already exists.") from error
        db.refresh(profile)
        return profile

    def get(self, db: Session, owner_id: str) -> FarmerProfile | None:
        return db.scalar(
            select(FarmerProfile).where(FarmerProfile.user_id == owner_id)
        )
