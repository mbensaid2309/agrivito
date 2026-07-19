from __future__ import annotations

import json

from pydantic import ValidationError

from app.schemas.photo_diagnosis import ProviderPhotoDiagnosisContent
from app.services.ai.exceptions import AIInvalidResponseError


class VisionResponseParser:
    def parse(self, raw_response: object) -> ProviderPhotoDiagnosisContent:
        if isinstance(raw_response, ProviderPhotoDiagnosisContent):
            return raw_response
        candidate = raw_response
        if isinstance(raw_response, str):
            if not raw_response.strip():
                raise AIInvalidResponseError("Vision returned an empty response.")
            try:
                candidate = json.loads(raw_response)
            except json.JSONDecodeError as error:
                raise AIInvalidResponseError(
                    "Vision returned invalid JSON."
                ) from error
        try:
            return ProviderPhotoDiagnosisContent.model_validate(candidate)
        except ValidationError as error:
            raise AIInvalidResponseError(
                "Vision response does not match the expected schema."
            ) from error
