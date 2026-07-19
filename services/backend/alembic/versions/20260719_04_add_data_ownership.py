"""Add authenticated ownership and text diagnosis support."""

from typing import Optional, Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "20260719_04"
down_revision: Optional[str] = "20260719_03"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("crops", sa.Column("user_id", sa.String(length=128), nullable=True))
    op.create_index("ix_crops_user_id", "crops", ["user_id"])
    op.alter_column("diagnoses", "media_id", existing_type=sa.String(36), nullable=True)
    op.alter_column(
        "diagnoses", "photo_quality_score", existing_type=sa.Integer(), nullable=True
    )
    op.alter_column(
        "diagnoses", "photo_quality_level", existing_type=sa.String(16), nullable=True
    )
    op.drop_constraint("ck_diagnoses_type_photo", "diagnoses", type_="check")
    op.drop_constraint("ck_diagnoses_photo_quality_score", "diagnoses", type_="check")
    op.create_check_constraint(
        "ck_diagnoses_type",
        "diagnoses",
        "diagnosis_type IN ('text', 'photo')",
    )
    op.create_check_constraint(
        "ck_diagnoses_photo_quality_score",
        "diagnoses",
        "photo_quality_score IS NULL OR photo_quality_score BETWEEN 0 AND 100",
    )
    op.execute(
        sa.text(
            """
            DO $$
            DECLARE table_name text;
            DECLARE role_name text;
            BEGIN
              FOREACH table_name IN ARRAY ARRAY[
                'farmer_profiles', 'farms', 'fields', 'crops', 'field_crops',
                'media', 'diagnoses'
              ] LOOP
                EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', table_name);
                FOREACH role_name IN ARRAY ARRAY['anon', 'authenticated', 'service_role']
                LOOP
                  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = role_name) THEN
                    EXECUTE format('REVOKE ALL ON TABLE %I FROM %I', table_name, role_name);
                  END IF;
                END LOOP;
              END LOOP;
            END
            $$
            """
        )
    )


def downgrade() -> None:
    op.execute(
        sa.text(
            """
            DO $$
            BEGIN
              IF EXISTS (
                SELECT 1 FROM diagnoses WHERE diagnosis_type = 'text'
              ) THEN
                RAISE EXCEPTION
                  'Cannot downgrade while authenticated text diagnoses exist';
              END IF;
            END
            $$
            """
        )
    )
    op.drop_constraint("ck_diagnoses_type", "diagnoses", type_="check")
    op.drop_constraint("ck_diagnoses_photo_quality_score", "diagnoses", type_="check")
    op.create_check_constraint(
        "ck_diagnoses_type_photo", "diagnoses", "diagnosis_type = 'photo'"
    )
    op.create_check_constraint(
        "ck_diagnoses_photo_quality_score",
        "diagnoses",
        "photo_quality_score BETWEEN 0 AND 100",
    )
    op.alter_column(
        "diagnoses", "photo_quality_level", existing_type=sa.String(16), nullable=False
    )
    op.alter_column(
        "diagnoses", "photo_quality_score", existing_type=sa.Integer(), nullable=False
    )
    op.alter_column("diagnoses", "media_id", existing_type=sa.String(36), nullable=False)
    op.drop_index("ix_crops_user_id", table_name="crops")
    op.drop_column("crops", "user_id")
