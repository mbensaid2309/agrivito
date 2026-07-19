# Agrivito Backend

Backend FastAPI du MVP Agrivito. Il porte la logique metier, construit le
contexte agricole et isole les appels OpenAI afin que le mobile ne contacte
jamais directement les services IA.

## Stack

- Python FastAPI et Pydantic
- SQLAlchemy, Psycopg, Alembic et PostgreSQL
- SDK OpenAI, utilise uniquement en mode live
- `python-multipart` et `boto3` pour l'upload et le provider S3 isole
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

## Authentification Sprint 8

FastAPI valide les JWT avant toute route privee. Le metier depend d'un
`AuthenticatedUser` neutre obtenu via `AuthProvider` :

- `MockAuthProvider` est deterministe en tests et CI, sans reseau ;
- `SupabaseAuthProvider` verifie signature, expiration, issuer, audience et
  claim `sub`, avec JWKS privilegie et secret HS256 en repli explicite.

Configuration locale sans service externe :

```env
AUTH_PROVIDER=supabase
AUTH_MODE=mock
```

Configuration live, uniquement dans l'environnement :

```env
AUTH_PROVIDER=supabase
AUTH_MODE=live
SUPABASE_URL=https://PROJECT.supabase.co
SUPABASE_JWKS_URL=
SUPABASE_JWT_SECRET=
AUTH_AUDIENCE=authenticated
AUTH_ISSUER=
AUTH_TIMEOUT_SECONDS=10
```

`SUPABASE_URL` permet de deriver l'issuer et l'URL JWKS. Ne jamais versionner le
secret JWT, une cle `service_role` ou un token utilisateur.

Routes publiques : `GET /health`, `POST /discovery/question`,
`POST /discovery/media/upload` et `POST /discovery/photo-diagnosis`.

Les routes agricoles, media et diagnostic hors `/discovery` sont privees. Leur
proprietaire vient exclusivement du claim `sub`. Un `user_id` client est refuse,
et une ressource appartenant a un autre utilisateur produit un `404` sur.

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

Le diagnostic photo utilise une configuration separee :

```env
VISION_PROVIDER=openai
VISION_MODE=mock
OPENAI_VISION_MODEL=
VISION_TIMEOUT_SECONDS=45
PHOTO_DIAGNOSIS_DISCOVERY_LIMIT=1
```

`VISION_MODE=live` exige `OPENAI_API_KEY` et `OPENAI_VISION_MODEL`. Le modele
n'est jamais duplique dans le code et le mode mock ne fait aucun appel reseau.

Le stockage media local fonctionne sans AWS :

```env
MEDIA_STORAGE_PROVIDER=local
MEDIA_LOCAL_PATH=./data/media
MEDIA_MAX_SIZE_MB=10
MEDIA_ALLOWED_MIME_TYPES=image/jpeg,image/png,image/webp
```

Le mode `s3` exige `AWS_REGION` et `AWS_S3_BUCKET`. Boto3 utilise ensuite la
chaine standard de credentials AWS (variables d'environnement, profil ou role
IAM). Les credentials ne doivent jamais etre ajoutes dans Git.

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

## Diagnostic photo

```text
POST /ai/photo-diagnosis
```

La requete contient `media_id`, une question optionnelle, la langue et le
contexte agricole disponible. `PhotoDiagnosisOrchestrator` verifie le statut,
le MIME, le proprietaire logique et le provider de stockage, puis lit les bytes
avec `MediaStorageProvider`. Aucun chemin local ou objet S3 public n'est expose.

`VisionProvider` possede deux implementations :

- `MockVisionProvider`, deterministe et sans reseau pour le developpement/CI ;
- `OpenAIVisionProvider`, qui utilise la Responses API et une sortie Pydantic
  structuree en mode live.

`PhotoQualityEngine` calcule un niveau `good`, `acceptable`, `poor` ou
`unusable` a partir des signaux visuels bornes et des metadonnees. Le Trust
Score visuel est ensuite calcule par Agrivito a partir de la qualite, de la
visibilite, du contexte, de la question et de la validite de la sortie. Une
photo inutilisable supprime hypotheses et recommandations et exige davantage
d'informations. Une sortie provider invalide beneficie d'une seule tentative
de correction, puis produit une erreur controlee.

La migration `20260719_03` cree `diagnoses`, lie chaque diagnostic a `media`,
stocke seulement le resultat structure, active RLS et retire les privileges des
roles Data API Supabase. Aucun binaire ni reponse brute provider n'est persiste.

