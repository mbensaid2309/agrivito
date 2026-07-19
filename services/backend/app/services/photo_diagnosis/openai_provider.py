from __future__ import annotations

import base64
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

from app.schemas.photo_diagnosis import ProviderPhotoDiagnosisContent
from app.services.ai.exceptions import (
    AIConfigurationError,
    AIInvalidResponseError,
    AIProviderRateLimitError,
    AIProviderTimeoutError,
    AIProviderUnavailableError,
)
from app.services.photo_diagnosis.provider import (
    VisionProvider,
    VisionProviderRequest,
)


class OpenAIVisionProvider(VisionProvider):
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
            raise AIConfigurationError(
                "OPENAI_API_KEY is required in live Vision mode."
            )
        if not model:
            raise AIConfigurationError(
                "OPENAI_VISION_MODEL is required in live Vision mode."
            )
        self.model = model
        self._client = client or OpenAI(
            api_key=api_key,
            timeout=timeout_seconds,
            max_retries=1,
        )

    def analyze(self, request: VisionProviderRequest) -> object:
        image_data = base64.b64encode(request.image_bytes).decode("ascii")
        try:
            response = self._client.responses.parse(
                model=self.model,
                input=[
                    {
                        "role": "user",
                        "content": [
                            {"type": "input_text", "text": request.prompt},
                            {
                                "type": "input_image",
                                "image_url": (
                                    f"data:{request.content_type};base64,{image_data}"
                                ),
                            },
                        ],
                    }
                ],
                text_format=ProviderPhotoDiagnosisContent,
            )
        except (APITimeoutError, TimeoutError) as error:
            raise AIProviderTimeoutError("Vision request timed out.") from error
        except RateLimitError as error:
            raise AIProviderRateLimitError("Vision rate limit reached.") from error
        except APIConnectionError as error:
            raise AIProviderUnavailableError("Vision connection failed.") from error
        except APIStatusError as error:
            raise AIProviderUnavailableError("Vision request failed.") from error
        except (ContentFilterFinishReasonError, LengthFinishReasonError) as error:
            raise AIInvalidResponseError(
                "Vision could not produce a complete structured response."
            ) from error
        except OpenAIError as error:
            raise AIProviderUnavailableError("Vision provider failed.") from error

        if response.output_parsed is None:
            raise AIInvalidResponseError(
                "Vision returned an empty structured response."
            )
        return response.output_parsed
