from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass

from app.schemas.ai_diagnosis import DiagnosisLanguage


@dataclass(frozen=True)
class AIProviderRequest:
    system_prompt: str
    user_prompt: str
    language: DiagnosisLanguage


class AIProvider(ABC):
    name = "unknown"

    @abstractmethod
    def generate_diagnosis(self, request: AIProviderRequest) -> object:
        raise NotImplementedError
