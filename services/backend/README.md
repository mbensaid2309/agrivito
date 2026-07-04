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

## Tests

```bash
pytest
```

Tests presents au Sprint 1 :

- chargement de l'application FastAPI ;
- endpoint `GET /health` ;
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
- Le Trust Score retourne un score provisoire mocke.
