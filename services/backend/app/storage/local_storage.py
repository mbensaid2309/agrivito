from pathlib import Path, PurePosixPath
from shutil import copyfileobj
from typing import BinaryIO
from uuid import uuid4

from app.storage.exceptions import MediaStorageOperationError
from app.storage.provider import MediaStorageProvider


class LocalMediaStorage(MediaStorageProvider):
    name = "local"

    def __init__(self, root_path: str) -> None:
        self._root = Path(root_path).expanduser().resolve()
        self._root.mkdir(parents=True, exist_ok=True)

    def save(
        self, file_object: BinaryIO, object_key: str, content_type: str
    ) -> None:
        del content_type
        target = self._resolve_key(object_key)
        target.parent.mkdir(parents=True, exist_ok=True)
        temporary = target.with_name(f".{target.name}.{uuid4().hex}.part")
        try:
            file_object.seek(0)
            with temporary.open("wb") as destination:
                copyfileobj(file_object, destination)
            temporary.replace(target)
        except OSError as error:
            temporary.unlink(missing_ok=True)
            raise MediaStorageOperationError(
                "Media could not be stored."
            ) from error

    def delete(self, object_key: str) -> None:
        target = self._resolve_key(object_key)
        try:
            target.unlink(missing_ok=True)
        except OSError as error:
            raise MediaStorageOperationError(
                "Media could not be deleted."
            ) from error

    def exists(self, object_key: str) -> bool:
        return self._resolve_key(object_key).is_file()

    def read(self, object_key: str) -> bytes:
        try:
            return self._resolve_key(object_key).read_bytes()
        except OSError as error:
            raise MediaStorageOperationError(
                "Media could not be read."
            ) from error

    def _resolve_key(self, object_key: str) -> Path:
        if not object_key or "\\" in object_key:
            raise MediaStorageOperationError("Invalid media storage key.")
        relative = PurePosixPath(object_key)
        if relative.is_absolute() or ".." in relative.parts:
            raise MediaStorageOperationError("Invalid media storage key.")
        target = self._root.joinpath(*relative.parts).resolve()
        try:
            target.relative_to(self._root)
        except ValueError as error:
            raise MediaStorageOperationError("Invalid media storage key.") from error
        return target
