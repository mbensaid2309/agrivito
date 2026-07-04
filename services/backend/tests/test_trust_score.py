import pytest

from app.services.ai.trust_score_service import TrustScoreService


def test_mock_trust_score() -> None:
    service = TrustScoreService()

    trust_score = service.get_mock_score()

    assert trust_score.model_dump() == {
        "score": 70,
        "level": "moyen",
        "explanation": "Score provisoire MVP.",
    }


@pytest.mark.parametrize(
    ("score", "level"),
    [
        (100, "élevé"),
        (80, "élevé"),
        (79, "moyen"),
        (60, "moyen"),
        (59, "faible"),
        (40, "faible"),
        (39, "insuffisant"),
        (0, "insuffisant"),
    ],
)
def test_trust_score_levels(score: int, level: str) -> None:
    service = TrustScoreService()

    assert service.level_for_score(score) == level
