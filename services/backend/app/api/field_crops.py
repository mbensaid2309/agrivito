from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.agriculture import FieldCrop, FieldCropCreate
from app.services.agriculture.field_crop_service import FieldCropService
from app.services.auth.dependencies import get_current_user
from app.services.auth.models import AuthenticatedUser

router = APIRouter(tags=["field crops"])
field_crop_service = FieldCropService()


@router.post(
    "/fields/{field_id}/crop",
    response_model=FieldCrop,
    status_code=status.HTTP_201_CREATED,
)
def associate_crop(
    field_id: str,
    payload: FieldCropCreate,
    db: Session = Depends(get_db),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> FieldCrop:
    return field_crop_service.create(db, current_user.id, field_id, payload)


@router.get("/fields/{field_id}/crop", response_model=FieldCrop)
def get_associated_crop(
    field_id: str,
    db: Session = Depends(get_db),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> FieldCrop:
    association = field_crop_service.get_for_field(db, current_user.id, field_id)
    if association is None:
        raise HTTPException(status_code=404, detail="Field crop not found.")
    return association
