from typing import Optional

import pytest
from fastapi.testclient import TestClient

from app.db.base import Base
from app.db.database import get_engine
from app.main import app


@pytest.fixture(autouse=True)
def reset_agriculture_database() -> None:
    engine = get_engine()
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    yield
    Base.metadata.drop_all(engine)


@pytest.fixture
def client() -> TestClient:
    return TestClient(app)


def test_farmer_profile_flow(client: TestClient) -> None:
    payload = {
        "user_id": "user-1",
        "display_name": "Ferme Atlas",
        "user_type": "farmer",
        "country": "Maroc",
        "region": "Souss-Massa",
        "preferred_language": "fr",
        "is_discovery_mode": False,
    }
    created = client.post("/farmer/profile", json=payload)
    fetched = client.get("/farmer/profile")

    assert created.status_code == 201
    assert fetched.status_code == 200
    assert fetched.json()["display_name"] == "Ferme Atlas"
    duplicate = client.post("/farmer/profile", json=payload)
    assert duplicate.status_code == 409

    second_client = TestClient(app)
    persisted = second_client.get("/farmer/profile")
    assert persisted.status_code == 200
    assert persisted.json()["user_id"] == "user-1"


def test_farm_field_crop_flow(client: TestClient) -> None:
    farm_response = client.post(
        "/farms",
        json={
            "user_id": "user-1",
            "name": "Ferme Atlas",
            "country": "Maroc",
            "region": "Souss-Massa",
            "locality": "Taroudant",
            "total_area": 4.5,
            "area_unit": "hectare",
        },
    )
    assert farm_response.status_code == 201
    farm_id = farm_response.json()["farm_id"]
    assert client.get("/farms").status_code == 200
    assert client.get(f"/farms/{farm_id}").status_code == 200

    field_response = client.post(
        f"/farms/{farm_id}/fields",
        json={
            "name": "Parcelle nord",
            "area": 1.2,
            "area_unit": "hectare",
            "soil_type": "argileux",
            "water_access": "seasonal",
            "irrigation_type": "drip",
        },
    )
    assert field_response.status_code == 201
    field_id = field_response.json()["field_id"]
    assert client.get(f"/farms/{farm_id}/fields").status_code == 200
    assert client.get(f"/fields/{field_id}").status_code == 200
    missing_crop = client.post(
        f"/fields/{field_id}/crop",
        json={"crop_id": "missing", "status": "active"},
    )
    assert missing_crop.status_code == 404

    crop_response = client.post(
        "/crops",
        json={
            "name": "tomate",
            "category": "vegetable",
            "variety": "Roma",
            "growth_stage": "vegetative",
        },
    )
    assert crop_response.status_code == 201
    crop_id = crop_response.json()["crop_id"]
    assert client.get("/crops").status_code == 200
    assert client.get(f"/crops/{crop_id}").status_code == 200

    association = client.post(
        f"/fields/{field_id}/crop",
        json={"crop_id": crop_id, "status": "active"},
    )
    assert association.status_code == 201
    assert client.get(f"/fields/{field_id}/crop").json()["crop_id"] == crop_id
    duplicate_active = client.post(
        f"/fields/{field_id}/crop",
        json={"crop_id": crop_id, "status": "active"},
    )
    assert duplicate_active.status_code == 409


@pytest.mark.parametrize(
    ("method", "path", "payload"),
    [
        ("get", "/farms/missing", None),
        ("post", "/farms/missing/fields", {"name": "A", "area": 1}),
        ("get", "/fields/missing", None),
        ("get", "/crops/missing", None),
        ("post", "/fields/missing/crop", {"crop_id": "missing"}),
    ],
)
def test_missing_resources_return_404(
    client: TestClient,
    method: str,
    path: str,
    payload: Optional[dict[str, object]],
) -> None:
    response = client.request(method, path, json=payload)
    assert response.status_code == 404


def test_required_fields_and_enums_are_validated(client: TestClient) -> None:
    assert client.post("/farms", json={}).status_code == 422
    response = client.post(
        "/crops", json={"name": "tomate", "category": "invalid"}
    )
    assert response.status_code == 422
