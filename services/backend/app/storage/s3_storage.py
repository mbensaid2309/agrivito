from typing import Any, BinaryIO, Optional

import boto3
from botocore.exceptions import BotoCoreError, ClientError

from app.storage.exceptions import (
    MediaStorageConfigurationError,
    MediaStorageOperationError,
)
from app.storage.provider import MediaStorageProvider


class S3MediaStorage(MediaStorageProvider):
    name = "s3"

    def __init__(
        self,
        bucket: str,
        region: str,
        client: Optional[Any] = None,
    ) -> None:
        if not bucket or not region:
            raise MediaStorageConfigurationError(
                "S3 media storage configuration is incomplete."
            )
        self._bucket = bucket
        self._client = client or boto3.client("s3", region_name=region)

    def save(
        self, file_object: BinaryIO, object_key: str, content_type: str
    ) -> None:
        try:
            file_object.seek(0)
            self._client.put_object(
                Bucket=self._bucket,
                Key=object_key,
                Body=file_object,
                ContentType=content_type,
            )
        except (BotoCoreError, ClientError) as error:
            raise MediaStorageOperationError(
                "Media could not be stored."
            ) from error

    def delete(self, object_key: str) -> None:
        try:
            self._client.delete_object(Bucket=self._bucket, Key=object_key)
        except (BotoCoreError, ClientError) as error:
            raise MediaStorageOperationError(
                "Media could not be deleted."
            ) from error

    def exists(self, object_key: str) -> bool:
        try:
            self._client.head_object(Bucket=self._bucket, Key=object_key)
            return True
        except ClientError as error:
            status_code = error.response.get("ResponseMetadata", {}).get(
                "HTTPStatusCode"
            )
            error_code = error.response.get("Error", {}).get("Code")
            if status_code == 404 or error_code in {"404", "NoSuchKey", "NotFound"}:
                return False
            raise MediaStorageOperationError(
                "Media availability could not be checked."
            ) from error
        except BotoCoreError as error:
            raise MediaStorageOperationError(
                "Media availability could not be checked."
            ) from error

    def read(self, object_key: str) -> bytes:
        try:
            response = self._client.get_object(
                Bucket=self._bucket,
                Key=object_key,
            )
            return bytes(response["Body"].read())
        except (BotoCoreError, ClientError, KeyError, AttributeError) as error:
            raise MediaStorageOperationError(
                "Media could not be read."
            ) from error
