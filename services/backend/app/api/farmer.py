from fastapi import APIRouter, HTTPException, status

from app.schemas.agriculture import FarmerProfile, FarmerProfileCreate
from app.services.agriculture.farmer_service import FarmerService

router = APIRouter(prefix="/farmer", tags=["farmer"])
service = FarmerService()


@router.post("/profile", response_model=FarmerProfile, status_code=status.HTTP_201_CREATED)
def create_farmer_profile(payload: FarmerProfileCreate) -> FarmerProfile:
    return service.create(payload)


@router.get("/profile", response_model=FarmerProfile)
def get_farmer_profile() -> FarmerProfile:
    profile = service.get()
    if profile is None:
        raise HTTPException(status_code=404, detail="Farmer profile not found.")
    return profile
