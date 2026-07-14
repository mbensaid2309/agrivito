from datetime import datetime, timezone
from hashlib import sha256
from io import BytesIO
from pathlib import PurePath
import re
from typing import Optional
from uuid import UUID, uuid4

from fastapi import UploadFile, status
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.core.config import Settings
from app.models.crop import Crop
from app.models.farm import Farm
from app.models.field import Field
from app.models.media import Media
from app.services.agriculture.exceptions import (
    ResourceConflictError,
    ResourceNotFoundError,
)
from app.services.media.exceptions import (
    MediaPersistenceError,
    MediaStorageUnavailableError,
    MediaValidationError,
)
from app.services.media.usage_tracker import DiscoveryPhotoUsageTracker
from app.storage.exceptions import MediaStorageError
from app.storage.provider import MediaStorageProvider

MIME_EXTENSIONS = {
    "image/jpeg": "jpg",
    "image/png": "png",
    "image/webp": "webp",
}


class MediaService:
    def __init__(
        self,
        storage: MediaStorageProvider,
        settings: Settings,
        usage_tracker: DiscoveryPhotoUsageTracker,
    ) -> None:
        self._storage = storage
        self._settings = settings
        self._usage_tracker = usage_tracker

    async def upload(
        self,
        db: Session,
        file: UploadFile,
        user_id: Optional[str] = None,
        discovery_session_id: Optional[str] = None,
        farm_id: Optional[str] = None,
        field_id: Optional[str] = None,
        crop_id: Optional[str] = None,
    ) -> Media:
        user_id = self._clean_optional(user_id)
        discovery_session_id = self._clean_optional(discovery_session_id)
        farm_id = self._clean_optional(farm_id)
        field_id = self._clean_optional(field_id)
        crop_id = self._clean_optional(crop_id)
        self._validate_relations(db, farm_id, field_id, crop_id)
        content_type = (file.content_type or "").lower()
        content = await self._read_and_validate(file, content_type)
        media_id = str(uuid4())
        now = datetime.now(timezone.utc)
        storage_key = self._build_storage_key(media_id, content_type, now)
        original_filename = self._safe_filename(file.filename, content_type)
        reserved_session = (
            discovery_session_id if discovery_session_id and not user_id else None
        )
        if reserved_session:
            self._usage_tracker.reserve(reserved_session)

        stored = False
        try:
            self._storage.save(BytesIO(content), storage_key, content_type)
            stored = True
            media = Media(
                id=media_id,
                user_id=user_id,
                discovery_session_id=discovery_session_id,
                farm_id=farm_id,
                field_id=field_id,
                crop_id=crop_id,
                storage_provider=self._storage.name,
                storage_key=storage_key,
                original_filename=original_filename,
                content_type=content_type,
                size_bytes=len(content),
                status="uploaded",
                checksum=sha256(content).hexdigest(),
            )
            db.add(media)
            db.flush()
            db.commit()
            return media
        except MediaStorageError as error:
            db.rollback()
            if reserved_session:
                self._usage_tracker.release(reserved_session)
            raise MediaStorageUnavailableError() from error
        except SQLAlchemyError as error:
            db.rollback()
            if stored:
                try:
                    self._storage.delete(storage_key)
                except MediaStorageError:
                    pass
            if reserved_session:
                self._usage_tracker.release(reserved_session)
            raise MediaPersistenceError() from error

    def get(self, db: Session, media_id: str) -> Optional[Media]:
        try:
            UUID(media_id)
        except ValueError:
            return None
        return db.get(Media, media_id)

    async def _read_and_validate(
        self, file: UploadFile, content_type: str
    ) -> bytes:
        if content_type not in self._settings.media_allowed_mime_types:
            raise MediaValidationError(
                "Unsupported media type.",
                status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            )
        max_bytes = self._settings.media_max_size_mb * 1024 * 1024
        content = await file.read(max_bytes + 1)
        if not content:
            raise MediaValidationError(
                "The uploaded file is empty.", status.HTTP_400_BAD_REQUEST
            )
        if len(content) > max_bytes:
            raise MediaValidationError(
                "The uploaded file is too large.",
                status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            )
        if self._detected_content_type(content) != content_type:
            raise MediaValidationError(
                "Uploaded content does not match an allowed image format.",
                status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            )
        return content

    def _validate_relations(
        self,
        db: Session,
        farm_id: Optional[str],
        field_id: Optional[str],
        crop_id: Optional[str],
    ) -> None:
        farm = db.get(Farm, farm_id) if farm_id else None
        if farm_id and farm is None:
            raise ResourceNotFoundError("Farm not found.")
        field = db.get(Field, field_id) if field_id else None
        if field_id and field is None:
            raise ResourceNotFoundError("Field not found.")
        if crop_id and db.get(Crop, crop_id) is None:
            raise ResourceNotFoundError("Crop not found.")
        if farm_id and field is not None and field.farm_id != farm_id:
            raise ResourceConflictError("Field does not belong to the selected farm.")

    @staticmethod
    def _detected_content_type(content: bytes) -> Optional[str]:
        if content.startswith(b"\xff\xd8\xff"):
            return "image/jpeg"
        if content.startswith(b"\x89PNG\r\n\x1a\n"):
            return "image/png"
        if (
            len(content) >= 12
            and content.startswith(b"RIFF")
            and content[8:12] == b"WEBP"
        ):
            return "image/webp"
        return None

    @staticmethod
    def _build_storage_key(
        media_id: str, content_type: str, created_at: datetime
    ) -> str:
        extension = MIME_EXTENSIONS[content_type]
        return (
            f"media/{created_at.year:04d}/{created_at.month:02d}/"
            f"{media_id}.{extension}"
        )

    @staticmethod
    def _safe_filename(filename: Optional[str], content_type: str) -> str:
        supplied = (filename or "upload").replace("\\", "/")
        base_name = PurePath(supplied).name
        stem = PurePath(base_name).stem
        safe_stem = re.sub(r"[^\w.-]+", "_", stem, flags=re.UNICODE).strip("._")
        safe_stem = safe_stem[:180] or "upload"
        return f"{safe_stem}.{MIME_EXTENSIONS[content_type]}"

    @staticmethod
    def _clean_optional(value: Optional[str]) -> Optional[str]:
        if value is None:
            return None
        cleaned = value.strip()
        return cleaned or None
