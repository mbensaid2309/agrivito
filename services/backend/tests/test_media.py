from __future__ import annotations

import asyncio
from io import BytesIO
from pathlib import Path
from typing import BinaryIO, Generator
from unittest.mock import MagicMock

import pytest
from botocore.exceptions import ClientError
from fastapi import UploadFile
from fastapi.testclient import TestClient
from sqlalchemy import select
from sqlalchemy.exc import SQLAlchemyError

from app.core.config import get_settings
from app.db.base import Base
from app.db.database import get_engine
from app.db.session import get_db
from app.main import app
from app.models.media import Media
from app.services.media.exceptions import MediaPersistenceError
from app.services.media.media_service import MediaService
from app.services.media.usage_tracker import DiscoveryPhotoUsageTracker
from app.storage.dependencies import get_media_storage_provider
from app.storage.exceptions import MediaStorageOperationError
from app.storage.local_storage import LocalMediaStorage
from app.storage.provider import MediaStorageProvider
from app.storage.s3_storage import S3MediaStorage

JPEG = b"\xff\xd8\xff\xe0" + b"jpeg-content"
PNG = b"\x89PNG\r\n\x1a\n" + b"png-content"
WEBP = b"RIFF\x10\x00\x00\x00WEBP" + b"webp-content"


@pytest.fixture
def media_storage(tmp_path: Path) -> LocalMediaStorage:
    return LocalMediaStorage(str(tmp_path / "media-root"))


@pytest.fixture
def media_client(
    media_storage: LocalMediaStorage,
) -> Generator[TestClient, None, None]:
    engine = get_engine()
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    app.dependency_overrides[get_media_storage_provider] = lambda: media_storage
    with TestClient(app) as client:
        yield client
    app.dependency_overrides.clear()
    Base.metadata.drop_all(engine)


@pytest.mark.parametrize(
    ("filename", "content_type", "content", "expected_filename"),
    [
        ("tomate.jpg", "image/jpeg", JPEG, "tomate.jpg"),
        ("feuille.png", "image/png", PNG, "feuille.png"),
        ("culture.webp", "image/webp", WEBP, "culture.webp"),
    ],
)
def test_upload_supported_images_and_read_metadata(
    media_client: TestClient,
    media_storage: LocalMediaStorage,
    filename: str,
    content_type: str,
    content: bytes,
    expected_filename: str,
) -> None:
    response = media_client.post(
        "/media/upload",
        files={"file": (filename, content, content_type)},
    )

    assert response.status_code == 201
    media = response.json()["media"]
    assert media["original_filename"] == expected_filename
    assert media["content_type"] == content_type
    assert media["size_bytes"] == len(content)
    assert media["storage_provider"] == "local"
    assert media["status"] == "uploaded"
    assert "storage_key" not in media
    assert str(media_storage._root) not in response.text

    metadata = media_client.get(f"/media/{media['id']}")
    assert metadata.status_code == 200
    assert metadata.json() == media


def test_storage_keys_are_unique_and_generated_by_backend(
    media_client: TestClient,
) -> None:
    first = media_client.post(
        "/media/upload", files={"file": ("same.jpg", JPEG, "image/jpeg")}
    )
    second = media_client.post(
        "/media/upload", files={"file": ("same.jpg", JPEG, "image/jpeg")}
    )

    assert first.status_code == second.status_code == 201
    with next(get_db()) as db:
        keys = list(db.scalars(select(Media.storage_key)))
    assert len(keys) == 2
    assert len(set(keys)) == 2
    assert all(key.startswith("media/") and key.endswith(".jpg") for key in keys)


def test_dangerous_filename_is_neutralized(media_client: TestClient) -> None:
    response = media_client.post(
        "/media/upload",
        files={"file": ("../../secret.jpg", JPEG, "image/jpeg")},
    )

    assert response.status_code == 201
    assert response.json()["media"]["original_filename"] == "secret.jpg"
    assert ".." not in response.text


