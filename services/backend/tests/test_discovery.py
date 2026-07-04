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
    assert body["answer"]["trust_score"] == {
        "score": 60,
        "level": "moyen",
        "explanation": "Réponse générale sans photo ni contexte de culture.",
    }
    assert body["answer"]["follow_up_questions"]
    assert body["answer"]["precautions"]
    assert body["usage"] == {
        "questions_used": 1,
        "questions_limit": 3,
        "remaining": 2,
    }


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
