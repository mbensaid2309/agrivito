Tu es Lead Developer sur le projet Agrivito.

Agrivito est une plateforme intelligente d’assistance à la décision agricole.

Ton rôle est d’implémenter le Sprint 4 du MVP en respectant strictement les documents validés dans le dossier `docs/`.

Tu ne dois pas prendre de décision d’architecture.

---

# Étape obligatoire avant de coder

Avant de modifier ou créer du code, lis intégralement les documents suivants :

```text
docs/13-Domain-Model.md
docs/16-Data-Architecture.md
docs/17-API-Design.md
docs/19-Technology-ADRs.md
docs/20-MVP-Backlog.md
docs/21-Codex-Handbook.md
docs/23-Brand-Name-Decision.md
docs/24-Sprint-2-Plan.md
docs/25-Sprint-3-Plan.md
docs/26-Sprint-4-Plan.md
```

Ces documents sont la source de vérité.

Important :

```text
AgriAI = ancien nom de travail
Agrivito = nom officiel du produit
```

Toutes les nouvelles implémentations doivent utiliser `Agrivito` ou `agrivito`.

---

# Processus obligatoire

Les documents du Sprint 4 et ce prompt sont déjà présents dans `main`.

Tu dois respecter strictement le processus suivant :

1. partir du dernier état de `main` ;
2. créer la branche `codex/sprint-4-postgresql-persistence` depuis `main` ;
3. développer uniquement sur cette branche ;
4. ne jamais modifier directement `main` ;
5. pousser les changements sur la branche du Sprint 4 ;
6. créer une Pull Request vers `main` ;
7. ne jamais merger toi-même la Pull Request ;
8. attendre la validation CTO.

Commandes attendues :

```bash
git checkout main
git pull origin main
git checkout -b codex/sprint-4-postgresql-persistence
```

Si la branche existe déjà, utilise-la uniquement après avoir vérifié qu’elle est bien basée sur le dernier `main`.

---

# Nom du Sprint

```text
Sprint 4 - PostgreSQL Persistence and Mobile API Integration
```

---

# Objectif du Sprint 4

Le Sprint 4 doit rendre persistantes les données agricoles créées pendant le Sprint 3 et connecter l’application Flutter aux API agricoles du backend FastAPI.

À la fin du Sprint 4, Agrivito doit :

- utiliser PostgreSQL comme base de données persistante ;
- utiliser Supabase uniquement comme hébergement PostgreSQL managé ;
- lire la connexion PostgreSQL depuis `DATABASE_URL` ;
- utiliser SQLAlchemy comme ORM ;
- utiliser Psycopg comme driver PostgreSQL ;
- utiliser Alembic pour les migrations ;
- remplacer le stockage in-memory du backend ;
- conserver les endpoints existants ;
- connecter les écrans agricoles Flutter au backend ;
- gérer les erreurs réseau et backend ;
- garder les tests backend et mobile fonctionnels ;
- garder GitHub Actions entièrement vert.

---

# Architecture obligatoire

```text
Application Flutter
        |
        | HTTP / JSON
        v
Backend FastAPI
        |
        | SQLAlchemy / Psycopg
        v
PostgreSQL Supabase
```

Règles obligatoires :

- Flutter ne communique jamais directement avec Supabase ;
- seul le backend FastAPI communique avec PostgreSQL ;
- aucune connexion PostgreSQL ne doit être présente dans Flutter ;
- le backend doit lire `DATABASE_URL` depuis l’environnement ;
- aucune URL PostgreSQL réelle ne doit être codée dans le code ;
- aucune clé Supabase ne doit être utilisée ;
- la future migration vers AWS RDS PostgreSQL doit rester possible.

---

# Utilisation autorisée de Supabase

Supabase est utilisé uniquement comme PostgreSQL managé pour le MVP.

Autorisé :

```text
PostgreSQL
connexion SSL
hébergement temporaire de la base MVP
```

Interdit :

```text
Supabase Auth
Supabase Storage
Supabase Realtime
Supabase Edge Functions
Supabase SDK Flutter
supabase_flutter
accès direct depuis Flutter
```

Ne change pas l’architecture cible AWS validée dans les ADR.

---

# Périmètre autorisé Sprint 4

Tu peux développer uniquement :

