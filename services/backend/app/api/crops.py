from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.agriculture import Crop, CropCreate
from app.services.agriculture.crop_service import CropService

router = APIRouter(prefix="/crops", tags=["crops"])
service = CropService()


@router.post("", response_model=Crop, status_code=status.HTTP_201_CREATED)
def create_crop(payload: CropCreate, db: Session = Depends(get_db)) -> Crop:
    return service.create(db, payload)


@router.get("", response_model=list[Crop])
def list_crops(db: Session = Depends(get_db)) -> list[Crop]:
    return service.list(db)


@router.get("/{crop_id}", response_model=Crop)
def get_crop(crop_id: str, db: Session = Depends(get_db)) -> Crop:
    crop = service.get(db, crop_id)
    if crop is None:
        raise HTTPException(status_code=404, detail="Crop not found.")
    return crop
