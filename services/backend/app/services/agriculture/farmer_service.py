from __future__ import annotations

from app.schemas.agriculture import FarmerProfile, FarmerProfileCreate, utc_now
from app.services.agriculture.store import AgricultureStore, store


class FarmerService:
    def __init__(self, data_store: AgricultureStore = store) -> None:
        self.store = data_store

    def create(self, payload: FarmerProfileCreate) -> FarmerProfile:
        profile = FarmerProfile(**payload.model_dump(), created_at=utc_now())
        self.store.farmer_profile = profile
        return profile

    def get(self) -> FarmerProfile | None:
        return self.store.farmer_profile
