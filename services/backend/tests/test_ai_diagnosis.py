from __future__ import annotations

from collections.abc import Generator

import pytest
from fastapi.testclient import TestClient

from app.db.base import Base
from app.db.database import get_engine
from app.main import app
from app.schemas.ai_diagnosis import AIDiagnosisRequest
from app.services.ai.dependencies import get_ai_orchestrator
from app.services.ai.exceptions import (
    AIInvalidResponseError,
    AIProviderRateLimitError,
    AIProviderTimeoutError,
)
from app.services.ai.mock_provider import MockAIProvider
from app.services.ai.orchestrator import AIOrchestrator
from app.services.ai.provider import AIProvider, AIProviderRequest
from app.services.ai.response_parser import AIResponseParser
from app.services.ai.trust_score import TrustScoreEngine, trust_level_for_score
from app.services.discovery.usage_tracker import DiscoveryUsageTracker


@pytest.fixture(autouse=True)
def reset_database() -> Generator[None, None, None]:
    engine = get_engine()
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    yield
    Base.metadata.drop_all(engine)
    app.dependency_overrides.clear()


def test_ai_diagnosis_without_context_is_structured() -> None:
    response = TestClient(app).post(
        "/ai/diagnosis",
        json={
            "question": "Pourquoi les feuilles de mes tomates jaunissent ?",
            "language": "fr",
            "discovery_session_id": "diagnosis-session",
        },
    )

    assert response.status_code == 200
    body = response.json()
    diagnosis = body["diagnosis"]
    assert diagnosis["summary"]
    assert diagnosis["observations"]
    assert diagnosis["hypotheses"]
    assert diagnosis["recommendations"]
    assert diagnosis["follow_up_questions"]
    assert diagnosis["precautions"]
    assert diagnosis["response_mode"] in {
        "reliable",
        "hypotheses",
        "questions_required",
        "refusal",
    }
    assert diagnosis["language"] == "fr"
    assert 0 <= diagnosis["trust_score"]["score"] <= 100
    assert body["usage"] == {
        "mode": "discovery",
        "questions_used": 1,
        "questions_limit": 3,
        "remaining": 2,
    }


def test_empty_question_is_rejected() -> None:
    response = TestClient(app).post(
        "/ai/diagnosis", json={"question": "   ", "language": "fr"}
    )

    assert response.status_code == 422


def test_complete_context_is_used_and_increases_score() -> None:
    client = TestClient(app)
    profile = client.post(
        "/farmer/profile",
        json={
            "user_id": "context-user",
            "display_name": "Ferme Atlas",
            "user_type": "farmer",
            "country": "Maroc",
            "region": "Souss-Massa",
            "preferred_language": "fr",
        },
    )
    farm = client.post(
        "/farms",
        json={
            "user_id": "context-user",
            "name": "Ferme Atlas",
            "country": "Maroc",
            "region": "Souss-Massa",
            "locality": "Taroudant",
            "total_area": 5,
            "area_unit": "hectare",
        },
    ).json()
    field = client.post(
        f"/farms/{farm['farm_id']}/fields",
        json={
            "name": "Parcelle nord",
            "area": 1.5,
            "area_unit": "hectare",
            "soil_type": "argileux",
            "water_access": "yes",
            "irrigation_type": "drip",
        },
    ).json()
    crop = client.post(
        "/crops",
        json={
            "name": "tomate",
            "category": "vegetable",
            "growth_stage": "flowering",
        },
    ).json()
    client.post(
        f"/fields/{field['field_id']}/crop",
        json={"crop_id": crop["crop_id"], "status": "active"},
    )
    assert profile.status_code == 201

    without_context = client.post(
        "/ai/diagnosis",
        json={
            "question": "Pourquoi les feuilles de mes tomates jaunissent ?",
            "language": "fr",
            "discovery_session_id": "without-context",
        },
    ).json()
    with_context = client.post(
        "/ai/diagnosis",
        json={
            "question": "Pourquoi les feuilles de mes tomates jaunissent ?",
            "language": "fr",
            "user_id": "context-user",
            "farm_id": farm["farm_id"],
            "field_id": field["field_id"],
            "crop_id": crop["crop_id"],
        },
    )

    assert with_context.status_code == 200
    body = with_context.json()
    assert body["context_used"] == {
        "farmer_profile": True,
        "farm": True,
        "field": True,
        "crop": True,
    }
    assert body["usage"]["mode"] == "authenticated"
    assert body["diagnosis"]["trust_score"]["score"] > (
        without_context["diagnosis"]["trust_score"]["score"]
    )


