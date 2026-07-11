from __future__ import annotations

from uuid import uuid4

from app.schemas.agriculture import Farm, FarmCreate, utc_now
from app.services.agriculture.store import AgricultureStore, store


class FarmService:
    def __init__(self, data_store: AgricultureStore = store) -> None:
        self.store = data_store

    def create(self, payload: FarmCreate) -> Farm:
        farm = Farm(
            farm_id=str(uuid4()), **payload.model_dump(), created_at=utc_now()
        )
        self.store.farms[farm.farm_id] = farm
        return farm

    def list(self) -> list[Farm]:
        return list(self.store.farms.values())

    def get(self, farm_id: str) -> Farm | None:
        return self.store.farms.get(farm_id)
