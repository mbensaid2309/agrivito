from __future__ import annotations

from types import SimpleNamespace

import httpx
import pytest
from openai import APITimeoutError, RateLimitError

from app.services.ai.exceptions import (
    AIInvalidResponseError,
    AIProviderRateLimitError,
    AIProviderTimeoutError,
)
from app.services.ai.openai_provider import OpenAIProvider
from app.services.ai.provider import AIProviderRequest
from app.services.photo_diagnosis.openai_provider import OpenAIVisionProvider
from app.services.photo_diagnosis.provider import VisionProviderRequest


def test_openai_provider_transforms_timeout() -> None:
    request = httpx.Request("POST", "https://api.openai.com/v1/responses")
    provider = _provider_with_error(APITimeoutError(request=request))

    with pytest.raises(AIProviderTimeoutError, match="timed out"):
        provider.generate_diagnosis(AIProviderRequest("system", "user", "fr"))


def test_openai_provider_transforms_rate_limit() -> None:
    request = httpx.Request("POST", "https://api.openai.com/v1/responses")
    response = httpx.Response(429, request=request)
    provider = _provider_with_error(
        RateLimitError("limited", response=response, body=None)
    )

    with pytest.raises(AIProviderRateLimitError, match="rate limit"):
        provider.generate_diagnosis(AIProviderRequest("system", "user", "fr"))


def test_openai_provider_rejects_empty_response() -> None:
    client = SimpleNamespace(
        responses=SimpleNamespace(
            parse=lambda **kwargs: SimpleNamespace(output_parsed=None)
        )
    )
    provider = OpenAIProvider(
        api_key="test-key",
        model="test-model",
        timeout_seconds=1,
        client=client,
    )

    with pytest.raises(AIInvalidResponseError, match="empty"):
        provider.generate_diagnosis(AIProviderRequest("system", "user", "fr"))


def _provider_with_error(error: Exception) -> OpenAIProvider:
    def raise_error(**kwargs: object) -> object:
        raise error

    client = SimpleNamespace(
        responses=SimpleNamespace(parse=raise_error),
    )
    return OpenAIProvider(
        api_key="test-key",
        model="test-model",
        timeout_seconds=1,
        client=client,
    )


def test_openai_vision_provider_sends_private_bytes_as_data_url() -> None:
    captured: dict[str, object] = {}

    def parse(**kwargs: object) -> object:
        captured.update(kwargs)
        return SimpleNamespace(output_parsed={"valid": True})

    provider = OpenAIVisionProvider(
        api_key="test-key",
        model="vision-model",
        timeout_seconds=1,
        client=SimpleNamespace(responses=SimpleNamespace(parse=parse)),
    )
    result = provider.analyze(
        VisionProviderRequest(b"image-bytes", "image/png", "prompt", "fr")
    )
    content = captured["input"][0]["content"]
    assert result == {"valid": True}
    assert content[1]["type"] == "input_image"
    assert content[1]["image_url"].startswith("data:image/png;base64,")
    assert captured["model"] == "vision-model"


@pytest.mark.parametrize(
    ("error", "expected"),
    [
        (
            APITimeoutError(
                request=httpx.Request(
                    "POST", "https://api.openai.com/v1/responses"
                )
            ),
            AIProviderTimeoutError,
        ),
        (
            RateLimitError(
                "limited",
                response=httpx.Response(
                    429,
                    request=httpx.Request(
                        "POST", "https://api.openai.com/v1/responses"
                    ),
                ),
                body=None,
            ),
            AIProviderRateLimitError,
        ),
    ],
)
def test_openai_vision_provider_transforms_errors(
    error: Exception, expected: type[Exception]
) -> None:
    def raise_error(**kwargs: object) -> object:
        raise error

    provider = OpenAIVisionProvider(
        api_key="test-key",
        model="vision-model",
        timeout_seconds=1,
        client=SimpleNamespace(
            responses=SimpleNamespace(parse=raise_error)
        ),
    )
    with pytest.raises(expected):
        provider.analyze(
            VisionProviderRequest(b"bytes", "image/jpeg", "prompt", "fr")
        )


def test_openai_vision_provider_rejects_empty_output() -> None:
    provider = OpenAIVisionProvider(
        api_key="test-key",
        model="vision-model",
        timeout_seconds=1,
        client=SimpleNamespace(
            responses=SimpleNamespace(
                parse=lambda **kwargs: SimpleNamespace(output_parsed=None)
            )
        ),
    )
    with pytest.raises(AIInvalidResponseError, match="empty"):
        provider.analyze(
            VisionProviderRequest(b"bytes", "image/jpeg", "prompt", "fr")
        )
