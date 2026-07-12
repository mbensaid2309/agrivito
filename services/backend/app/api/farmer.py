from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.agriculture import FarmerProfile, FarmerProfileCreate
from app.services.agriculture.farmer_service import FarmerService

router = APIRouter(prefix="/farmer", tags=["farmer"])
service = FarmerService()


@router.post("/profile", response_model=FarmerProfile, status_code=status.HTTP_201_CREATED)
def create_farmer_profile(
    payload: FarmerProfileCreate, db: Session = Depends(get_db)
) -> FarmerProfile:
    return service.create(db, payload)


@router.get("/profile", response_model=FarmerProfile)
def get_farmer_profile(db: Session = Depends(get_db)) -> FarmerProfile:
    profile = service.get(db)
    if profile is None:
        raise HTTPException(status_code=404, detail="Farmer profile not found.")
    return profile
