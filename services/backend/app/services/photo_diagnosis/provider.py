from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass

from app.schemas.ai_diagnosis import DiagnosisLanguage


@dataclass(frozen=True)
class VisionProviderRequest:
    image_bytes: bytes
    content_type: str
    prompt: str
    language: DiagnosisLanguage


class VisionProvider(ABC):
    name = "unknown"
    model = "unknown"

    @abstractmethod
    def analyze(self, request: VisionProviderRequest) -> object:
        raise NotImplementedError
