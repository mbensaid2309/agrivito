from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.agriculture import Farm, FarmCreate
from app.services.agriculture.farm_service import FarmService

router = APIRouter(prefix="/farms", tags=["farms"])
service = FarmService()


@router.post("", response_model=Farm, status_code=status.HTTP_201_CREATED)
def create_farm(payload: FarmCreate, db: Session = Depends(get_db)) -> Farm:
    return service.create(db, payload)


@router.get("", response_model=list[Farm])
def list_farms(db: Session = Depends(get_db)) -> list[Farm]:
    return service.list(db)


@router.get("/{farm_id}", response_model=Farm)
def get_farm(farm_id: str, db: Session = Depends(get_db)) -> Farm:
    farm = service.get(db, farm_id)
    if farm is None:
        raise HTTPException(status_code=404, detail="Farm not found.")
    return farm