Exemple :

```bash
curl -X POST http://127.0.0.1:8000/ai/photo-diagnosis \
  -H "content-type: application/json" \
  -d '{"media_id":"MEDIA_ID","question":"Pourquoi les feuilles sont-elles tachees ?","language":"fr","discovery_session_id":"temporary-photo-session"}'
```

Le mode decouverte autorise une analyse photo en memoire avant d'inviter a
creer un compte.

## Medias

```text
POST /media/upload
GET  /media/{media_id}
```

`POST /media/upload` accepte un formulaire multipart avec `file` obligatoire et
`farm_id`, `field_id`, `crop_id` optionnels. Le proprietaire vient du JWT.
L'upload anonyme utilise `/discovery/media/upload` et une session decouverte.
Le backend verifie la signature reelle et le MIME pour JPEG, PNG et WebP, refuse
les fichiers vides ou superieurs a 10 MB, neutralise le nom fourni et genere une
cle `media/YYYY/MM/<uuid>.<extension>`.

```bash
curl -X POST http://127.0.0.1:8000/media/upload \
  -F "file=@/chemin/vers/tomate.jpg;type=image/jpeg" \
  -F "discovery_session_id=temporary-photo-session"
```

La table `media` contient uniquement les metadonnees et un checksum. Le fichier
binaire est enregistre par `LocalMediaStorage` ou `S3MediaStorage`. Si le
stockage echoue, aucune metadonnee n'est validee ; si PostgreSQL echoue, le
service tente de supprimer le fichier. Aucun chemin systeme, credential ou URL
publique n'est retourne.

`LocalMediaStorage` cree le dossier configure, bloque toute traversee de chemin
et fournit `save`, `read`, `exists`, `delete`. `S3MediaStorage` ecrit des objets prives
sans ACL publique et ses tests utilisent exclusivement un client mocke.

En mode decouverte, une session peut envoyer une photo. Le compteur est en
memoire et invite ensuite a creer un compte.

## Diagnostic texte

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

## API agricole privee

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
export VISION_MODE=mock
export AUTH_MODE=mock
pytest
```

Les tests locaux utilisent SQLite en memoire. GitHub Actions utilise PostgreSQL
16, un dossier media temporaire, applique `alembic upgrade head`, force
`AUTH_MODE=mock`, `AI_MODE=mock`, `VISION_MODE=mock` et
`MEDIA_STORAGE_PROVIDER=local`, puis execute Pytest. Aucun appel Supabase,
OpenAI ou AWS reel n'est effectue.

La CI verifie aussi la reversibilite de la derniere migration avec
`alembic downgrade -1`, puis reapplique `alembic upgrade head` avant les tests.

La couverture inclut le healthcheck, le diagnostic avec et sans contexte, le
mode decouverte, les endpoints agricoles, le parser, les providers, les erreurs
controlees, les seuils du Trust Score, les migrations, les formats images, les
relations, les rollbacks, les providers local/S3, la qualite photo, le Trust
Score visuel, la persistance, les erreurs Vision controlees, les JWT valides et
invalides, l'usurpation de `user_id` et l'isolation entre utilisateurs.

## Docker

```bash
docker build -t agrivito-backend .
docker run --rm -p 8000:8000 --env-file .env agrivito-backend
curl http://127.0.0.1:8000/health
```

## Configuration

Les variables sont documentees dans `.env.example` : `DATABASE_URL`, les
variables IA texte/Vision, `MEDIA_STORAGE_PROVIDER`, `MEDIA_LOCAL_PATH`,
`MEDIA_MAX_SIZE_MB`, `MEDIA_ALLOWED_MIME_TYPES`, l'authentification et la
configuration AWS vide.
Le fichier `.env` reel et `data/media/` restent ignores par Git.

## Limites connues

- Le diagnostic photo est prudent et ne garantit jamais une maladie.
- Les appels OpenAI reels texte ou Vision necessitent une configuration live explicite.
- Cognito, AWS RDS et App Runner ne sont pas integres. `AuthProvider` permet une
  migration future vers Cognito sans coupler le metier.
- S3 est prepare mais non deploye ; le developpement et la CI utilisent le local.
- Le compteur discovery est volontairement non persistant.
- Supabase fournit Auth et PostgreSQL manage pendant le MVP, sans acces Flutter
  direct aux tables metier.
- Pas de comparaison multi-images, video, voix, RAG ou historique avance.
- Aucun deploiement AWS n'est inclus dans le Sprint 8.
