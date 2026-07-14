from abc import ABC, abstractmethod
from typing import BinaryIO


class MediaStorageProvider(ABC):
    name: str

    @abstractmethod
    def save(
        self, file_object: BinaryIO, object_key: str, content_type: str
    ) -> None:
        raise NotImplementedError

    @abstractmethod
    def delete(self, object_key: str) -> None:
        raise NotImplementedError

    @abstractmethod
    def exists(self, object_key: str) -> bool:
        raise NotImplementedError
