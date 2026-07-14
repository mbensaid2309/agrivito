from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, ConfigDict

MediaStatus = Literal["uploaded", "failed", "deleted"]


class MediaResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    original_filename: str
    content_type: str
    size_bytes: int
    storage_provider: str
    status: MediaStatus
    farm_id: Optional[str] = None
    field_id: Optional[str] = None
    crop_id: Optional[str] = None
    created_at: datetime


class MediaMetadata(MediaResponse):
    pass


class MediaUploadResponse(BaseModel):
    media: MediaResponse
