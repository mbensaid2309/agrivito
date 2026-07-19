from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.agriculture import Field, FieldCreate
from app.services.agriculture.field_service import FieldService
from app.services.auth.dependencies import get_current_user
from app.services.auth.models import AuthenticatedUser

router = APIRouter(tags=["fields"])
field_service = FieldService()


@router.post(
    "/farms/{farm_id}/fields",
    response_model=Field,
    status_code=status.HTTP_201_CREATED,
)
def create_field(
    farm_id: str,
    payload: FieldCreate,
    db: Session = Depends(get_db),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> Field:
    return field_service.create(db, current_user.id, farm_id, payload)


@router.get("/farms/{farm_id}/fields", response_model=list[Field])
def list_fields(
    farm_id: str,
    db: Session = Depends(get_db),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> list[Field]:
    return field_service.list_for_farm(db, current_user.id, farm_id)


@router.get("/fields/{field_id}", response_model=Field)
def get_field(
    field_id: str,
    db: Session = Depends(get_db),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> Field:
    field = field_service.get(db, current_user.id, field_id)
    if field is None:
        raise HTTPException(status_code=404, detail="Field not found.")
    return field