@pytest.mark.parametrize(
    ("files", "expected_status"),
    [
        ({"file": ("empty.jpg", b"", "image/jpeg")}, 400),
        ({"file": ("notes.txt", b"not-an-image", "text/plain")}, 415),
        ({"file": ("fake.jpg", PNG, "image/jpeg")}, 415),
    ],
)
def test_invalid_files_are_rejected(
    media_client: TestClient,
    files: dict[str, tuple[str, bytes, str]],
    expected_status: int,
) -> None:
    response = media_client.post("/media/upload", files=files)

    assert response.status_code == expected_status
    assert "data/media" not in response.text
    with next(get_db()) as db:
        assert db.scalar(select(Media)) is None


def test_oversized_file_is_rejected(
    media_storage: LocalMediaStorage,
) -> None:
    settings = get_settings()
    small_settings = settings.__class__(
        **{
            **settings.__dict__,
            "media_max_size_mb": 1,
        }
    )
    service = MediaService(
        media_storage,
        small_settings,
        DiscoveryPhotoUsageTracker(),
    )
    upload = UploadFile(
        filename="large.jpg",
        file=BytesIO(b"\xff\xd8\xff" + b"x" * (1024 * 1024)),
        headers={"content-type": "image/jpeg"},
    )

    with next(get_db()) as db:
        with pytest.raises(Exception) as error:
            asyncio.run(service.upload(db, upload))
    assert getattr(error.value, "status_code", None) == 413


def test_valid_and_incoherent_agricultural_relations(
    media_client: TestClient,
) -> None:
    farm_one = _create_farm(media_client, "Ferme une")
    farm_two = _create_farm(media_client, "Ferme deux")
    field = media_client.post(
        f"/farms/{farm_one}/fields",
        json={"name": "Parcelle", "area": 1, "area_unit": "hectare"},
    ).json()["field_id"]
    crop = media_client.post(
        "/crops",
        json={"name": "tomate", "category": "vegetable"},
    ).json()["crop_id"]

    accepted = media_client.post(
        "/media/upload",
        data={"farm_id": farm_one, "field_id": field, "crop_id": crop},
        files={"file": ("tomate.jpg", JPEG, "image/jpeg")},
    )
    incoherent = media_client.post(
        "/media/upload",
        data={"farm_id": farm_two, "field_id": field},
        files={"file": ("tomate.jpg", JPEG, "image/jpeg")},
    )
    missing = media_client.post(
        "/media/upload",
        data={"crop_id": "missing"},
        files={"file": ("tomate.jpg", JPEG, "image/jpeg")},
    )

    assert accepted.status_code == 201
    assert accepted.json()["media"]["crop_id"] == crop
    assert incoherent.status_code == 409
    assert missing.status_code == 404


def test_storage_failure_creates_no_metadata(
    media_client: TestClient,
) -> None:
    failing = FailingStorage()
    app.dependency_overrides[get_media_storage_provider] = lambda: failing

    response = media_client.post(
        "/media/upload", files={"file": ("tomate.jpg", JPEG, "image/jpeg")}
    )

    assert response.status_code == 503
    assert "credential" not in response.text.lower()
    with next(get_db()) as db:
        assert db.scalar(select(Media)) is None


def test_database_failure_deletes_stored_file(
    media_storage: LocalMediaStorage,
) -> None:
    database = MagicMock()
    database.flush.side_effect = SQLAlchemyError("database secret")
    service = MediaService(
        media_storage,
        get_settings(),
        DiscoveryPhotoUsageTracker(),
    )
    upload = UploadFile(
        filename="tomate.jpg",
        file=BytesIO(JPEG),
        headers={"content-type": "image/jpeg"},
    )

    with pytest.raises(MediaPersistenceError):
        asyncio.run(service.upload(database, upload))

    assert list(media_storage._root.rglob("*.jpg")) == []
    database.rollback.assert_called_once()


