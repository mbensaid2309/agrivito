from app.core.config import Settings, get_settings
from app.services.ai.mock_provider import MockAIProvider
from app.services.ai.openai_provider import OpenAIProvider
from app.services.ai.orchestrator import AIOrchestrator
from app.services.ai.provider import AIProvider
from app.services.discovery.usage_tracker import get_discovery_usage_tracker


def build_ai_provider(settings: Settings) -> AIProvider:
    if settings.ai_mode == "mock":
        return MockAIProvider()
    return OpenAIProvider(
        api_key=settings.openai_api_key,
        model=settings.openai_model,
        timeout_seconds=settings.openai_timeout_seconds,
    )


def get_ai_orchestrator() -> AIOrchestrator:
    return AIOrchestrator(
        provider=build_ai_provider(get_settings()),
        usage_tracker=get_discovery_usage_tracker(),
    )
