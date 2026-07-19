from __future__ import annotations

from app.services.photo_diagnosis.provider import (
    VisionProvider,
    VisionProviderRequest,
)


class MockVisionProvider(VisionProvider):
    name = "mock"
    model = "mock-vision"

    def analyze(self, request: VisionProviderRequest) -> object:
        scenario = request.prompt.lower()
        if "provider_invalid_output" in scenario:
            return {"summary": "Sortie incomplète"}
        if "unusable_photo" in scenario:
            return self._response(0.08, "questions_required")
        if "poor_photo" in scenario:
            return self._response(0.35, "questions_required")
        if "multiple_hypotheses" in scenario:
            response = self._response(0.82, "hypotheses")
            response["hypotheses"].append(
                {
                    "label": "Stress nutritionnel possible",
                    "explanation": (
                        "La coloration visible peut avoir plusieurs causes et "
                        "nécessite des informations complémentaires."
                    ),
                }
            )
            return response
        return self._response(0.9, "hypotheses")

    @staticmethod
    def _response(signal: float, response_mode: str) -> dict[str, object]:
        return {
            "summary": (
                "La photo montre une anomalie foliaire qui doit être "
                "interprétée avec prudence."
            ),
            "visual_observations": [
                "Des zones de coloration irrégulière sont visibles sur la feuille."
            ],
            "hypotheses": [
                {
                    "label": "Stress foliaire possible",
                    "explanation": (
                        "L'aspect visible peut correspondre à plusieurs causes "
                        "agronomiques."
                    ),
                }
            ],
            "recommendations": [
                "Observer plusieurs plants et vérifier l'évolution avant tout traitement."
            ],
            "follow_up_questions": [
                "Depuis combien de temps ces marques sont-elles visibles ?"
            ],
            "precautions": [
                "Une photo seule ne permet pas de confirmer une maladie."
            ],
            "quality_signals": {
                "brightness": signal,
                "sharpness": signal,
                "subject_visibility": signal,
                "distance": signal,
                "crop_identifiability": signal,
                "symptom_visibility": signal,
            },
            "response_mode": response_mode,
        }
