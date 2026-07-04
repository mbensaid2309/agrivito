# Agrivito

Agrivito est une plateforme intelligente d'assistance a la decision agricole. Le MVP demarre avec une application mobile Flutter et un backend FastAPI qui centralise la logique metier et les futurs appels IA.

## Objectif Sprint 2

Le Sprint 2 ajoute le socle d'acces utilisateur et le mode decouverte :

- usage sans compte ;
- session decouverte locale cote mobile ;
- limite simple de 3 questions ;
- endpoint backend `POST /discovery/question` ;
- reponse agricole mockee avec Trust Score, questions complementaires et precautions ;
- preparation Login / Register pour Cognito via Amplify, sans integration AWS reelle.

## Stack validee

| Domaine | Technologie |
| --- | --- |
| Mobile | Flutter |
| Backend API | Python FastAPI |
| Cloud cible | AWS |
| Acceleration mobile/cloud | AWS Amplify |
| Authentification | Amazon Cognito via Amplify Auth |
| Stockage media | Amazon S3 via Amplify Storage |
| Base de donnees | Amazon RDS PostgreSQL |
| IA | OpenAI API via backend uniquement |
| Hebergement backend | AWS App Runner |
| CI/CD | GitHub Actions |

## Structure

```text
agrivito/
 ├── docs/
 ├── prompts/
 │    └── PROMPT-CODEX-SPRINT-1.md
 ├── apps/
 │    └── mobile/
 ├── services/
 │    └── backend/
 ├── infra/
 ├── scripts/
 ├── .github/
 │    └── workflows/
 ├── .gitignore
 └── README.md
```

## Backend local

```bash
cd services/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Healthcheck :

```bash
curl http://127.0.0.1:8000/health
```

Question en mode decouverte :

```bash
curl -X POST http://127.0.0.1:8000/discovery/question \
  -H "content-type: application/json" \
  -d '{"session_id":"temporary-session-id","question":"Pourquoi les feuilles de mes tomates jaunissent ?","language":"fr"}'
```

## Mobile local

```bash
cd apps/mobile
flutter pub get
flutter run --dart-define=AGRIVITO_API_BASE_URL=http://127.0.0.1:8000
```

Sur emulateur Android, utiliser plutot :

```bash
flutter run --dart-define=AGRIVITO_API_BASE_URL=http://10.0.2.2:8000
```

## Tests

Backend :

```bash
cd services/backend
pytest
```

Mobile :

```bash
cd apps/mobile
flutter analyze
flutter test
```

## Regles de contribution

- Utiliser Agrivito pour le nom produit et `agrivito` pour les noms techniques.
- Ne jamais stocker de secret dans Git.
- Ne jamais appeler OpenAI depuis le mobile.
- Garder les evolutions limitees au sprint valide.
- Respecter les documents dans `docs/`, en particulier `19-Technology-ADRs.md`, `21-Codex-Handbook.md`, `22-Sprint-1-Plan.md` et `23-Brand-Name-Decision.md`.

## Limites connues

- L'authentification Cognito, S3, RDS et les appels OpenAI reels sont prepares mais non finalises.
- Le mode decouverte est limite a 3 questions en session locale mobile.
- Le backend discovery retourne une reponse mockee prudente, sans appel OpenAI reel.
- La CI mobile effectue une verification Flutter minimale sans deploiement.
