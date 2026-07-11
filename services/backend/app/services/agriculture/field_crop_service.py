from __future__ import annotations

from uuid import uuid4

from app.schemas.agriculture import FieldCrop, FieldCropCreate, utc_now
from app.services.agriculture.store import AgricultureStore, store


class FieldCropService:
    def __init__(self, data_store: AgricultureStore = store) -> None:
        self.store = data_store

    def create(self, field_id: str, payload: FieldCropCreate) -> FieldCrop:
        association = FieldCrop(
            field_crop_id=str(uuid4()),
            field_id=field_id,
            **payload.model_dump(),
            created_at=utc_now(),
        )
        self.store.field_crops[field_id] = association
        return association

    def get_for_field(self, field_id: str) -> FieldCrop | None:
        return self.store.field_crops.get(field_id)
