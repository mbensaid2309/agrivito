from __future__ import annotations

from dataclasses import dataclass

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.crop import Crop
from app.models.farm import Farm
from app.models.farmer_profile import FarmerProfile
from app.models.field import Field
from app.models.field_crop import FieldCrop
from app.schemas.ai_diagnosis import (
    AIDiagnosisRequest,
    AgriculturalContext,
    DiagnosisContextUsed,
)
from app.services.agriculture.exceptions import ResourceNotFoundError


@dataclass(frozen=True)
class BuiltAgriculturalContext:
    values: AgriculturalContext
    used: DiagnosisContextUsed


class AgriculturalContextBuilder:
    def build(
        self, db: Session, request: AIDiagnosisRequest
    ) -> BuiltAgriculturalContext:
        values: dict[str, object] = {}
        used = DiagnosisContextUsed()

        if request.user_id:
            profile = db.scalar(
                select(FarmerProfile).where(
                    FarmerProfile.user_id == request.user_id
                )
            )
            if profile is not None:
                values.update(
                    user_type=profile.user_type,
                    country=profile.country,
                    region=profile.region,
                    preferred_language=profile.preferred_language,
                )
                used.farmer_profile = True

        farm = self._get_farm(db, request.farm_id)
        if farm is not None:
            if request.user_id and farm.user_id != request.user_id:
                raise ResourceNotFoundError("Farm not found.")
            values.update(
                farm_name=farm.name,
                farm_locality=farm.locality,
                country=farm.country,
                region=farm.region,
                total_area=farm.total_area,
                area_unit=farm.area_unit,
            )
            used.farm = True

        field = self._get_field(db, request.field_id)
        if field is not None:
            if farm is not None and field.farm_id != farm.farm_id:
                raise ResourceNotFoundError("Field not found for this farm.")
            values.update(
                field_name=field.name,
                field_area=field.area,
                area_unit=field.area_unit,
                soil_type=field.soil_type,
                water_access=field.water_access,
                irrigation_type=field.irrigation_type,
            )
            used.field = True

        crop = self._get_crop(db, request.crop_id)
        if crop is not None:
            if field is not None:
                association = db.scalar(
                    select(FieldCrop).where(
                        FieldCrop.field_id == field.field_id,
                        FieldCrop.crop_id == crop.crop_id,
                    )
                )
                if association is None:
                    raise ResourceNotFoundError(
                        "Crop is not associated with this field."
                    )
            values.update(
                crop_name=crop.name,
                crop_category=crop.category,
                variety=crop.variety,
                season=crop.season,
                planting_date=(
                    crop.planting_date.isoformat() if crop.planting_date else None
                ),
                growth_stage=crop.growth_stage,
            )
            used.crop = True

        return BuiltAgriculturalContext(
            values=AgriculturalContext.model_validate(values),
            used=used,
        )

    def _get_farm(self, db: Session, farm_id: str | None) -> Farm | None:
        if farm_id is None:
            return None
        farm = db.get(Farm, farm_id)
        if farm is None:
            raise ResourceNotFoundError("Farm not found.")
        return farm

    def _get_field(self, db: Session, field_id: str | None) -> Field | None:
        if field_id is None:
            return None
        field = db.get(Field, field_id)
        if field is None:
            raise ResourceNotFoundError("Field not found.")
        return field

    def _get_crop(self, db: Session, crop_id: str | None) -> Crop | None:
        if crop_id is None:
            return None
        crop = db.get(Crop, crop_id)
        if crop is None:
            raise ResourceNotFoundError("Crop not found.")
        return crop
