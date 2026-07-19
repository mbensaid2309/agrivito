from __future__ import annotations

from pathlib import Path
from typing import Generator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import select

from app.db.base import Base
from app.db.database import get_engine
from app.db.session import get_db
from app.main import app
from app.models.diagnosis import Diagnosis
from app.models.media import Media
from app.schemas.ai_diagnosis import DiagnosisContextUsed
from app.schemas.photo_diagnosis import (
    PhotoQualityResponse,
    PhotoQualitySignals,
)
from app.services.ai.exceptions import (
    AIProviderRateLimitError,
    AIProviderTimeoutError,
)
from app.services.photo_diagnosis.dependencies import (
    get_photo_diagnosis_orchestrator,
)
from app.services.photo_diagnosis.mock_provider import MockVisionProvider
from app.services.photo_diagnosis.orchestrator import PhotoDiagnosisOrchestrator
from app.services.photo_diagnosis.photo_quality import PhotoQualityEngine
from app.services.photo_diagnosis.provider import (
    VisionProvider,
    VisionProviderRequest,
)
from app.services.photo_diagnosis.trust_score import VisualTrustScoreEngine
from app.services.photo_diagnosis.usage_tracker import PhotoDiagnosisUsageTracker
from app.storage.dependencies import get_media_storage_provider
from app.storage.local_storage import LocalMediaStorage

JPEG = b"\xff\xd8\xff\xe0" + b"photo-content" * 100


class TimeoutVisionProvider(VisionProvider):
    name = "timeout"
    model = "mock"

    def analyze(self, request: VisionProviderRequest) -> object:
        raise AIProviderTimeoutError("secret timeout")


class RateLimitVisionProvider(VisionProvider):
    name = "rate-limit"
    model = "mock"

    def analyze(self, request: VisionProviderRequest) -> object:
        raise AIProviderRateLimitError("secret rate limit")


class UnsafeVisionProvider(MockVisionProvider):
    name = "unsafe-mock"

    def analyze(self, request: VisionProviderRequest) -> object:
        response = super().analyze(request)
        response["summary"] = "Maladie confirmée avec certitude."
        response["hypotheses"] = [
            {
                "label": "Maladie confirmée",
                "explanation": "Cause certainement identifiée.",
            }
        ]
        response["recommendations"] = ["Appliquer 25 ml de produit."]
        return response


@pytest.fixture
def photo_storage(tmp_path: Path) -> LocalMediaStorage:
    return LocalMediaStorage(str(tmp_path / "photo-diagnosis"))


@pytest.fixture
def photo_client(
    photo_storage: LocalMediaStorage,
) -> Generator[TestClient, None, None]:
    engine = get_engine()
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    orchestrator = PhotoDiagnosisOrchestrator(
        provider=MockVisionProvider(),
        storage=photo_storage,
        usage_tracker=PhotoDiagnosisUsageTracker(),
    )
    app.dependency_overrides[get_media_storage_provider] = lambda: photo_storage
    app.dependency_overrides[get_photo_diagnosis_orchestrator] = (
        lambda: orchestrator
    )
    with TestClient(app) as client:
        yield client
    app.dependency_overrides.clear()
    Base.metadata.drop_all(engine)


def test_photo_diagnosis_is_structured_and_persisted(
    photo_client: TestClient,
) -> None:
    media_id = _upload(photo_client, session="diagnosis-session")
    response = _diagnose(photo_client, media_id, "diagnosis-session")

    assert response.status_code == 200
    body = response.json()
    diagnosis = body["diagnosis"]
    assert diagnosis["media_id"] == media_id
    assert diagnosis["photo_quality"]["level"] in {"good", "acceptable"}
    assert diagnosis["observations"]
    assert diagnosis["hypotheses"]
    assert diagnosis["recommendations"]
    assert diagnosis["follow_up_questions"]
    assert diagnosis["precautions"]
    assert 0 <= diagnosis["trust_score"]["score"] <= 100
    assert body["usage"] == {
        "mode": "discovery",
        "diagnoses_used": 1,
        "diagnoses_limit": 1,
        "remaining": 0,
    }
    with next(get_db()) as db:
        record = db.scalar(select(Diagnosis))
        assert record is not None
        assert record.media_id == media_id
        assert record.diagnosis_type == "photo"
        assert record.provider == "mock"
        assert record.observations_json == diagnosis["observations"]


