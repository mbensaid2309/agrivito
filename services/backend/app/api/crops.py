from fastapi import APIRouter, HTTPException, status

from app.schemas.agriculture import Crop, CropCreate
from app.services.agriculture.crop_service import CropService

router = APIRouter(prefix="/crops", tags=["crops"])
service = CropService()


@router.post("", response_model=Crop, status_code=status.HTTP_201_CREATED)
def create_crop(payload: CropCreate) -> Crop:
    return service.create(payload)


@router.get("", response_model=list[Crop])
def list_crops() -> list[Crop]:
    return service.list()


@router.get("/{crop_id}", response_model=Crop)
def get_crop(crop_id: str) -> Crop:
    crop = service.get(crop_id)
    if crop is None:
        raise HTTPException(status_code=404, detail="Crop not found.")
    return crop
