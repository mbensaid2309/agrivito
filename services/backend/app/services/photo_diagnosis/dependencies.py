from functools import lru_cache

from app.core.config import Settings, get_settings
from app.services.photo_diagnosis.mock_provider import MockVisionProvider
from app.services.photo_diagnosis.openai_provider import OpenAIVisionProvider
from app.services.photo_diagnosis.orchestrator import PhotoDiagnosisOrchestrator
from app.services.photo_diagnosis.provider import VisionProvider
from app.services.photo_diagnosis.usage_tracker import PhotoDiagnosisUsageTracker
from app.storage.dependencies import get_media_storage_provider


def build_vision_provider(settings: Settings) -> VisionProvider:
    if settings.vision_mode == "mock":
        return MockVisionProvider()
    return OpenAIVisionProvider(
        api_key=settings.openai_api_key,
        model=settings.openai_vision_model,
        timeout_seconds=settings.vision_timeout_seconds,
    )


@lru_cache
def get_photo_diagnosis_usage_tracker() -> PhotoDiagnosisUsageTracker:
    return PhotoDiagnosisUsageTracker(
        get_settings().photo_diagnosis_discovery_limit
    )


def get_photo_diagnosis_orchestrator() -> PhotoDiagnosisOrchestrator:
    settings = get_settings()
    return PhotoDiagnosisOrchestrator(
        provider=build_vision_provider(settings),
        storage=get_media_storage_provider(),
        usage_tracker=get_photo_diagnosis_usage_tracker(),
    )
