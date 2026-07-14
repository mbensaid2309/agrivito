# Agrivito Backend

Backend FastAPI du MVP Agrivito. Il porte la logique metier, construit le
contexte agricole et isole les appels OpenAI afin que le mobile ne contacte
jamais directement les services IA.

## Stack

- Python FastAPI et Pydantic
- SQLAlchemy, Psycopg, Alembic et PostgreSQL
- SDK OpenAI, utilise uniquement en mode live
- Uvicorn, Pytest et Docker

## Installation locale

```bash
cd services/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
```

Renseigner `DATABASE_URL` uniquement dans `.env`. Supabase est utilise uniquement
comme hebergement PostgreSQL manage pour le MVP. Le backend est le seul composant
autorise a acceder a cette base.

Le diagnostic fonctionne sans cle externe avec :

```env
AI_MODE=mock
AI_PROVIDER=openai
OPENAI_TIMEOUT_SECONDS=30
```

Pour activer un appel reel, definir uniquement dans l'environnement backend :

```env
AI_MODE=live
OPENAI_API_KEY=replace-with-your-openai-api-key
OPENAI_MODEL=replace-with-approved-model
```

Le mode live refuse le diagnostic si la cle ou le modele manque. Aucune valeur
sensible ne doit etre loggee, affichee ou versionnee.

## Lancement local

```bash
alembic upgrade head
uvicorn app.main:app --reload
```

Verifier le backend :

```bash
curl http://127.0.0.1:8000/health
```

La documentation interactive est disponible sur `http://127.0.0.1:8000/docs`.

## Diagnostic texte Sprint 5

```text
POST /ai/diagnosis
```

La requete accepte une question, une langue et des identifiants optionnels de
profil, exploitation, parcelle, culture et session decouverte. Le backend :

1. verifie les ressources et leurs relations ;
2. construit le contexte depuis PostgreSQL ;
3. appelle `MockAIProvider` ou `OpenAIProvider` ;
4. parse et valide la sortie structuree ;
5. applique les regles anti-hallucination ;
6. calcule le Trust Score cote Agrivito ;
7. retourne une reponse stable.

Exemple :

```bash
curl -X POST http://127.0.0.1:8000/ai/diagnosis \
  -H "content-type: application/json" \
  -d '{"question":"Pourquoi les feuilles de mes tomates jaunissent ?","language":"fr","discovery_session_id":"temporary-session-id"}'
```

La reponse distingue resume, observations, hypotheses, recommandations,
questions complementaires, precautions et Trust Score. Les modes supportes sont
`reliable`, `hypotheses`, `questions_required` et `refusal`.

Le provider ne fournit jamais le Trust Score final. Les sorties vides ou
invalides, timeouts, rate limits et indisponibilites deviennent des erreurs API
controlees. Le prompt interdit notamment d'inventer une photo, une meteo, une
analyse de sol ou une maladie confirmee.

## Mode decouverte

L'endpoint historique reste disponible :

```text
POST /discovery/question
```

Il utilise le meme orchestrateur tout en conservant son contrat. Le compteur
backend est non persistant et refuse une quatrieme question pour une meme session.

## API agricole Sprint 4

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

## Migrations

```bash
alembic upgrade head
```

Verifier la reversibilite uniquement sur une base de test isolee :

```bash
alembic downgrade -1
alembic upgrade head
```

Ne jamais executer un downgrade destructif sur une base partagee sans sauvegarde
et validation explicite.

## Tests

```bash
export AI_MODE=mock
pytest
```

Les tests locaux utilisent SQLite en memoire. GitHub Actions utilise PostgreSQL
16, applique `alembic upgrade head`, force `AI_MODE=mock`, puis execute Pytest.
Aucun appel OpenAI reel n'est effectue.

La couverture inclut le healthcheck, le diagnostic avec et sans contexte, le
mode decouverte, les endpoints agricoles, le parser, les providers, les erreurs
controlees, les seuils du Trust Score et les migrations.

## Docker

```bash
docker build -t agrivito-backend .
docker run --rm -p 8000:8000 --env-file .env agrivito-backend
curl http://127.0.0.1:8000/health
```

## Configuration

Les variables sont documentees dans `.env.example` : `DATABASE_URL`,
`OPENAI_API_KEY`, `OPENAI_MODEL`, `OPENAI_TIMEOUT_SECONDS`, `AI_PROVIDER` et
`AI_MODE`. Le fichier `.env` reel reste ignore par Git.

## Limites connues

- Pas de diagnostic photo, Vision, voix, RAG ou historique complet.
- Les appels OpenAI reels necessitent une configuration live explicite.
- Cognito, S3, AWS RDS et App Runner ne sont pas integres.
- Le compteur discovery est volontairement non persistant.
- Supabase n'heberge que PostgreSQL pendant le MVP.
- Aucun deploiement AWS n'est inclus dans le Sprint 5.