1. configuration PostgreSQL ;
2. lecture de `DATABASE_URL` ;
3. SQLAlchemy ;
4. Psycopg ;
5. Alembic ;
6. modèles SQLAlchemy agricoles ;
7. migration initiale ;
8. remplacement du stockage in-memory backend ;
9. persistance des profils agricoles ;
10. persistance des exploitations ;
11. persistance des parcelles ;
12. persistance des cultures ;
13. persistance des associations parcelle / culture ;
14. connexion Flutter aux endpoints agricoles ;
15. gestion des états de chargement et d’erreur ;
16. tests backend ;
17. tests Flutter ;
18. configuration PostgreSQL de test dans GitHub Actions ;
19. mise à jour des README ;
20. maintien des fonctionnalités des Sprints 1, 2 et 3.

---

# Hors périmètre strict

Ne pas développer :

- Cognito réel ;
- Supabase Auth ;
- Supabase Storage ;
- Supabase Realtime ;
- Supabase Edge Functions ;
- stockage S3 réel ;
- appel OpenAI réel ;
- diagnostic photo réel ;
- historique complet des conversations ;
- paiement ;
- abonnement ;
- marketplace ;
- fournisseurs ;
- météo réelle ;
- IoT ;
- drone ;
- satellite ;
- dashboard avancé ;
- backoffice ;
- déploiement AWS ;
- App Runner ;
- AWS RDS ;
- Sprint 5.

Ne pas introduire :

- Kubernetes ;
- EKS ;
- microservices ;
- Firebase ;
- MongoDB ;
- DynamoDB ;
- SDK Supabase mobile ;
- nouvelle technologie non validée.

---

# Vérification du socle existant

Avant de coder, vérifier que les éléments des Sprints précédents existent toujours :

```text
services/backend/
apps/mobile/
.github/workflows/
README.md
```

Vérifier que les endpoints existants sont toujours présents :

```http
GET /health
POST /discovery/question

GET /farmer/profile
POST /farmer/profile

GET /farms
POST /farms
GET /farms/{farm_id}

GET /farms/{farm_id}/fields
POST /farms/{farm_id}/fields
GET /fields/{field_id}

GET /crops
POST /crops
GET /crops/{crop_id}

POST /fields/{field_id}/crop
GET /fields/{field_id}/crop
```

Ne casse pas les Sprints 1, 2 ou 3.

---

# Configuration sensible

La vraie connexion PostgreSQL est stockée localement dans :

```text
services/backend/.env
```

La variable utilisée est :

```env
DATABASE_URL=postgresql+psycopg://USER:PASSWORD@HOST:PORT/postgres?sslmode=require
```

Tu ne dois jamais :

- afficher la vraie valeur ;
- logger la vraie valeur ;
- copier la vraie valeur ;
- écrire la vraie valeur dans le code ;
- écrire la vraie valeur dans un README ;
- commiter le fichier `.env`.

Le fichier `services/backend/.env` doit rester ignoré par Git.

Mettre à jour si nécessaire `services/backend/.env.example` avec uniquement une valeur fictive :

```env
APP_NAME=agrivito-backend
APP_ENV=local
LOG_LEVEL=INFO
DATABASE_URL=postgresql+psycopg://user:password@host:5432/database?sslmode=require
```

---

# Dépendances backend

Ajouter uniquement les dépendances nécessaires dans `services/backend/requirements.txt` :

```text
SQLAlchemy
psycopg
alembic
```

Utiliser des versions compatibles avec la version Python et FastAPI déjà présentes.

Ne pas ajouter d’ORM alternatif, de client Supabase, de framework supplémentaire ou de dépendance inutile.

---

# Structure backend attendue

```text
services/backend/
├── alembic/
│   ├── versions/
│   ├── env.py
│   └── script.py.mako
├── alembic.ini
├── app/
│   ├── api/
│   ├── core/
│   ├── db/
│   │   ├── base.py
│   │   ├── database.py
│   │   └── session.py
│   ├── models/
│   │   ├── farmer_profile.py
│   │   ├── farm.py
│   │   ├── field.py
│   │   ├── crop.py
│   │   └── field_crop.py
│   ├── schemas/
│   ├── services/
│   └── main.py
├── tests/
├── .env.example
└── requirements.txt
```

Une structure consolidée est acceptable si elle reste simple, claire et cohérente.

