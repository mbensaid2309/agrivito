from __future__ import annotations

import json

from pydantic import ValidationError

from app.schemas.ai_diagnosis import ProviderDiagnosisContent
from app.services.ai.exceptions import AIInvalidResponseError


class AIResponseParser:
    def parse(self, raw_response: object) -> ProviderDiagnosisContent:
        if isinstance(raw_response, ProviderDiagnosisContent):
            return raw_response

        candidate = raw_response
        if isinstance(raw_response, str):
            candidate = self._decode_json(raw_response)

        try:
            return ProviderDiagnosisContent.model_validate(candidate)
        except ValidationError as error:
            raise AIInvalidResponseError(
                "Provider response does not match the diagnosis schema."
            ) from error

    def _decode_json(self, raw_response: str) -> object:
        if not raw_response.strip():
            raise AIInvalidResponseError("Provider returned an empty response.")

        try:
            return json.loads(raw_response)
        except json.JSONDecodeError:
            corrected = raw_response.strip()
            if corrected.startswith("```json") and corrected.endswith("```"):
                corrected = corrected[7:-3].strip()
            elif corrected.startswith("```") and corrected.endswith("```"):
                corrected = corrected[3:-3].strip()
            else:
                raise AIInvalidResponseError("Provider returned invalid JSON.")

        try:
            return json.loads(corrected)
        except json.JSONDecodeError as error:
            raise AIInvalidResponseError("Provider returned invalid JSON.") from error
