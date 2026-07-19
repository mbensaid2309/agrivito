from __future__ import annotations

from datetime import datetime, timedelta, timezone
from pathlib import Path
from types import SimpleNamespace

import jwt
import pytest
from cryptography.hazmat.primitives.asymmetric import rsa
from fastapi.testclient import TestClient
from sqlalchemy import select

from app.core.config import Settings
from app.db.base import Base
from app.db.database import get_engine
from app.db.session import get_db
from app.main import app
from app.models.diagnosis import Diagnosis
from app.models.media import Media
from app.services.auth.exceptions import InvalidAccessTokenError
from app.services.auth.mock_provider import MockAuthProvider
from app.services.auth.supabase_provider import SupabaseAuthProvider
from app.services.photo_diagnosis.dependencies import (
    get_photo_diagnosis_orchestrator,
)
from app.services.photo_diagnosis.mock_provider import MockVisionProvider
from app.services.photo_diagnosis.orchestrator import PhotoDiagnosisOrchestrator
from app.services.photo_diagnosis.usage_tracker import PhotoDiagnosisUsageTracker
from app.storage.dependencies import get_media_storage_provider
from app.storage.local_storage import LocalMediaStorage

JPEG = b"\xff\xd8\xff\xe0secure-image"
USER_A = "00000000-0000-0000-0000-00000000000a"
USER_B = "00000000-0000-0000-0000-00000000000b"


@pytest.fixture(autouse=True)
def isolated_database(tmp_path: Path):
    engine = get_engine()
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    storage = LocalMediaStorage(str(tmp_path / "media"))
    app.dependency_overrides[get_media_storage_provider] = lambda: storage
    app.dependency_overrides[get_photo_diagnosis_orchestrator] = lambda: (
        PhotoDiagnosisOrchestrator(
            provider=MockVisionProvider(),
            storage=storage,
            usage_tracker=PhotoDiagnosisUsageTracker(1),
        )
    )
    yield
    app.dependency_overrides.clear()
    Base.metadata.drop_all(engine)


def _client(token: str | None = None) -> TestClient:
    headers = {"Authorization": f"Bearer {token}"} if token else None
    return TestClient(app, headers=headers)


def test_public_and_private_endpoint_boundaries() -> None:
    anonymous = _client()
    assert anonymous.get("/health").status_code == 200
    assert anonymous.post(
        "/discovery/question",
        json={"question": "Pourquoi les feuilles jaunissent ?", "session_id": "s8"},
    ).status_code == 200
    assert anonymous.get("/farms").status_code == 401
    assert _client("modified-token").get("/farms").status_code == 401
    assert TestClient(
        app, headers={"Authorization": "Basic credentials"}
    ).get("/farms").status_code == 401
    assert _client("mock-valid-token").get("/farms").status_code == 200


def test_mock_provider_builds_current_user() -> None:
    user = MockAuthProvider().verify_access_token("mock-user-a")
    assert user.id == USER_A
    assert user.email == "a@agrivito.test"
    assert user.roles == ("authenticated",)
    assert user.provider == "mock"


def test_supabase_provider_validates_signature_and_required_claims() -> None:
    private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    issuer = "https://project.supabase.co/auth/v1"
    settings = Settings(
        auth_mode="live",
        auth_issuer=issuer,
        auth_audience="authenticated",
        supabase_jwks_url=f"{issuer}/.well-known/jwks.json",
    )
    provider = SupabaseAuthProvider(
        settings,
        jwks_client=SimpleNamespace(
            get_signing_key_from_jwt=lambda token: SimpleNamespace(
                key=private_key.public_key()
            )
        ),
    )
    now = datetime.now(timezone.utc)
    claims = {
        "sub": USER_A,
        "email": "a@example.test",
        "role": "authenticated",
        "iss": issuer,
        "aud": "authenticated",
        "iat": now,
        "exp": now + timedelta(minutes=5),
    }
    token = jwt.encode(claims, private_key, algorithm="RS256")
    user = provider.verify_access_token(token)
    assert user.id == USER_A
    assert user.provider == "supabase"

    invalid_claims = [
        {**claims, "exp": now - timedelta(seconds=1)},
        {**claims, "iss": "https://attacker.invalid/auth/v1"},
        {**claims, "aud": "other"},
        {key: value for key, value in claims.items() if key != "sub"},
    ]
    for invalid in invalid_claims:
        invalid_token = jwt.encode(invalid, private_key, algorithm="RS256")
        with pytest.raises(InvalidAccessTokenError):
            provider.verify_access_token(invalid_token)

    other_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    tampered = jwt.encode(claims, other_key, algorithm="RS256")
    with pytest.raises(InvalidAccessTokenError):
        provider.verify_access_token(tampered)


