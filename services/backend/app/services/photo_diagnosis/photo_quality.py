from __future__ import annotations

from app.schemas.photo_diagnosis import (
    PhotoQualityResponse,
    PhotoQualitySignals,
)


class PhotoQualityEngine:
    def calculate(
        self,
        *,
        signals: PhotoQualitySignals,
        size_bytes: int,
    ) -> PhotoQualityResponse:
        signal_score = (
            signals.brightness * 10
            + signals.sharpness * 20
            + signals.subject_visibility * 20
            + signals.distance * 10
            + signals.crop_identifiability * 15
            + signals.symptom_visibility * 15
        )
        size_score = 10 if size_bytes >= 1024 else 6
        score = max(0, min(100, round(signal_score + size_score)))
        if score >= 80:
            level = "good"
        elif score >= 60:
            level = "acceptable"
        elif score >= 35:
            level = "poor"
        else:
            level = "unusable"

        issues: list[str] = []
        instructions: list[str] = []
        if signals.brightness < 0.5:
            issues.append("Éclairage insuffisant.")
            instructions.append("Prenez la photo avec une lumière naturelle uniforme.")
        if signals.sharpness < 0.5:
            issues.append("Photo insuffisamment nette.")
            instructions.append("Stabilisez le téléphone et refaites la mise au point.")
        if signals.distance < 0.5 or signals.subject_visibility < 0.5:
            issues.append("Sujet trop éloigné ou partiellement visible.")
            instructions.append("Cadrez la partie atteinte de plus près.")
        if signals.symptom_visibility < 0.5:
            issues.append("Symptômes difficilement visibles.")
            instructions.append("Montrez clairement la zone concernée.")
        if level in {"poor", "unusable"} and not instructions:
            instructions.append("Prenez une photo plus proche et mieux éclairée.")
        return PhotoQualityResponse(
            score=score,
            level=level,
            issues=issues,
            retake_required=level in {"poor", "unusable"},
            retake_instructions=list(dict.fromkeys(instructions)),
        )
