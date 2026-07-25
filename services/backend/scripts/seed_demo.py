"""Create the deterministic Sprint 8.5 demo context without duplicates."""

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.database import get_engine
from app.models.crop import Crop
from app.models.farm import Farm
from app.models.farmer_profile import FarmerProfile
from app.models.field import Field
from app.models.field_crop import FieldCrop

DEMO_USER_ID = "00000000-0000-0000-0000-000000000001"


def seed_demo() -> None:
    with Session(get_engine()) as db:
        profile = db.scalar(
            select(FarmerProfile).where(FarmerProfile.user_id == DEMO_USER_ID)
        )
        if profile is None:
            db.add(
                FarmerProfile(
                    user_id=DEMO_USER_ID,
                    display_name="Agriculteur de démonstration",
                    user_type="farmer",
                    country="Maroc",
                    region="Meknès",
                    preferred_language="fr",
                    is_discovery_mode=False,
                )
            )

        farm = db.scalar(
            select(Farm).where(
                Farm.user_id == DEMO_USER_ID,
                Farm.name == "Ferme Atlas",
            )
        )
        if farm is None:
            farm = Farm(
                user_id=DEMO_USER_ID,
                name="Ferme Atlas",
                country="Maroc",
                region="Meknès",
                locality="Meknès",
                total_area=12.5,
                area_unit="hectare",
            )
            db.add(farm)
            db.flush()

        field = db.scalar(
            select(Field).where(
                Field.farm_id == farm.farm_id,
                Field.name == "Parcelle Nord",
            )
        )
        if field is None:
            field = Field(
                farm_id=farm.farm_id,
                name="Parcelle Nord",
                area=3.0,
                area_unit="hectare",
                soil_type="limono-argileux",
                water_access="yes",
                irrigation_type="drip",
                notes="Données fictives pour la démonstration Agrivito.",
            )
            db.add(field)
            db.flush()

        crop = db.scalar(
            select(Crop).where(
                Crop.user_id == DEMO_USER_ID,
                Crop.name == "Tomate",
                Crop.variety == "Roma",
            )
        )
        if crop is None:
            crop = Crop(
                user_id=DEMO_USER_ID,
                name="Tomate",
                category="vegetable",
                variety="Roma",
                season="Printemps-été",
                growth_stage="flowering",
                notes="Données fictives pour la démonstration Agrivito.",
            )
            db.add(crop)
            db.flush()

        association = db.scalar(
            select(FieldCrop).where(
                FieldCrop.field_id == field.field_id,
                FieldCrop.status == "active",
            )
        )
        if association is None:
            db.add(
                FieldCrop(
                    field_id=field.field_id,
                    crop_id=crop.crop_id,
                    status="active",
                )
            )
        db.commit()


if __name__ == "__main__":
    seed_demo()
    print("Données de démonstration Agrivito prêtes.")
