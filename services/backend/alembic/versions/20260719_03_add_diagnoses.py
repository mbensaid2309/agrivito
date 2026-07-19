"""Add persisted photo diagnoses."""

from typing import Optional, Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "20260719_03"
down_revision: Optional[str] = "20260714_02"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "diagnoses",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("media_id", sa.String(length=36), nullable=False),
        sa.Column("user_id", sa.String(length=128), nullable=True),
        sa.Column("discovery_session_id", sa.String(length=128), nullable=True),
        sa.Column("farm_id", sa.String(length=36), nullable=True),
        sa.Column("field_id", sa.String(length=36), nullable=True),
        sa.Column("crop_id", sa.String(length=36), nullable=True),
        sa.Column("diagnosis_type", sa.String(length=16), nullable=False),
        sa.Column("summary", sa.String(length=2000), nullable=False),
        sa.Column("observations_json", sa.JSON(), nullable=False),
        sa.Column("hypotheses_json", sa.JSON(), nullable=False),
        sa.Column("recommendations_json", sa.JSON(), nullable=False),
        sa.Column("follow_up_questions_json", sa.JSON(), nullable=False),
        sa.Column("precautions_json", sa.JSON(), nullable=False),
        sa.Column("photo_quality_score", sa.Integer(), nullable=False),
        sa.Column("photo_quality_level", sa.String(length=16), nullable=False),
        sa.Column("trust_score", sa.Integer(), nullable=False),
        sa.Column("trust_level", sa.String(length=16), nullable=False),
        sa.Column("response_mode", sa.String(length=32), nullable=False),
        sa.Column("language", sa.String(length=16), nullable=False),
        sa.Column("provider", sa.String(length=32), nullable=False),
        sa.Column("model", sa.String(length=160), nullable=True),
        sa.Column("status", sa.String(length=16), nullable=False),
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
        sa.CheckConstraint(
            "diagnosis_type = 'photo'", name="ck_diagnoses_type_photo"
        ),
        sa.CheckConstraint(
            "photo_quality_score BETWEEN 0 AND 100",
            name="ck_diagnoses_photo_quality_score",
        ),
        sa.CheckConstraint(
            "trust_score BETWEEN 0 AND 100", name="ck_diagnoses_trust_score"
        ),
        sa.CheckConstraint(
            "status IN ('completed', 'failed', 'insufficient')",
            name="ck_diagnoses_status",
        ),
        sa.ForeignKeyConstraint(
            ["media_id"], ["media.id"], ondelete="CASCADE"
        ),
        sa.ForeignKeyConstraint(["farm_id"], ["farms.id"]),
        sa.ForeignKeyConstraint(["field_id"], ["fields.id"]),
        sa.ForeignKeyConstraint(["crop_id"], ["crops.id"]),
    )
    op.create_index("ix_diagnoses_media_id", "diagnoses", ["media_id"])
    op.create_index("ix_diagnoses_user_id", "diagnoses", ["user_id"])
    op.create_index(
        "ix_diagnoses_discovery_session_id",
        "diagnoses",
        ["discovery_session_id"],
    )
    op.execute(sa.text('ALTER TABLE "diagnoses" ENABLE ROW LEVEL SECURITY'))
    op.execute(
        sa.text(
            """
            DO $$
            DECLARE role_name text;
            BEGIN
              FOREACH role_name IN ARRAY ARRAY['anon', 'authenticated', 'service_role']
              LOOP
                IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = role_name) THEN
                  EXECUTE format('REVOKE ALL ON TABLE diagnoses FROM %I', role_name);
                END IF;
              END LOOP;
            END
            $$
            """
        )
    )


def downgrade() -> None:
    op.drop_table("diagnoses")
