from app.schemas.trust_score import TrustScoreResponse


class TrustScoreService:
    def get_mock_score(self) -> TrustScoreResponse:
        return TrustScoreResponse(
            score=70,
            level=self.level_for_score(70),
            explanation="Score provisoire MVP.",
        )

    def level_for_score(self, score: int) -> str:
        if score < 0 or score > 100:
            raise ValueError("Trust Score must be between 0 and 100.")
        if score >= 80:
            return "élevé"
        if score >= 60:
            return "moyen"
        if score >= 40:
            return "faible"
        return "insuffisant"
