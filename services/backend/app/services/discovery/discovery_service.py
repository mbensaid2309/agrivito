from app.schemas.discovery import (
    DiscoveryAnswer,
    DiscoveryQuestionRequest,
    DiscoveryQuestionResponse,
    DiscoveryUsage,
)
from app.schemas.trust_score import TrustScoreResponse


class DiscoveryService:
    questions_limit = 3

    def answer_question(
        self, request: DiscoveryQuestionRequest
    ) -> DiscoveryQuestionResponse:
        questions_used = 1
        remaining = max(self.questions_limit - questions_used, 0)

        return DiscoveryQuestionResponse(
            answer=DiscoveryAnswer(
                summary="Les feuilles jaunes peuvent avoir plusieurs causes.",
                response=(
                    "Cela peut venir d'un manque d'eau, d'un excès d'eau, "
                    "d'une carence ou d'une maladie. Pour être plus fiable, "
                    "Agrivito doit connaître le contexte."
                ),
                trust_score=TrustScoreResponse(
                    score=60,
                    level="moyen",
                    explanation="Réponse générale sans photo ni contexte de culture.",
                ),
                follow_up_questions=[
                    "Depuis combien de temps les feuilles jaunissent ?",
                    "Les feuilles jaunes sont-elles en bas ou en haut de la plante ?",
                    "À quelle fréquence arrosez-vous ?",
                ],
                precautions=[
                    "Ne pas appliquer de traitement sans diagnostic plus précis.",
                    "Ajouter une photo dans un prochain sprint pour améliorer l'analyse.",
                ],
            ),
            usage=DiscoveryUsage(
                questions_used=questions_used,
                questions_limit=self.questions_limit,
                remaining=remaining,
            ),
        )
