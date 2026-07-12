from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.crop import Crop
from app.models.field import Field
from app.models.field_crop import FieldCrop
from app.schemas.agriculture import FieldCropCreate
from app.services.agriculture.exceptions import (
    ResourceConflictError,
    ResourceNotFoundError,
)


class FieldCropService:
    def create(
        self, db: Session, field_id: str, payload: FieldCropCreate
    ) -> FieldCrop:
        if db.get(Field, field_id) is None:
            raise ResourceNotFoundError("Field not found.")
        if db.get(Crop, payload.crop_id) is None:
            raise ResourceNotFoundError("Crop not found.")
        if payload.status == "active":
            active = db.scalar(
                select(FieldCrop).where(
                    FieldCrop.field_id == field_id,
                    FieldCrop.status == "active",
                )
            )
            if active is not None:
                raise ResourceConflictError(
                    "An active crop already exists for this field."
                )
        association = FieldCrop(field_id=field_id, **payload.model_dump())
        db.add(association)
        try:
            db.commit()
        except IntegrityError as error:
            db.rollback()
            raise ResourceConflictError(
                "An active crop already exists for this field."
            ) from error
        db.refresh(association)
        return association

    def get_for_field(self, db: Session, field_id: str) -> FieldCrop | None:
        if db.get(Field, field_id) is None:
            raise ResourceNotFoundError("Field not found.")
        statement = (
            select(FieldCrop)
            .where(FieldCrop.field_id == field_id)
            .order_by(FieldCrop.created_at.desc())
        )
        return db.scalar(statement)
