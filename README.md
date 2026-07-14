# Agrivito

Agrivito est une plateforme intelligente d'assistance a la decision agricole. Le MVP demarre avec une application mobile Flutter et un backend FastAPI qui centralise la logique metier et les futurs appels IA.

## Objectif Sprint 5

Le Sprint 5 ajoute la premiere capacite de diagnostic texte structure :

- endpoint `POST /ai/diagnosis` ;
- AI Orchestrator et abstraction de provider ;
- `MockAIProvider` sans reseau et `OpenAIProvider` cote backend uniquement ;
- contexte agricole recupere depuis PostgreSQL ;
- sortie validee et Trust Score calcule par Agrivito ;
- Chat Flutter avec reponse structuree et gestion des erreurs ;
- maintien du mode decouverte limite a trois questions ;
- maintien des fonctionnalites des Sprints 1 a 4.

Architecture :

```text
Flutter -> FastAPI -> AI Orchestrator -> PostgreSQL + provider IA -> Trust Score
```

Supabase fournit uniquement l'hebergement PostgreSQL du MVP. Le mobile ne
communique jamais directement avec Supabase et aucun SDK Supabase n'est utilise.

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
 │    ├── PROMPT-CODEX-SPRINT-1.md
 │    └── PROMPT-CODEX-SPRINT-5.md
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
cp .env.example .env
# Renseigner DATABASE_URL uniquement dans .env
# AI_MODE=mock fonctionne sans cle OpenAI
alembic upgrade head
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

Diagnostic texte structure :

```bash
curl -X POST http://127.0.0.1:8000/ai/diagnosis \
  -H "content-type: application/json" \
  -d '{"question":"Pourquoi les feuilles de mes tomates jaunissent ?","language":"fr","discovery_session_id":"temporary-session-id"}'
```

Les endpoints agricoles sont documentes dans `services/backend/README.md` et
disponibles dans la documentation interactive FastAPI sur `/docs`.

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
- Respecter les documents approuves dans `docs/`, notamment le plan Sprint 5.

## Limites connues

- L'authentification Cognito, S3 et AWS RDS ne sont pas integres.
- Le mode decouverte est limite a trois questions et n'est pas persiste.
- `AI_MODE=mock` est le mode local et CI sans appel externe ; `AI_MODE=live`
  exige une cle et un modele OpenAI uniquement dans l'environnement backend.
- Aucun diagnostic photo, Vision, voix, RAG ou historique complet n'est inclus.
- Supabase est utilise uniquement comme PostgreSQL manage temporaire ; la cible
  cloud reste AWS RDS PostgreSQL.
- L'identite mobile reste mockee tant que Cognito n'est pas integre.
- Aucun deploiement automatique n'est inclus.
