from __future__ import annotations

from uuid import uuid4

from app.schemas.agriculture import Field, FieldCreate, utc_now
from app.services.agriculture.store import AgricultureStore, store


class FieldService:
    def __init__(self, data_store: AgricultureStore = store) -> None:
        self.store = data_store

    def create(self, farm_id: str, payload: FieldCreate) -> Field:
        field = Field(
            field_id=str(uuid4()),
            farm_id=farm_id,
            **payload.model_dump(),
            created_at=utc_now(),
        )
        self.store.fields[field.field_id] = field
        return field

    def list_for_farm(self, farm_id: str) -> list[Field]:
        return [field for field in self.store.fields.values() if field.farm_id == farm_id]

    def get(self, field_id: str) -> Field | None:
        return self.store.fields.get(field_id)