def test_supabase_provider_supports_explicit_legacy_hs256_secret() -> None:
    issuer = "https://legacy.supabase.co/auth/v1"
    secret = "test-only-secret-with-sufficient-length"
    provider = SupabaseAuthProvider(
        Settings(
            auth_mode="live",
            auth_issuer=issuer,
            auth_audience="authenticated",
            supabase_jwt_secret=secret,
        )
    )
    now = datetime.now(timezone.utc)
    token = jwt.encode(
        {
            "sub": USER_A,
            "iss": issuer,
            "aud": "authenticated",
            "iat": now,
            "exp": now + timedelta(minutes=5),
        },
        secret,
        algorithm="HS256",
    )

    assert provider.verify_access_token(token).id == USER_A


def test_payload_user_id_cannot_be_spoofed() -> None:
    response = _client("mock-user-a").post(
        "/farms",
        json={
            "user_id": USER_B,
            "name": "Tentative",
            "country": "Maroc",
            "region": "Souss-Massa",
            "locality": "Agadir",
        },
    )
    assert response.status_code == 422


def test_discovery_cannot_read_authenticated_agricultural_context() -> None:
    farm = _client("mock-user-a").post(
        "/farms",
        json={
            "name": "Ferme privée",
            "country": "Maroc",
            "region": "Souss-Massa",
            "locality": "Agadir",
        },
    ).json()

    response = _client().post(
        "/discovery/question",
        json={
            "question": "Que faut-il observer ?",
            "session_id": "anonymous-session",
            "farm_id": farm["farm_id"],
        },
    )

    assert response.status_code == 422


def test_authenticated_diagnosis_ignores_discovery_session() -> None:
    response = _client("mock-user-a").post(
        "/ai/diagnosis",
        json={
            "question": "Pourquoi les feuilles jaunissent ?",
            "discovery_session_id": "spoofed-session",
        },
    )

    assert response.status_code == 200
    assert response.json()["usage"]["mode"] == "authenticated"


def test_private_data_is_isolated_between_users() -> None:
    user_a = _client("mock-user-a")
    user_b = _client("mock-user-b")
    profile = user_a.post(
        "/farmer/profile",
        json={
            "display_name": "Agriculteur A",
            "user_type": "farmer",
            "country": "Maroc",
            "region": "Souss-Massa",
            "preferred_language": "fr",
        },
    )
    farm = user_a.post(
        "/farms",
        json={
            "name": "Ferme privée",
            "country": "Maroc",
            "region": "Souss-Massa",
            "locality": "Agadir",
        },
    ).json()
    field = user_a.post(
        f"/farms/{farm['farm_id']}/fields",
        json={"name": "Parcelle privée", "area": 1, "area_unit": "hectare"},
    ).json()
    crop = user_a.post(
        "/crops", json={"name": "tomate", "category": "vegetable"}
    ).json()
    assert user_a.post(
        f"/fields/{field['field_id']}/crop",
        json={"crop_id": crop["crop_id"], "status": "active"},
    ).status_code == 201
    upload = user_a.post(
        "/media/upload",
        data={
            "farm_id": farm["farm_id"],
            "field_id": field["field_id"],
            "crop_id": crop["crop_id"],
        },
        files={"file": ("leaf.jpg", JPEG, "image/jpeg")},
    )
    media_id = upload.json()["media"]["id"]

    assert profile.status_code == 201
    assert user_b.get("/farmer/profile").status_code == 404
    assert user_b.get("/farms").json() == []
    assert user_b.get(f"/farms/{farm['farm_id']}").status_code == 404
    assert user_b.get(f"/fields/{field['field_id']}").status_code == 404
    assert user_b.get(f"/crops/{crop['crop_id']}").status_code == 404
    assert user_b.get(f"/media/{media_id}").status_code == 404
    assert user_b.post(
        "/ai/photo-diagnosis", json={"media_id": media_id, "language": "fr"}
    ).status_code == 404

    text_diagnosis = user_a.post(
        "/ai/diagnosis",
        json={
            "question": "Pourquoi cette culture jaunit-elle ?",
            "farm_id": farm["farm_id"],
            "field_id": field["field_id"],
            "crop_id": crop["crop_id"],
        },
    )
    photo_diagnosis = user_a.post(
        "/ai/photo-diagnosis",
        json={
            "media_id": media_id,
            "question": "Que montre cette feuille ?",
            "farm_id": farm["farm_id"],
            "field_id": field["field_id"],
            "crop_id": crop["crop_id"],
        },
    )
    assert text_diagnosis.status_code == 200
    assert photo_diagnosis.status_code == 200
    with next(get_db()) as db:
        records = list(db.scalars(select(Diagnosis).order_by(Diagnosis.created_at)))
        stored_media = db.get(Media, media_id)
    assert stored_media is not None and stored_media.user_id == USER_A
    assert {record.diagnosis_type for record in records} == {"text", "photo"}
    assert all(record.user_id == USER_A for record in records)