def test_media_id_is_required(photo_client: TestClient) -> None:
    response = photo_client.post("/discovery/photo-diagnosis", json={})
    assert response.status_code == 422


def test_missing_media_returns_404(photo_client: TestClient) -> None:
    response = photo_client.post(
        "/discovery/photo-diagnosis",
        json={
            "media_id": "00000000-0000-0000-0000-000000000000",
            "discovery_session_id": "missing-session",
        },
    )
    assert response.status_code == 404


def test_deleted_media_is_rejected(photo_client: TestClient) -> None:
    media_id = _upload(photo_client, session="deleted-session")
    with next(get_db()) as db:
        media = db.get(Media, media_id)
        media.status = "deleted"
        db.commit()
    response = _diagnose(photo_client, media_id, "deleted-session")
    assert response.status_code == 404


def test_non_image_media_is_rejected(
    photo_client: TestClient,
    photo_storage: LocalMediaStorage,
) -> None:
    media = Media(
        id="00000000-0000-0000-0000-000000000001",
        discovery_session_id="non-image-session",
        storage_provider="local",
        storage_key="media/file.txt",
        original_filename="file.txt",
        content_type="text/plain",
        size_bytes=4,
        status="uploaded",
    )
    with next(get_db()) as db:
        db.add(media)
        db.commit()
    response = _diagnose(photo_client, media.id, "non-image-session")
    assert response.status_code == 415
    assert not photo_storage.exists(media.storage_key)


def test_media_access_is_scoped_to_discovery_session(
    photo_client: TestClient,
) -> None:
    media_id = _upload(photo_client, session="owner-session")
    response = _diagnose(photo_client, media_id, "other-session")
    assert response.status_code == 404


@pytest.mark.parametrize(
    ("scenario", "level", "status", "retake"),
    [
        ("poor_photo", "poor", "completed", True),
        ("unusable_photo", "unusable", "insufficient", True),
    ],
)
def test_quality_scenarios_apply_safe_behavior(
    photo_client: TestClient,
    scenario: str,
    level: str,
    status: str,
    retake: bool,
) -> None:
    session = f"session-{scenario}"
    media_id = _upload(photo_client, session=session)
    response = _diagnose(photo_client, media_id, session, scenario)
    diagnosis = response.json()["diagnosis"]

    assert response.status_code == 200
    assert diagnosis["photo_quality"]["level"] == level
    assert diagnosis["photo_quality"]["retake_required"] is retake
    assert diagnosis["status"] == status
    assert diagnosis["response_mode"] == "questions_required"
    if status == "insufficient":
        assert diagnosis["hypotheses"] == []
        assert diagnosis["recommendations"] == []


def test_multiple_hypotheses_scenario(photo_client: TestClient) -> None:
    media_id = _upload(photo_client, session="multiple-session")
    response = _diagnose(
        photo_client,
        media_id,
        "multiple-session",
        "multiple_hypotheses",
    )
    assert len(response.json()["diagnosis"]["hypotheses"]) == 2


def test_visual_guardrails_remove_certainty_and_precise_dosage(
    photo_client: TestClient,
    photo_storage: LocalMediaStorage,
) -> None:
    media_id = _upload(photo_client, session="guardrail-session")
    app.dependency_overrides[get_photo_diagnosis_orchestrator] = lambda: (
        PhotoDiagnosisOrchestrator(
            provider=UnsafeVisionProvider(),
            storage=photo_storage,
            usage_tracker=PhotoDiagnosisUsageTracker(),
        )
    )
    response = _diagnose(photo_client, media_id, "guardrail-session")
    diagnosis = response.json()["diagnosis"]
    serialized = str(
        {
            "summary": diagnosis["summary"],
            "hypotheses": diagnosis["hypotheses"],
            "recommendations": diagnosis["recommendations"],
        }
    ).lower()
    assert response.status_code == 200
    assert "confirm" not in serialized
    assert "certain" not in serialized
    assert "25 ml" not in serialized
    assert diagnosis["recommendations"] == []


