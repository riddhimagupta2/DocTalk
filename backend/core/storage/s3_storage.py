"""
Amazon S3 / S3-compatible Object Storage implementation.
"""
import io
import os
from django.conf import settings
from .base import BaseStorageService
from ..utils.logging import get_logger

logger = get_logger("core.storage.s3")


class S3StorageService(BaseStorageService):
    """S3 bucket storage integration."""

    def __init__(self):
        self.bucket_name = os.getenv("AWS_STORAGE_BUCKET_NAME", "")
        self.region = os.getenv("AWS_S3_REGION_NAME", "us-east-1")
        self._client = None

    def _get_client(self):
        if self._client is None:
            import boto3

            self._client = boto3.client(
                "s3",
                aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
                aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
                region_name=self.region,
            )
        return self._client

    def save(
        self,
        file_bytes: bytes,
        path: str,
        content_type: str = "image/jpeg",
    ) -> str:
        client = self._get_client()
        client.put_object(
            Bucket=self.bucket_name,
            Key=path,
            Body=file_bytes,
            ContentType=content_type,
        )
        return path

    def read(self, path: str) -> bytes:
        client = self._get_client()
        response = client.get_object(Bucket=self.bucket_name, Key=path)
        return response["Body"].read()

    def delete(self, path: str) -> bool:
        client = self._get_client()
        client.delete_object(Bucket=self.bucket_name, Key=path)
        return True

    def get_url(self, path: str) -> str:
        client = self._get_client()
        return client.generate_presigned_url(
            "get_object",
            Params={"Bucket": self.bucket_name, "Key": path},
            ExpiresIn=3600 * 24,
        )
