"""Add media metadata persistence."""

from typing import Optional, Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "20260714_02"
down_revision: Optional[str] = "20260712_01"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "media",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("user_id", sa.String(length=128), nullable=True),
        sa.Column("discovery_session_id", sa.String(length=128), nullable=True),
        sa.Column("farm_id", sa.String(length=36), nullable=True),
        sa.Column("field_id", sa.String(length=36), nullable=True),
        sa.Column("crop_id", sa.String(length=36), nullable=True),
        sa.Column("storage_provider", sa.String(length=16), nullable=False),
        sa.Column("storage_key", sa.String(length=255), nullable=False),
        sa.Column("original_filename", sa.String(length=255), nullable=False),
        sa.Column("content_type", sa.String(length=64), nullable=False),
        sa.Column("size_bytes", sa.Integer(), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("width", sa.Integer(), nullable=True),
        sa.Column("height", sa.Integer(), nullable=True),
        sa.Column("checksum", sa.String(length=64), nullable=True),
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
            "storage_provider IN ('local', 's3')",
            name="ck_media_storage_provider",
        ),
        sa.CheckConstraint(
            "status IN ('uploaded', 'failed', 'deleted')",
            name="ck_media_status",
        ),
        sa.CheckConstraint(
            "size_bytes > 0", name="ck_media_size_bytes_positive"
        ),
        sa.ForeignKeyConstraint(["farm_id"], ["farms.id"]),
        sa.ForeignKeyConstraint(["field_id"], ["fields.id"]),
        sa.ForeignKeyConstraint(["crop_id"], ["crops.id"]),
        sa.UniqueConstraint("storage_key", name="uq_media_storage_key"),
    )
    op.create_index("ix_media_user_id", "media", ["user_id"])
    op.create_index(
        "ix_media_discovery_session_id", "media", ["discovery_session_id"]
    )
    op.create_index("ix_media_farm_id", "media", ["farm_id"])
    op.create_index("ix_media_field_id", "media", ["field_id"])
    op.create_index("ix_media_crop_id", "media", ["crop_id"])
    op.execute(sa.text('ALTER TABLE "media" ENABLE ROW LEVEL SECURITY'))
    op.execute(
        sa.text(
            """
            DO $$
            DECLARE role_name text;
            BEGIN
              FOREACH role_name IN ARRAY ARRAY['anon', 'authenticated', 'service_role']
              LOOP
                IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = role_name) THEN
                  EXECUTE format('REVOKE ALL ON TABLE media FROM %I', role_name);
                END IF;
              END LOOP;
            END
            $$
            """
        )
    )


def downgrade() -> None:
    op.drop_table("media")
