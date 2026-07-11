from __future__ import annotations

from uuid import uuid4

from app.schemas.agriculture import Crop, CropCreate, utc_now
from app.services.agriculture.store import AgricultureStore, store


class CropService:
    def __init__(self, data_store: AgricultureStore = store) -> None:
        self.store = data_store

    def create(self, payload: CropCreate) -> Crop:
        crop = Crop(crop_id=str(uuid4()), **payload.model_dump(), created_at=utc_now())
        self.store.crops[crop.crop_id] = crop
        return crop

    def list(self) -> list[Crop]:
        return list(self.store.crops.values())

    def get(self, crop_id: str) -> Crop | None:
        return self.store.crops.get(crop_id)
