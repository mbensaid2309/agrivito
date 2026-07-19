from __future__ import annotations

from datetime import date, datetime, timezone
from typing import Literal, Optional

from pydantic import BaseModel, ConfigDict, Field as PydanticField, field_validator

UserType = Literal["farmer", "advisor", "cooperative_member", "unknown"]
WaterAccess = Literal["yes", "no", "seasonal", "unknown"]
IrrigationType = Literal["none", "drip", "sprinkler", "flood", "manual", "unknown"]
CropCategory = Literal[
    "vegetable", "fruit_tree", "cereal", "legume", "industrial_crop", "other", "unknown"
]
GrowthStage = Literal[
    "seedling", "vegetative", "flowering", "fruiting", "harvest", "post_harvest", "unknown"
]
FieldCropStatus = Literal["active", "planned", "completed", "unknown"]
AreaUnit = Literal["hectare", "square_meter", "acre", "unknown"]


class AgricultureModel(BaseModel):
    model_config = ConfigDict(from_attributes=True, extra="forbid")

    @field_validator("*", mode="before")
    @classmethod
    def strip_text(cls, value: object) -> object:
        return value.strip() if isinstance(value, str) else value


class FarmerProfileCreate(AgricultureModel):
    display_name: str = PydanticField(min_length=1)
    user_type: UserType = "unknown"
    country: str = PydanticField(min_length=1)
    region: str = PydanticField(min_length=1)
    preferred_language: str = PydanticField(min_length=1)
    is_discovery_mode: bool = False


class FarmerProfile(FarmerProfileCreate):
    user_id: str
    created_at: datetime


class FarmCreate(AgricultureModel):
    name: str = PydanticField(min_length=1)
    country: str = PydanticField(min_length=1)
    region: str = PydanticField(min_length=1)
    locality: str = PydanticField(min_length=1)
    total_area: Optional[float] = PydanticField(default=None, gt=0)
    area_unit: AreaUnit = "unknown"


class Farm(FarmCreate):
    farm_id: str
    user_id: str
    created_at: datetime


class FieldCreate(AgricultureModel):
    name: str = PydanticField(min_length=1)
    area: float = PydanticField(gt=0)
    area_unit: AreaUnit = "unknown"
    soil_type: Optional[str] = None
    water_access: WaterAccess = "unknown"
    irrigation_type: IrrigationType = "unknown"
    notes: Optional[str] = None


class Field(FieldCreate):
    field_id: str
    farm_id: str
    created_at: datetime


class CropCreate(AgricultureModel):
    name: str = PydanticField(min_length=1)
    category: CropCategory = "unknown"
    variety: Optional[str] = None
    season: Optional[str] = None
    planting_date: Optional[date] = None
    growth_stage: GrowthStage = "unknown"
    notes: Optional[str] = None


class Crop(CropCreate):
    crop_id: str
    user_id: Optional[str] = None
    created_at: datetime


class FieldCropCreate(AgricultureModel):
    crop_id: str = PydanticField(min_length=1)
    status: FieldCropStatus = "active"
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class FieldCrop(FieldCropCreate):
    field_crop_id: str
    field_id: str
    created_at: datetime


def utc_now() -> datetime:
    return datetime.now(timezone.utc)
