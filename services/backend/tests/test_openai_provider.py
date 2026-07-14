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