Ne crée pas de microservices.

---

# Module de connexion PostgreSQL

Créer un module dédié dans `services/backend/app/db/`.

Il doit fournir :

- une Base SQLAlchemy déclarative ;
- un engine SQLAlchemy ;
- une session factory ;
- une dépendance FastAPI `get_db` ;
- une ouverture propre des sessions ;
- une fermeture des sessions dans un bloc `finally` ;
- une lecture de `DATABASE_URL` depuis la configuration ;
- une erreur claire si `DATABASE_URL` est absente ;
- aucune fuite de credentials.

Comportement attendu :

```python
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

Ne jamais écrire une URL PostgreSQL directement dans le code.

---

# Modèles SQLAlchemy obligatoires

Créer les modèles suivants :

```text
FarmerProfile
Farm
Field
Crop
FieldCrop
```

Tables recommandées :

```text
farmer_profiles
farms
fields
crops
field_crops
```

Conserver autant que possible les identifiants et structures déjà définis pendant le Sprint 3.

## FarmerProfile

Champs minimum :

```text
id
user_id
display_name
user_type
country
region
preferred_language
is_discovery_mode
created_at
updated_at
```

Contraintes : clé primaire sur `id`, `user_id` obligatoire et unique, champs obligatoires validés, dates générées côté backend.

Valeurs `user_type` :

```text
farmer
advisor
cooperative_member
unknown
```

## Farm

Champs minimum :

```text
id
user_id
name
country
region
locality
total_area
area_unit
created_at
updated_at
```

Contraintes : clé primaire sur `id`, `user_id`, `name` et `country` obligatoires, une exploitation peut avoir plusieurs parcelles.

Unités :

```text
hectare
square_meter
acre
unknown
```

## Field

Champs minimum :

```text
id
farm_id
name
area
area_unit
soil_type
water_access
irrigation_type
notes
created_at
updated_at
```

Contraintes : clé primaire sur `id`, clé étrangère `farm_id` vers `farms.id`, `name`, `area` et `area_unit` obligatoires, aucune parcelle orpheline.

Valeurs `water_access` :

```text
yes
no
seasonal
unknown
```

Valeurs `irrigation_type` :

```text
none
drip
sprinkler
flood
manual
unknown
```

## Crop

Champs minimum :

```text
id
name
category
variety
season
planting_date
growth_stage
notes
created_at
updated_at
```

Contraintes : clé primaire sur `id`, `name` et `category` obligatoires.

Catégories :

```text
vegetable
fruit_tree
cereal
legume
industrial_crop
other
unknown
```

Stades :

```text
seedling
vegetative
flowering
fruiting
harvest
post_harvest
unknown
```

## FieldCrop

Champs minimum :

```text
id
field_id
crop_id
status
start_date
end_date
created_at
updated_at
```

Contraintes : clé primaire sur `id`, clés étrangères vers `fields.id` et `crops.id`, aucune référence inexistante, une seule culture principale active par parcelle.

Statuts :

```text
active
planned
completed
unknown
```

---

# Relations SQLAlchemy

Relations attendues :

```text
Farm 1 ---- N Field
Field 1 ---- N FieldCrop
Crop 1 ---- N FieldCrop
```

Relations recommandées :

```text
farm.fields
field.farm
field.field_crops
field_crop.field
field_crop.crop
crop.field_crops
```

Configurer uniquement les cascades nécessaires pour éviter les données orphelines.

---

# Alembic

Initialiser Alembic dans `services/backend/`.

Fichiers attendus :

```text
services/backend/alembic.ini
services/backend/alembic/env.py
services/backend/alembic/versions/
```

Créer une migration initiale pour :

```text
farmer_profiles
farms
fields
crops
field_crops
```

La migration doit créer les tables, clés primaires, clés étrangères, contraintes d’unicité, index utiles et contraintes nécessaires.

Valider :

```bash
cd services/backend
alembic upgrade head
alembic downgrade -1
alembic upgrade head
```

Ne pas créer de migration destructive inutile.

---

# Remplacement du stockage in-memory

Remplacer le stockage in-memory du Sprint 3 dans le chemin principal d’exécution.

Services concernés :

```text
farmer_service
farm_service
field_service
crop_service
field_crop_service
```

Chaque service doit utiliser une session SQLAlchemy et gérer création, lecture, liste, ressources inexistantes, parents inexistants, doublons, commit, rollback, refresh et erreurs de contrainte.

Le stockage in-memory ne doit plus être utilisé dans l’exécution normale du backend.

---

# Compatibilité des endpoints

Conserver les endpoints existants et les contrats JSON autant que possible :

```http
GET /health
POST /discovery/question
GET /farmer/profile
POST /farmer/profile
GET /farms
POST /farms
GET /farms/{farm_id}
GET /farms/{farm_id}/fields
POST /farms/{farm_id}/fields
GET /fields/{field_id}
GET /crops
POST /crops
GET /crops/{crop_id}
POST /fields/{field_id}/crop
GET /fields/{field_id}/crop
```

Toute modification de contrat doit être minimale et documentée dans la Pull Request.

---

# Codes HTTP et erreurs

Utiliser :

```text
200 OK
201 Created
400 Bad Request
404 Not Found
409 Conflict
422 Unprocessable Entity
500 Internal Server Error
503 Service Unavailable
```

Gérer au minimum : `DATABASE_URL` absente, connexion impossible, session invalide, ressource inexistante, parent inexistant, doublon, contrainte étrangère invalide, deuxième culture active et rollback.

Ne jamais exposer mot de passe, URL PostgreSQL complète, credentials, stack trace ou secret dans les réponses API.

---

# Connexion Flutter au backend

Les écrans agricoles du Sprint 3 doivent maintenant utiliser le backend FastAPI.

```text
Flutter
  |
  | HTTP / JSON
  v
