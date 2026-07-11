from __future__ import annotations

from app.schemas.agriculture import Crop, Farm, FarmerProfile, Field, FieldCrop


class AgricultureStore:
    def __init__(self) -> None:
        self.farmer_profile: FarmerProfile | None = None
        self.farms: dict[str, Farm] = {}
        self.fields: dict[str, Field] = {}
        self.crops: dict[str, Crop] = {}
        self.field_crops: dict[str, FieldCrop] = {}


store = AgricultureStore()
