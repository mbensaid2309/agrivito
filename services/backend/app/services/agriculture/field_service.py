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
    def create(self, db: Session, farm_id: str, payload: FieldCreate) -> Field:
        if db.get(Farm, farm_id) is None:
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

    def list_for_farm(self, db: Session, farm_id: str) -> list[Field]:
        if db.get(Farm, farm_id) is None:
            raise ResourceNotFoundError("Farm not found.")
        statement = (
            select(Field)
            .where(Field.farm_id == farm_id)
            .order_by(Field.created_at)
        )
        return list(db.scalars(statement))

    def get(self, db: Session, field_id: str) -> Field | None:
        return db.get(Field, field_id)
