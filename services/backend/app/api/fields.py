from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.agriculture import Field, FieldCreate
from app.services.agriculture.field_service import FieldService

router = APIRouter(tags=["fields"])
field_service = FieldService()


@router.post(
    "/farms/{farm_id}/fields",
    response_model=Field,
    status_code=status.HTTP_201_CREATED,
)
def create_field(
    farm_id: str, payload: FieldCreate, db: Session = Depends(get_db)
) -> Field:
    return field_service.create(db, farm_id, payload)


@router.get("/farms/{farm_id}/fields", response_model=list[Field])
def list_fields(farm_id: str, db: Session = Depends(get_db)) -> list[Field]:
    return field_service.list_for_farm(db, farm_id)


@router.get("/fields/{field_id}", response_model=Field)
def get_field(field_id: str, db: Session = Depends(get_db)) -> Field:
    field = field_service.get(db, field_id)
    if field is None:
        raise HTTPException(status_code=404, detail="Field not found.")
    return field