def test_missing_context_resource_returns_404() -> None:
    response = TestClient(app).post(
        "/ai/diagnosis",
        json={
            "question": "Pourquoi cette culture jaunit-elle ?",
            "farm_id": "missing",
        },
    )

    assert response.status_code == 404


@pytest.mark.parametrize(
    ("provider", "expected_status"),
    [
        ("timeout", 504),
        ("rate_limit", 503),
        ("invalid", 502),
    ],
)
def test_provider_errors_are_controlled(
    provider: str, expected_status: int
) -> None:
    implementations: dict[str, AIProvider] = {
        "timeout": RaisingProvider(AIProviderTimeoutError("timeout")),
        "rate_limit": RaisingProvider(AIProviderRateLimitError("rate limit")),
        "invalid": InvalidProvider(),
    }
    orchestrator = AIOrchestrator(
        provider=implementations[provider],
        usage_tracker=DiscoveryUsageTracker(),
    )
    app.dependency_overrides[get_ai_orchestrator] = lambda: orchestrator

    response = TestClient(app).post(
        "/ai/diagnosis", json={"question": "Pourquoi la plante jaunit-elle ?"}
    )

    assert response.status_code == expected_status
    assert "OpenAI" not in response.text


def test_mock_provider_is_deterministic() -> None:
    provider = MockAIProvider()
    request = AIProviderRequest("system", "user", "fr")

    assert provider.generate_diagnosis(request) == provider.generate_diagnosis(request)


def test_response_parser_accepts_one_fenced_json_correction() -> None:
    raw = """```json
    {
      "summary": "Résumé",
      "observations": [],
      "hypotheses": [],
      "recommendations": [],
      "follow_up_questions": [],
      "precautions": [],
      "response_mode": "questions_required"
    }
    ```"""

    parsed = AIResponseParser().parse(raw)

    assert parsed.summary == "Résumé"


def test_response_parser_rejects_invalid_response() -> None:
    with pytest.raises(AIInvalidResponseError):
        AIResponseParser().parse("not-json")


def test_trust_score_is_deterministic_and_contextual() -> None:
    request = AIDiagnosisRequest(
        question="Pourquoi les feuilles de mes tomates jaunissent ?"
    )
    engine = TrustScoreEngine()
    from app.schemas.ai_diagnosis import DiagnosisContextUsed

    empty_context = DiagnosisContextUsed()
    full_context = DiagnosisContextUsed(
        farmer_profile=True, farm=True, field=True, crop=True
    )

    first = engine.calculate(
        question=request.question,
        context_used=empty_context,
        provider_response_valid=True,
    )
    second = engine.calculate(
        question=request.question,
        context_used=empty_context,
        provider_response_valid=True,
    )
    complete = engine.calculate(
        question=request.question,
        context_used=full_context,
        provider_response_valid=True,
    )

    assert first == second
    assert complete.score > first.score


@pytest.mark.parametrize(
    ("score", "level"),
    [(80, "high"), (60, "medium"), (40, "low"), (39, "insufficient")],
)
def test_trust_score_boundaries(score: int, level: str) -> None:
    assert trust_level_for_score(score) == level


class RaisingProvider(AIProvider):
    name = "raising"

    def __init__(self, error: Exception) -> None:
        self._error = error

    def generate_diagnosis(self, request: AIProviderRequest) -> object:
        raise self._error


class InvalidProvider(AIProvider):
    name = "invalid"

    def generate_diagnosis(self, request: AIProviderRequest) -> object:
        return {"summary": "Missing fields"}
