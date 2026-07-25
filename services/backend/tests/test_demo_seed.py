from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.db.base import Base
from app.db.database import get_engine
from app.models.crop import Crop
from app.models.farm import Farm
from app.models.farmer_profile import FarmerProfile
from app.models.field import Field
from app.models.field_crop import FieldCrop
from scripts.seed_demo import DEMO_USER_ID, seed_demo


def test_demo_seed_is_complete_and_idempotent() -> None:
    Base.metadata.create_all(get_engine())
    seed_demo()
    seed_demo()

    with Session(get_engine()) as db:
        assert db.scalar(
            select(func.count()).select_from(FarmerProfile).where(
                FarmerProfile.user_id == DEMO_USER_ID
            )
        ) == 1
        assert db.scalar(
            select(func.count()).select_from(Farm).where(Farm.user_id == DEMO_USER_ID)
        ) == 1
        assert db.scalar(select(func.count()).select_from(Field)) == 1
        assert db.scalar(
            select(func.count()).select_from(Crop).where(Crop.user_id == DEMO_USER_ID)
        ) == 1
        assert db.scalar(select(func.count()).select_from(FieldCrop)) == 1

        crop = db.scalar(select(Crop).where(Crop.user_id == DEMO_USER_ID))
        assert crop is not None
        assert crop.name == "Tomate"
        assert crop.variety == "Roma"
        assert crop.growth_stage == "flowering"