FastAPI
  |
  | SQLAlchemy
  v
PostgreSQL
```

Flutter ne doit jamais communiquer directement avec Supabase, contenir des credentials, utiliser `supabase_flutter`, contenir une URL ou une clé Supabase.

Créer ou compléter les services dans `apps/mobile/lib/services/` :

```text
farmer_api_service.dart
farm_api_service.dart
field_api_service.dart
crop_api_service.dart
field_crop_api_service.dart
```

Une classe consolidée est acceptable si elle reste simple et lisible.

Les services doivent utiliser `AGRIVITO_API_BASE_URL`, envoyer et décoder du JSON, gérer les codes HTTP, timeouts et erreurs réseau, sans secret.

---

# Parcours mobile attendu

L’utilisateur doit pouvoir :

1. ouvrir Agrivito ;
2. accéder au profil agricole ;
3. créer un profil ;
4. retrouver son profil après redémarrage du backend ;
5. créer et afficher ses exploitations ;
6. ouvrir une exploitation ;
7. créer et afficher ses parcelles ;
8. créer et afficher ses cultures ;
9. associer une culture à une parcelle ;
10. afficher la culture active de la parcelle.

États UI obligatoires :

```text
loading
success
empty
validation_error
network_error
backend_error
```

Messages simples et compréhensibles, sans erreur SQL visible.

Base URL :

```bash
flutter run --dart-define=AGRIVITO_API_BASE_URL=http://127.0.0.1:8000
```

Android Emulator :

```bash
flutter run --dart-define=AGRIVITO_API_BASE_URL=http://10.0.2.2:8000
```

---

# Tests backend

Vérifier au minimum : santé, discovery, CRUD profil, unicité, CRUD exploitations, CRUD parcelles, erreurs parent inexistant, CRUD cultures, association parcelle/culture, ressources inexistantes, interdiction de deux cultures actives, persistance, validation, codes HTTP et rollback.

La vraie base Supabase personnelle ne doit jamais être utilisée dans la CI.

Pour GitHub Actions, utiliser un service PostgreSQL dédié :

```env
DATABASE_URL=postgresql+psycopg://postgres:postgres@localhost:5432/agrivito_test
```

La CI doit démarrer PostgreSQL, attendre sa disponibilité, installer les dépendances, lancer `alembic upgrade head`, puis `pytest`.

Les tests doivent être isolés, indépendants de l’ordre, nettoyer leurs données et ne contenir aucun secret.

---

# Tests Flutter

Vérifier : lancement, navigation, mode découverte, profil, loading, empty state, succès, erreur réseau, validation, services mockés, listes exploitations/parcelles/cultures, association culture/parcelle et `flutter analyze`.

```bash
cd apps/mobile
flutter analyze
flutter test
```

---

# CI GitHub Actions

Conserver au minimum :

```text
Backend tests
Mobile checks
```

Backend : PostgreSQL service, installation Python et dépendances, migrations, pytest.

Mobile : installation Flutter, `flutter pub get`, `flutter analyze`, `flutter test`.

Les deux jobs doivent être verts.

---

# Documentation

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

Documenter l’objectif Sprint 4, l’architecture Flutter → FastAPI → PostgreSQL, le rôle temporaire de Supabase, `.env`, `DATABASE_URL`, les dépendances, migrations, lancement, tests, limites et sécurité.

---

# Commandes de validation

Backend :

```bash
cd services/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
alembic upgrade head
pytest
uvicorn app.main:app --reload
```

Vérifier :

```text
http://127.0.0.1:8000/health
http://127.0.0.1:8000/docs
```

Mobile :

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=AGRIVITO_API_BASE_URL=http://127.0.0.1:8000
```

