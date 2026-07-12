# Agrivito Backend

Backend FastAPI du MVP Agrivito. Il porte la logique metier, expose l'API et isolera les futurs appels OpenAI afin que le mobile ne contacte jamais directement les services IA.

## Stack

- Python FastAPI
- SQLAlchemy
- Psycopg
- Alembic
- PostgreSQL
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

Renseigner `DATABASE_URL` uniquement dans `.env`, avec une connexion fictive de
ce format :

```env
DATABASE_URL=postgresql+psycopg://user:password@host:5432/database?sslmode=require
```

Supabase est utilise uniquement comme hebergement PostgreSQL manage pour le MVP.
Aucune cle ni aucun SDK Supabase n'est requis.
La migration active RLS sur les tables du schema public sans politique d'acces
public ; les donnees restent accessibles uniquement par la connexion backend.

## Lancement local

```bash
alembic upgrade head
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

## API agricole Sprint 4

Le backend expose les fondations metier suivantes :

```text
GET  /farmer/profile
POST /farmer/profile
GET  /farms
POST /farms
GET  /farms/{farm_id}
GET  /farms/{farm_id}/fields
POST /farms/{farm_id}/fields
GET  /fields/{field_id}
GET  /crops
POST /crops
GET  /crops/{crop_id}
POST /fields/{field_id}/crop
GET  /fields/{field_id}/crop
```

Les donnees agricoles sont persistantes dans PostgreSQL. Le backend est le seul
composant autorise a communiquer avec la base.

## Migrations

Appliquer la migration :

```bash
alembic upgrade head
```

Verifier localement la reversibilite sur une base de test uniquement :

```bash
alembic downgrade -1
alembic upgrade head
```

Ne jamais executer un downgrade destructif sur une base partagee sans sauvegarde
et validation explicite.

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

Les tests locaux utilisent SQLite en memoire. GitHub Actions utilise un service
PostgreSQL 16 isole, applique `alembic upgrade head`, puis execute Pytest.

Tests presents :

- chargement de l'application FastAPI ;
- endpoint `GET /health` ;
- endpoint `POST /discovery/question` ;
- validation des requetes discovery invalides ;
- creation et lecture du profil agricole ;
- creation et lecture des exploitations, parcelles et cultures ;
- association d'une culture principale a une parcelle ;
- validation des champs agricoles et erreurs sur identifiants inexistants ;
- configuration minimale ;
- Trust Score MVP mocke et niveaux associes.

## Docker

Construire l'image :

```bash
docker build -t agrivito-backend .
```

Demarrer le container :

```bash
docker run --rm -p 8000:8000 --env-file .env agrivito-backend
```

Verifier le healthcheck :

```bash
curl http://127.0.0.1:8000/health
```

## Configuration

Les variables attendues sont documentees dans `.env.example`. `DATABASE_URL` est
lue depuis l'environnement. Aucun secret reel ne doit etre versionne ou affiche.

## Limites connues

- Aucun appel OpenAI reel.
- Cognito, S3, AWS RDS PostgreSQL et App Runner restent des cibles futures.
- Le Trust Score discovery retourne un score prudent mocke.
- La limite discovery est preparee sans base de donnees au Sprint 2.
- Supabase n'est utilise que pour heberger PostgreSQL pendant le MVP.
- Aucun deploiement AWS n'est inclus dans le Sprint 4.
