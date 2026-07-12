"""Create the initial agricultural persistence tables."""

from typing import Optional, Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "20260712_01"
down_revision: Optional[str] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _timestamps() -> list[sa.Column]:
    return [
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
    ]


def upgrade() -> None:
    op.create_table(
        "farmer_profiles",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("display_name", sa.String(length=160), nullable=False),
        sa.Column("user_type", sa.String(length=32), nullable=False),
        sa.Column("country", sa.String(length=100), nullable=False),
        sa.Column("region", sa.String(length=120), nullable=False),
        sa.Column("preferred_language", sa.String(length=16), nullable=False),
        sa.Column("is_discovery_mode", sa.Boolean(), nullable=False),
        *_timestamps(),
        sa.CheckConstraint(
            "user_type IN ('farmer', 'advisor', 'cooperative_member', 'unknown')",
            name="ck_farmer_profiles_user_type",
        ),
        sa.UniqueConstraint("user_id", name="uq_farmer_profiles_user_id"),
    )
    op.create_index("ix_farmer_profiles_user_id", "farmer_profiles", ["user_id"])

    op.create_table(
        "farms",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("name", sa.String(length=160), nullable=False),
        sa.Column("country", sa.String(length=100), nullable=False),
        sa.Column("region", sa.String(length=120), nullable=False),
        sa.Column("locality", sa.String(length=160), nullable=False),
        sa.Column("total_area", sa.Float(), nullable=True),
        sa.Column("area_unit", sa.String(length=24), nullable=False),
        *_timestamps(),
        sa.CheckConstraint(
            "area_unit IN ('hectare', 'square_meter', 'acre', 'unknown')",
            name="ck_farms_area_unit",
        ),
    )
    op.create_index("ix_farms_user_id", "farms", ["user_id"])

    op.create_table(
        "fields",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("farm_id", sa.String(length=36), nullable=False),
        sa.Column("name", sa.String(length=160), nullable=False),
        sa.Column("area", sa.Float(), nullable=False),
        sa.Column("area_unit", sa.String(length=24), nullable=False),
        sa.Column("soil_type", sa.String(length=120), nullable=True),
        sa.Column("water_access", sa.String(length=16), nullable=False),
        sa.Column("irrigation_type", sa.String(length=16), nullable=False),
        sa.Column("notes", sa.String(length=1000), nullable=True),
        *_timestamps(),
        sa.CheckConstraint(
            "area_unit IN ('hectare', 'square_meter', 'acre', 'unknown')",
            name="ck_fields_area_unit",
        ),
        sa.CheckConstraint(
            "water_access IN ('yes', 'no', 'seasonal', 'unknown')",
            name="ck_fields_water_access",
        ),
        sa.CheckConstraint(
            "irrigation_type IN ('none', 'drip', 'sprinkler', 'flood', 'manual', 'unknown')",
            name="ck_fields_irrigation_type",
        ),
        sa.ForeignKeyConstraint(["farm_id"], ["farms.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_fields_farm_id", "fields", ["farm_id"])

    op.create_table(
        "crops",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("name", sa.String(length=160), nullable=False),
        sa.Column("category", sa.String(length=32), nullable=False),
        sa.Column("variety", sa.String(length=160), nullable=True),
        sa.Column("season", sa.String(length=80), nullable=True),
        sa.Column("planting_date", sa.Date(), nullable=True),
        sa.Column("growth_stage", sa.String(length=32), nullable=False),
        sa.Column("notes", sa.String(length=1000), nullable=True),
        *_timestamps(),
        sa.CheckConstraint(
            "category IN ('vegetable', 'fruit_tree', 'cereal', 'legume', 'industrial_crop', 'other', 'unknown')",
            name="ck_crops_category",
        ),
        sa.CheckConstraint(
            "growth_stage IN ('seedling', 'vegetative', 'flowering', 'fruiting', 'harvest', 'post_harvest', 'unknown')",
            name="ck_crops_growth_stage",
        ),
    )
    op.create_index("ix_crops_name", "crops", ["name"])

    op.create_table(
        "field_crops",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("field_id", sa.String(length=36), nullable=False),
        sa.Column("crop_id", sa.String(length=36), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("start_date", sa.Date(), nullable=True),
        sa.Column("end_date", sa.Date(), nullable=True),
        *_timestamps(),
        sa.CheckConstraint(
            "status IN ('active', 'planned', 'completed', 'unknown')",
            name="ck_field_crops_status",
        ),
        sa.ForeignKeyConstraint(["field_id"], ["fields.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["crop_id"], ["crops.id"]),
    )
    op.create_index("ix_field_crops_field_id", "field_crops", ["field_id"])
    op.create_index("ix_field_crops_crop_id", "field_crops", ["crop_id"])
    op.create_index(
        "uq_field_crops_active_field",
        "field_crops",
        ["field_id"],
        unique=True,
        postgresql_where=sa.text("status = 'active'"),
    )
    for table_name in (
        "farmer_profiles",
        "farms",
        "fields",
        "crops",
        "field_crops",
    ):
        op.execute(sa.text(f'ALTER TABLE "{table_name}" ENABLE ROW LEVEL SECURITY'))


def downgrade() -> None:
    op.drop_table("field_crops")
    op.drop_table("crops")
    op.drop_table("fields")
    op.drop_table("farms")
    op.drop_table("farmer_profiles")
