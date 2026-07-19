from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.agriculture import Farm, FarmCreate
from app.services.agriculture.farm_service import FarmService
from app.services.auth.dependencies import get_current_user
from app.services.auth.models import AuthenticatedUser

router = APIRouter(prefix="/farms", tags=["farms"])
service = FarmService()


@router.post("", response_model=Farm, status_code=status.HTTP_201_CREATED)
def create_farm(
    payload: FarmCreate,
    db: Session = Depends(get_db),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> Farm:
    return service.create(db, current_user.id, payload)


@router.get("", response_model=list[Farm])
def list_farms(
    db: Session = Depends(get_db),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> list[Farm]:
    return service.list(db, current_user.id)


@router.get("/{farm_id}", response_model=Farm)
def get_farm(
    farm_id: str,
    db: Session = Depends(get_db),
    current_user: AuthenticatedUser = Depends(get_current_user),
) -> Farm:
    farm = service.get(db, current_user.id, farm_id)
    if farm is None:
        raise HTTPException(status_code=404, detail="Farm not found.")
    return farm