---

# Règles de sécurité et qualité

Ne jamais commiter `.env`, vraie `DATABASE_URL`, mots de passe, clés Supabase/OpenAI/AWS, tokens, credentials ou données personnelles réelles.

Avant chaque commit :

```bash
git status
git diff --check
git check-ignore -v services/backend/.env
```

Le code doit rester simple, lisible, typé, maintenable, testable et cohérent avec les sprints précédents. Ne pas sur-concevoir, ne pas modifier l’architecture et ne pas ajouter de fonctionnalité hors périmètre.

---

# Définition de Done

Le Sprint 4 est terminé uniquement si :

- la branche dédiée existe ;
- SQLAlchemy, Psycopg et Alembic sont configurés ;
- `DATABASE_URL` est lue depuis l’environnement ;
- la migration initiale fonctionne ;
- les cinq tables et leurs clés étrangères existent ;
- le stockage in-memory principal est remplacé ;
- les données persistent ;
- les endpoints et contrats JSON restent cohérents ;
- Flutter utilise le backend ;
- loading et erreurs sont gérés ;
- les tests backend et Flutter passent ;
- GitHub Actions est vert ;
- la CI n’utilise pas la vraie base Supabase ;
- aucun secret ni technologie interdite n’est ajouté ;
- aucune fonctionnalité hors périmètre n’est développée.

---

# Pull Request attendue

Créer une Pull Request depuis :

```text
codex/sprint-4-postgresql-persistence
```

vers :

```text
main
```

Titre :

```text
Sprint 4 - PostgreSQL persistence and mobile API integration
```

Description :

```markdown
## Objectif

Ajouter la persistance PostgreSQL et connecter les écrans agricoles Flutter aux API backend Agrivito.

## Changements

- Ajout SQLAlchemy
- Ajout Psycopg
- Ajout Alembic
- Ajout de la configuration DATABASE_URL
- Ajout des modèles PostgreSQL
- Ajout de la migration initiale
- Remplacement du stockage in-memory
- Maintien des contrats API existants
- Connexion Flutter aux endpoints agricoles
- Ajout des états loading et erreur
- Ajout de PostgreSQL de test en CI
- Mise à jour des README
- Mise à jour des tests backend
- Mise à jour des tests mobile

## Tests réalisés

- alembic upgrade head
- pytest
- flutter analyze
- flutter test

## Limites connues

- Supabase utilisé uniquement comme PostgreSQL managé
- Pas de Supabase Auth
- Pas de Supabase Storage
- Pas d'authentification Cognito réelle
- Pas d'appel OpenAI réel
- Pas de déploiement AWS

## Documents respectés

- docs/13-Domain-Model.md
- docs/16-Data-Architecture.md
- docs/17-API-Design.md
- docs/19-Technology-ADRs.md
- docs/20-MVP-Backlog.md
- docs/21-Codex-Handbook.md
- docs/23-Brand-Name-Decision.md
- docs/25-Sprint-3-Plan.md
- docs/26-Sprint-4-Plan.md
```

---

# Rapport final attendu

À la fin, fournir : branche utilisée, fichiers créés/modifiés, migration et tables créées, tests backend et Flutter, résultat CI, limites connues et URL de la Pull Request.

Ne merge pas la Pull Request.

Attends la validation CTO.