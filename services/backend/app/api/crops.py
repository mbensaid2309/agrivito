from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.agriculture import Crop, CropCreate
from app.services.agriculture.crop_service import CropService
from app.services.auth.dependencies import get_current_user
from app.services.auth.models import AuthenticatedUser

router = APIRouter(prefix="/crops", tags=["crops"])
service = CropService()


@router.post("", response_model=Crop, status_code=status.HTTP_201_CREATED)
def create_crop(
    payload: CropCreate,
    db: Session = Depends(get_db),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> Crop:
    return service.create(db, current_user.id, payload)


@router.get("", response_model=list[Crop])
def list_crops(
    db: Session = Depends(get_db),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> list[Crop]:
    return service.list(db, current_user.id)


@router.get("/{crop_id}", response_model=Crop)
def get_crop(
    crop_id: str,
    db: Session = Depends(get_db),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> Crop:
    crop = service.get(db, current_user.id, crop_id)
    if crop is None:
        raise HTTPException(status_code=404, detail="Crop not found.")
    return crop