def test_invalid_provider_output_is_controlled_and_not_persisted(
    photo_client: TestClient,
) -> None:
    media_id = _upload(photo_client, session="invalid-session")
    response = _diagnose(
        photo_client,
        media_id,
        "invalid-session",
        "provider_invalid_output",
    )
    assert response.status_code == 502
    assert "summary" not in response.text.lower()
    with next(get_db()) as db:
        assert db.scalar(select(Diagnosis)) is None


@pytest.mark.parametrize(
    ("provider", "expected_status"),
    [(TimeoutVisionProvider(), 504), (RateLimitVisionProvider(), 503)],
)
def test_provider_errors_are_controlled_and_usage_is_released(
    photo_client: TestClient,
    photo_storage: LocalMediaStorage,
    provider: VisionProvider,
    expected_status: int,
) -> None:
    media_id = _upload(photo_client, session="provider-session")
    app.dependency_overrides[get_photo_diagnosis_orchestrator] = lambda: (
        PhotoDiagnosisOrchestrator(
            provider=provider,
            storage=photo_storage,
            usage_tracker=PhotoDiagnosisUsageTracker(),
        )
    )
    response = _diagnose(photo_client, media_id, "provider-session")
    assert response.status_code == expected_status
    assert "secret" not in response.text.lower()


def test_discovery_photo_diagnosis_limit_is_one(photo_client: TestClient) -> None:
    media_id = _upload(photo_client, session="limit-session")
    first = _diagnose(photo_client, media_id, "limit-session")
    second = _diagnose(photo_client, media_id, "limit-session")
    assert first.status_code == 200
    assert second.status_code == 429


@pytest.mark.parametrize(
    ("signal", "expected_level"),
    [(0.9, "good"), (0.35, "poor"), (0.08, "unusable")],
)
def test_photo_quality_engine_is_deterministic(
    signal: float, expected_level: str
) -> None:
    signals = _signals(signal)
    engine = PhotoQualityEngine()
    first = engine.calculate(signals=signals, size_bytes=4096)
    second = engine.calculate(signals=signals, size_bytes=4096)
    assert first == second
    assert first.level == expected_level
    assert 0 <= first.score <= 100
    assert first.retake_required is (expected_level in {"poor", "unusable"})


@pytest.mark.parametrize(
    ("score", "level"),
    [(80, "high"), (60, "medium"), (40, "low"), (39, "insufficient")],
)
def test_visual_trust_score_boundaries(score: int, level: str) -> None:
    assert VisualTrustScoreEngine.level_for(score) == level


def test_visual_trust_score_increases_with_context_and_quality() -> None:
    engine = VisualTrustScoreEngine()
    good_quality = PhotoQualityResponse(
        score=90,
        level="good",
        issues=[],
        retake_required=False,
        retake_instructions=[],
    )
    poor_quality = PhotoQualityResponse(
        score=30,
        level="unusable",
        issues=["Photo floue."],
        retake_required=True,
        retake_instructions=["Reprendre la photo."],
    )
    high = engine.calculate(
        photo_quality=good_quality,
        signals=_signals(0.95),
        context_used=DiagnosisContextUsed(
            farmer_profile=True, farm=True, field=True, crop=True
        ),
        question="Pourquoi les feuilles sont-elles tachées ?",
        provider_response_valid=True,
    )
    low = engine.calculate(
        photo_quality=poor_quality,
        signals=_signals(0.1),
        context_used=DiagnosisContextUsed(),
        question="",
        provider_response_valid=True,
    )
    assert high.score > low.score
    assert low.level == "insufficient"


def _upload(client: TestClient, *, session: str) -> str:
    response = client.post(
        "/discovery/media/upload",
        data={"discovery_session_id": session},
        files={"file": ("leaf.jpg", JPEG, "image/jpeg")},
    )
    assert response.status_code == 201
    return response.json()["media"]["id"]


def _diagnose(
    client: TestClient,
    media_id: str,
    session: str,
    question: str = "Pourquoi les feuilles sont-elles tachées ?",
):
    return client.post(
        "/discovery/photo-diagnosis",
        json={
            "media_id": media_id,
            "question": question,
            "language": "fr",
            "discovery_session_id": session,
        },
    )


def _signals(value: float) -> PhotoQualitySignals:
    return PhotoQualitySignals(
        brightness=value,
        sharpness=value,
        subject_visibility=value,
        distance=value,
        crop_identifiability=value,
        symptom_visibility=value,
    )
