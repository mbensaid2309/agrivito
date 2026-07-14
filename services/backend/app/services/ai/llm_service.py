from app.services.ai.provider import AIProvider, AIProviderRequest


class LLMService:
    """Compatibility facade delegating text generation to the active provider."""

    def __init__(self, provider: AIProvider) -> None:
        self._provider = provider

    def generate_response(self, request: AIProviderRequest) -> object:
        return self._provider.generate_diagnosis(request)
