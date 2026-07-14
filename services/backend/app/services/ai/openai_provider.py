from __future__ import annotations

from typing import Any

from openai import (
    APIConnectionError,
    APIStatusError,
    APITimeoutError,
    ContentFilterFinishReasonError,
    LengthFinishReasonError,
    OpenAI,
    OpenAIError,
    RateLimitError,
)

from app.schemas.ai_diagnosis import ProviderDiagnosisContent
from app.services.ai.exceptions import (
    AIConfigurationError,
    AIInvalidResponseError,
    AIProviderRateLimitError,
    AIProviderTimeoutError,
    AIProviderUnavailableError,
)
from app.services.ai.provider import AIProvider, AIProviderRequest


class OpenAIProvider(AIProvider):
    name = "openai"

    def __init__(
        self,
        *,
        api_key: str,
        model: str,
        timeout_seconds: float,
        client: Any | None = None,
    ) -> None:
        if not api_key:
            raise AIConfigurationError("OPENAI_API_KEY is required in live mode.")
        if not model:
            raise AIConfigurationError("OPENAI_MODEL is required in live mode.")
        self._model = model
        self._client = client or OpenAI(
            api_key=api_key,
            timeout=timeout_seconds,
            max_retries=1,
        )

    def generate_diagnosis(self, request: AIProviderRequest) -> object:
        try:
            response = self._client.responses.parse(
                model=self._model,
                input=[
                    {"role": "system", "content": request.system_prompt},
                    {"role": "user", "content": request.user_prompt},
                ],
                text_format=ProviderDiagnosisContent,
            )
        except (APITimeoutError, TimeoutError) as error:
            raise AIProviderTimeoutError("OpenAI request timed out.") from error
        except RateLimitError as error:
            raise AIProviderRateLimitError("OpenAI rate limit reached.") from error
        except APIConnectionError as error:
            raise AIProviderUnavailableError("OpenAI connection failed.") from error
        except APIStatusError as error:
            raise AIProviderUnavailableError("OpenAI request failed.") from error
        except (ContentFilterFinishReasonError, LengthFinishReasonError) as error:
            raise AIInvalidResponseError(
                "OpenAI could not produce a complete structured response."
            ) from error
        except OpenAIError as error:
            raise AIProviderUnavailableError("OpenAI provider failed.") from error

        if response.output_parsed is None:
            raise AIInvalidResponseError("OpenAI returned an empty structured response.")
        return response.output_parsed
