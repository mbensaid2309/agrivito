from fastapi.testclient import TestClient

from app.main import app


def test_discovery_question_endpoint() -> None:
    client = TestClient(app)

    response = client.post(
        "/discovery/question",
        json={
            "session_id": "temporary-session-id",
            "question": "Pourquoi les feuilles de mes tomates jaunissent ?",
            "language": "fr",
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert "answer" in body
    assert 0 <= body["answer"]["trust_score"]["score"] <= 100
    assert body["answer"]["trust_score"]["level"] == "moyen"
    assert body["answer"]["follow_up_questions"]
    assert body["answer"]["precautions"]
    assert body["usage"] == {
        "questions_used": 1,
        "questions_limit": 3,
        "remaining": 2,
    }


def test_discovery_question_limit_is_three() -> None:
    client = TestClient(app)
    payload = {
        "session_id": "limited-session",
        "question": "Pourquoi les feuilles de tomates jaunissent ?",
        "language": "fr",
    }

    responses = [client.post("/discovery/question", json=payload) for _ in range(4)]

    assert [response.status_code for response in responses] == [200, 200, 200, 429]
    assert responses[2].json()["usage"]["remaining"] == 0
    assert responses[3].json()["detail"] == (
        "Vous avez atteint la limite du mode découverte."
    )


def test_discovery_question_defaults_to_french() -> None:
    client = TestClient(app)

    response = client.post(
        "/discovery/question",
        json={
            "session_id": "temporary-session-id",
            "question": "Pourquoi les feuilles jaunissent ?",
        },
    )

    assert response.status_code == 200


def test_discovery_question_requires_session_id() -> None:
    client = TestClient(app)

    response = client.post(
        "/discovery/question",
        json={
            "question": "Pourquoi les feuilles jaunissent ?",
            "language": "fr",
        },
    )

    assert response.status_code == 422


def test_discovery_question_rejects_empty_question() -> None:
    client = TestClient(app)

    response = client.post(
        "/discovery/question",
        json={
            "session_id": "temporary-session-id",
            "question": "   ",
            "language": "fr",
        },
    )

    assert response.status_code == 422
