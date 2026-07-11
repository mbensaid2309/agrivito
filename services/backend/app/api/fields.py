from fastapi import APIRouter, HTTPException, status

from app.schemas.agriculture import Field, FieldCreate
from app.services.agriculture.farm_service import FarmService
from app.services.agriculture.field_service import FieldService

router = APIRouter(tags=["fields"])
farm_service = FarmService()
field_service = FieldService()


def _require_farm(farm_id: str) -> None:
    if farm_service.get(farm_id) is None:
        raise HTTPException(status_code=404, detail="Farm not found.")


@router.post(
    "/farms/{farm_id}/fields",
    response_model=Field,
    status_code=status.HTTP_201_CREATED,
)
def create_field(farm_id: str, payload: FieldCreate) -> Field:
    _require_farm(farm_id)
    return field_service.create(farm_id, payload)


@router.get("/farms/{farm_id}/fields", response_model=list[Field])
def list_fields(farm_id: str) -> list[Field]:
    _require_farm(farm_id)
    return field_service.list_for_farm(farm_id)


@router.get("/fields/{field_id}", response_model=Field)
def get_field(field_id: str) -> Field:
    field = field_service.get(field_id)
    if field is None:
        raise HTTPException(status_code=404, detail="Field not found.")
    return field
