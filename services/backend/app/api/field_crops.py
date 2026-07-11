from fastapi import APIRouter, HTTPException, status

from app.schemas.agriculture import FieldCrop, FieldCropCreate
from app.services.agriculture.crop_service import CropService
from app.services.agriculture.field_crop_service import FieldCropService
from app.services.agriculture.field_service import FieldService

router = APIRouter(tags=["field crops"])
field_service = FieldService()
crop_service = CropService()
field_crop_service = FieldCropService()


def _require_field(field_id: str) -> None:
    if field_service.get(field_id) is None:
        raise HTTPException(status_code=404, detail="Field not found.")


@router.post(
    "/fields/{field_id}/crop",
    response_model=FieldCrop,
    status_code=status.HTTP_201_CREATED,
)
def associate_crop(field_id: str, payload: FieldCropCreate) -> FieldCrop:
    _require_field(field_id)
    if crop_service.get(payload.crop_id) is None:
        raise HTTPException(status_code=404, detail="Crop not found.")
    return field_crop_service.create(field_id, payload)


@router.get("/fields/{field_id}/crop", response_model=FieldCrop)
def get_associated_crop(field_id: str) -> FieldCrop:
    _require_field(field_id)
    association = field_crop_service.get_for_field(field_id)
    if association is None:
        raise HTTPException(status_code=404, detail="Field crop not found.")
    return association
