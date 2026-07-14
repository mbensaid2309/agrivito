from app.services.ai.provider import AIProvider, AIProviderRequest


class MockAIProvider(AIProvider):
    name = "mock"

    def generate_diagnosis(self, request: AIProviderRequest) -> object:
        return {
            "summary": "Le symptôme décrit peut avoir plusieurs causes.",
            "observations": [
                "La question décrit un symptôme visible sur une culture."
            ],
            "hypotheses": [
                {
                    "label": "Stress hydrique",
                    "explanation": (
                        "Un manque ou un excès d'eau peut provoquer ce type de symptôme."
                    ),
                },
                {
                    "label": "Déséquilibre nutritif",
                    "explanation": (
                        "Une carence reste possible sans analyse complémentaire."
                    ),
                },
            ],
            "recommendations": [
                "Vérifier l'humidité du sol et observer l'évolution avant tout traitement."
            ],
            "follow_up_questions": [
                "Depuis combien de temps le symptôme est-il visible ?",
                "Toute la parcelle est-elle concernée ?",
                "Quel est le rythme d'irrigation actuel ?",
            ],
            "precautions": [
                "Ne pas appliquer de produit chimique sans diagnostic plus précis."
            ],
            "response_mode": "hypotheses",
        }