def test_discovery_mode_is_limited_to_one_photo(
    media_client: TestClient,
) -> None:
    payload = {"discovery_session_id": "photo-session"}
    first = media_client.post(
        "/media/upload",
        data=payload,
        files={"file": ("first.jpg", JPEG, "image/jpeg")},
    )
    second = media_client.post(
        "/media/upload",
        data={**payload, "user_id": "   "},
        files={"file": ("second.jpg", JPEG, "image/jpeg")},
    )

    assert first.status_code == 201
    assert second.status_code == 429
    assert "create an account" in second.text.lower()


def test_missing_media_returns_404(media_client: TestClient) -> None:
    response = media_client.get("/media/00000000-0000-0000-0000-000000000000")

    assert response.status_code == 404


def test_local_storage_save_delete_exists_and_blocks_traversal(
    media_storage: LocalMediaStorage,
    tmp_path: Path,
) -> None:
    key = "media/2026/07/test.jpg"
    media_storage.save(BytesIO(JPEG), key, "image/jpeg")
    assert media_storage.exists(key)
    assert media_storage.read(key) == JPEG
    media_storage.delete(key)
    assert not media_storage.exists(key)

    with pytest.raises(MediaStorageOperationError):
        media_storage.save(BytesIO(JPEG), "../../outside.jpg", "image/jpeg")
    assert not (tmp_path / "outside.jpg").exists()


def test_s3_storage_uses_private_object_operations_without_real_aws() -> None:
    client = FakeS3Client()
    storage = S3MediaStorage("private-bucket", "eu-west-3", client=client)

    storage.save(BytesIO(JPEG), "media/2026/07/id.jpg", "image/jpeg")
    assert client.put_kwargs == {
        "Bucket": "private-bucket",
        "Key": "media/2026/07/id.jpg",
        "Body": client.put_kwargs["Body"],
        "ContentType": "image/jpeg",
    }
    assert "ACL" not in client.put_kwargs
    assert storage.exists("media/2026/07/id.jpg")
    assert storage.read("media/2026/07/id.jpg") == JPEG
    storage.delete("media/2026/07/id.jpg")
    assert client.deleted_key == "media/2026/07/id.jpg"


def test_s3_missing_object_returns_false() -> None:
    storage = S3MediaStorage(
        "private-bucket", "eu-west-3", client=MissingS3Client()
    )

    assert not storage.exists("media/missing.jpg")


def _create_farm(client: TestClient, name: str) -> str:
    response = client.post(
        "/farms",
        json={
            "user_id": f"user-{name}",
            "name": name,
            "country": "Maroc",
            "region": "Souss-Massa",
            "locality": "Taroudant",
            "area_unit": "hectare",
        },
    )
    return response.json()["farm_id"]


class FailingStorage(MediaStorageProvider):
    name = "local"

    def save(
        self, file_object: BinaryIO, object_key: str, content_type: str
    ) -> None:
        raise MediaStorageOperationError("disk path secret")

    def delete(self, object_key: str) -> None:
        pass

    def exists(self, object_key: str) -> bool:
        return False

    def read(self, object_key: str) -> bytes:
        raise MediaStorageOperationError("disk path secret")


class FakeS3Client:
    def __init__(self) -> None:
        self.put_kwargs: dict[str, object] = {}
        self.deleted_key: str | None = None

    def put_object(self, **kwargs: object) -> None:
        self.put_kwargs = kwargs

    def head_object(self, **kwargs: object) -> None:
        return None

    def delete_object(self, **kwargs: object) -> None:
        self.deleted_key = str(kwargs["Key"])

    def get_object(self, **kwargs: object) -> dict[str, BytesIO]:
        return {"Body": BytesIO(JPEG)}


class MissingS3Client(FakeS3Client):
    def head_object(self, **kwargs: object) -> None:
        raise ClientError(
            {
                "Error": {"Code": "404", "Message": "missing"},
                "ResponseMetadata": {"HTTPStatusCode": 404},
            },
            "HeadObject",
        )
