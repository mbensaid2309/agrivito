from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.farm import Farm
from app.models.field import Field
from app.schemas.agriculture import FieldCreate
from app.services.agriculture.exceptions import (
    ResourceConflictError,
    ResourceNotFoundError,
)


class FieldService:
    def create(
        self, db: Session, owner_id: str, farm_id: str, payload: FieldCreate
    ) -> Field:
        if self._owned_farm(db, owner_id, farm_id) is None:
            raise ResourceNotFoundError("Farm not found.")
        field = Field(farm_id=farm_id, **payload.model_dump())
        db.add(field)
        try:
            db.commit()
        except IntegrityError as error:
            db.rollback()
            raise ResourceConflictError("Field could not be created.") from error
        db.refresh(field)
        return field

    def list_for_farm(
        self, db: Session, owner_id: str, farm_id: str
    ) -> list[Field]:
        if self._owned_farm(db, owner_id, farm_id) is None:
            raise ResourceNotFoundError("Farm not found.")
        statement = (
            select(Field)
            .where(Field.farm_id == farm_id)
            .order_by(Field.created_at)
        )
        return list(db.scalars(statement))

    def get(self, db: Session, owner_id: str, field_id: str) -> Field | None:
        return db.scalar(
            select(Field)
            .join(Farm, Field.farm_id == Farm.farm_id)
            .where(Field.field_id == field_id, Farm.user_id == owner_id)
        )

    @staticmethod
    def _owned_farm(db: Session, owner_id: str, farm_id: str) -> Farm | None:
        return db.scalar(
            select(Farm).where(Farm.farm_id == farm_id, Farm.user_id == owner_id)
        )
