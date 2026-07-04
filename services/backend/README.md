# Agrivito Backend

Backend FastAPI du MVP Agrivito. Il porte la logique metier, expose l'API et isolera les futurs appels OpenAI afin que le mobile ne contacte jamais directement les services IA.

## Stack

- Python FastAPI
- Uvicorn
- Pytest
- Docker pour l'execution containerisee

## Installation locale

```bash
cd services/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
```

## Lancement local

```bash
uvicorn app.main:app --reload
```

Healthcheck :

```bash
curl http://127.0.0.1:8000/health
```

Reponse attendue :

```json
{
  "status": "ok",
  "service": "agrivito-backend"
}
```

Question decouverte :

```bash
curl -X POST http://127.0.0.1:8000/discovery/question \
  -H "content-type: application/json" \
  -d '{"session_id":"temporary-session-id","question":"Pourquoi les feuilles de mes tomates jaunissent ?","language":"fr"}'
```

Reponse attendue :

```json
{
  "answer": {
    "summary": "Les feuilles jaunes peuvent avoir plusieurs causes.",
    "response": "Cela peut venir d'un manque d'eau, d'un excès d'eau, d'une carence ou d'une maladie. Pour être plus fiable, Agrivito doit connaître le contexte.",
    "trust_score": {
      "score": 60,
      "level": "moyen",
      "explanation": "Réponse générale sans photo ni contexte de culture."
    },
    "follow_up_questions": [
      "Depuis combien de temps les feuilles jaunissent ?",
      "Les feuilles jaunes sont-elles en bas ou en haut de la plante ?",
      "À quelle fréquence arrosez-vous ?"
    ],
    "precautions": [
      "Ne pas appliquer de traitement sans diagnostic plus précis.",
      "Ajouter une photo dans un prochain sprint pour améliorer l'analyse."
    ]
  },
  "usage": {
    "questions_used": 1,
    "questions_limit": 3,
    "remaining": 2
  }
}
```

## Tests

```bash
pytest
```

Tests presents :

- chargement de l'application FastAPI ;
- endpoint `GET /health` ;
- endpoint `POST /discovery/question` ;
- validation des requetes discovery invalides ;
- configuration minimale ;
- Trust Score MVP mocke et niveaux associes.

## Docker

Construire l'image :

```bash
docker build -t agrivito-backend .
```

Demarrer le container :

```bash
docker run --rm -p 8000:8000 --env-file .env.example agrivito-backend
```

Verifier le healthcheck :

```bash
curl http://127.0.0.1:8000/health
```

## Configuration

Les variables attendues sont documentees dans `.env.example`. Aucun secret reel ne doit etre versionne.

## Limites connues

- Aucun appel OpenAI reel au Sprint 1.
- Cognito, S3, RDS PostgreSQL et App Runner sont prevus par l'architecture mais non integres dans ce socle.
- Le Trust Score discovery retourne un score prudent mocke.
- La limite discovery est preparee sans base de donnees au Sprint 2.
