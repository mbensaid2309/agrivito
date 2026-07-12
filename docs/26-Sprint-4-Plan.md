---
title: Sprint 4 Plan
version: 1.0
status: Approved
owner: CTO
approved_by: CEO
last_updated: 2026-07-12
---

# Agrivito - Sprint 4 Plan

## 1. Nom du Sprint

**Sprint 4 - PostgreSQL Persistence and Mobile API Integration**

---

## 2. Objectif

Le Sprint 4 doit rendre persistantes les données agricoles créées pendant le Sprint 3 et connecter l’application Flutter aux API agricoles du backend FastAPI.

À la fin du Sprint 4, Agrivito doit utiliser une base PostgreSQL Supabase accessible uniquement depuis le backend.

Supabase est utilisé comme service PostgreSQL managé pour accélérer le MVP.

Supabase ne remplace pas l’architecture cible AWS d’Agrivito.

---

## 3. Architecture cible Sprint 4

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
- le backend FastAPI est le seul composant autorisé à accéder à PostgreSQL ;
- le backend lit la configuration depuis `DATABASE_URL` ;
- aucune information sensible ne doit être commitée ;
- Supabase Auth, Storage, Realtime et Edge Functions sont hors périmètre ;
- la future migration vers AWS RDS PostgreSQL doit rester possible.

---

## 4. Contexte actuel

Les Sprints précédents ont livré :

### Sprint 1

- repository structuré ;
- backend FastAPI ;
- endpoint `GET /health` ;
- application Flutter initiale ;
- CI GitHub Actions ;
- structure IA ;
- Trust Score mocké.

### Sprint 2

- mode découverte sans compte ;
- session découverte locale ;
- limite de trois questions ;
- endpoint `POST /discovery/question` ;
- réponse agricole mockée ;
- écrans Login et Register ;
- préparation Cognito et Amplify.

### Sprint 3

- profil agricole ;
- exploitations ;
- parcelles ;
- cultures ;
- association culture / parcelle ;
- endpoints agricoles ;
- services backend in-memory ;
- écrans agricoles Flutter ;
- tests backend et mobile.

Limites actuelles :

- les données backend sont perdues au redémarrage ;
- le stockage backend est in-memory ;
- les données agricoles du mobile sont locales ;
- les formulaires Flutter ne sont pas entièrement connectés aux endpoints ;
- aucun modèle SQLAlchemy n’existe ;
- aucune migration Alembic n’existe ;
- aucune base PostgreSQL réelle n’est utilisée.

---

## 5. Décision d’architecture PostgreSQL

Pour le Sprint 4, Agrivito utilise une base PostgreSQL hébergée sur Supabase.

Supabase est utilisé uniquement comme PostgreSQL managé.

### Autorisé

- PostgreSQL ;
- SQLAlchemy ;
- Psycopg ;
- Alembic ;
- connexion SSL ;
- variable d’environnement `DATABASE_URL` ;
- requêtes SQL via le backend FastAPI.

### Interdit

- Supabase Auth ;
- Supabase Storage ;
- Supabase Realtime ;
- Supabase Edge Functions ;
- SDK Supabase dans Flutter ;
- accès direct du mobile à Supabase ;
- stockage de clés Supabase dans l’application mobile.

Cette décision est temporaire pour accélérer le MVP.

La future cible reste AWS RDS PostgreSQL.

---

## 6. Périmètre du Sprint 4

Le Sprint 4 couvre :

1. configuration PostgreSQL via `DATABASE_URL` ;
2. ajout de SQLAlchemy ;
3. ajout de Psycopg ;
4. ajout d’Alembic ;
5. création des modèles SQLAlchemy ;
6. création de la migration initiale ;
7. création des tables agricoles ;
8. remplacement du stockage in-memory backend ;
9. maintien des contrats API existants ;
10. connexion des écrans Flutter aux endpoints agricoles ;
11. gestion des états loading, succès, vide et erreur ;
12. tests backend avec une base isolée ;
13. tests mobile avec services mockés ;
14. mise à jour des README ;
15. maintien de la CI verte.

---

## 7. Configuration locale

La vraie chaîne de connexion doit être stockée uniquement dans :

```text
services/backend/.env
```

Exemple de format :

```env
DATABASE_URL=postgresql+psycopg://USER:PASSWORD@HOST:5432/postgres?sslmode=require
```

Le fichier `.env` doit rester ignoré par Git.

Le fichier suivant doit être présent dans le repository :

```text
services/backend/.env.example
```

Il doit contenir uniquement une valeur fictive :

```env
APP_NAME=agrivito-backend
APP_ENV=local
LOG_LEVEL=INFO
DATABASE_URL=postgresql+psycopg://user:password@host:5432/database?sslmode=require
```

La vraie URL Supabase ne doit jamais être présente dans GitHub.

---

## 8. Dépendances backend

Ajouter uniquement les dépendances nécessaires.

Dépendances attendues :

```text
SQLAlchemy
psycopg
alembic
```

La gestion des variables d’environnement doit rester cohérente avec la configuration existante du backend.

Ne pas ajouter :

- un ORM alternatif ;
- un framework de persistance supplémentaire ;
- un client Supabase ;
- une dépendance non nécessaire au Sprint 4.

---

## 9. Structure backend recommandée

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

Une structure légèrement différente est acceptable si elle reste simple, claire et cohérente.

---

## 10. Module de connexion PostgreSQL

Créer un module de connexion dans :

```text
services/backend/app/db/
```

Il doit fournir :

- un moteur SQLAlchemy ;
- une session factory ;
- une classe de base déclarative ;
- une dépendance FastAPI `get_db` ;
- une gestion correcte de l’ouverture de session ;
- une fermeture de session dans un bloc `finally` ;
- la lecture de `DATABASE_URL` depuis la configuration ;
- une erreur claire si `DATABASE_URL` est absente.

Exemple d’utilisation attendue dans FastAPI :

```python
from sqlalchemy.orm import Session
from fastapi import Depends

def endpoint(db: Session = Depends(get_db)):
    ...
```

Aucune URL de base ne doit être codée directement dans le code.

---

## 11. Modèles SQLAlchemy attendus

Créer les modèles suivants :

```text
FarmerProfile
Farm
Field
Crop
FieldCrop
```

Les noms de tables recommandés sont :

```text
farmer_profiles
farms
fields
crops
field_crops
```

Les identifiants peuvent être des UUID ou des chaînes générées par le backend.

Le choix doit rester cohérent avec les schémas existants.

---

## 12. Modèle FarmerProfile

Table :

```text
farmer_profiles
```

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

Contraintes :

- `id` est la clé primaire ;
- `user_id` est obligatoire ;
- `user_id` est unique ;
- `display_name` est obligatoire ;
- `user_type` est obligatoire ;
- `country` est obligatoire ;
- `preferred_language` est obligatoire ;
- `created_at` est généré automatiquement ;
- `updated_at` est mis à jour automatiquement.

Valeurs possibles pour `user_type` :

```text
farmer
advisor
cooperative_member
unknown
```

---

## 13. Modèle Farm

Table :

```text
farms
```

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

Contraintes :

- `id` est la clé primaire ;
- `user_id` est obligatoire ;
- `name` est obligatoire ;
- `country` est obligatoire ;
- `total_area` est optionnelle ;
- `area_unit` est optionnelle ;
- une exploitation peut avoir plusieurs parcelles.

Unités possibles :

```text
hectare
square_meter
acre
unknown
```

---

## 14. Modèle Field

Table :

```text
fields
```

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

Contraintes :

- `id` est la clé primaire ;
- `farm_id` est une clé étrangère vers `farms.id` ;
- `name` est obligatoire ;
- `area` est obligatoire ;
- `area_unit` est obligatoire ;
- une parcelle appartient à une exploitation ;
- une exploitation supprimée ne doit pas laisser de parcelles orphelines.

Valeurs possibles pour `water_access` :

```text
yes
no
seasonal
unknown
```

Valeurs possibles pour `irrigation_type` :

```text
none
drip
sprinkler
flood
manual
unknown
```

---

## 15. Modèle Crop

Table :

```text
crops
```

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

Contraintes :

- `id` est la clé primaire ;
- `name` est obligatoire ;
- `category` est obligatoire ;
- les autres champs sont optionnels.

Catégories possibles :

```text
vegetable
fruit_tree
cereal
legume
industrial_crop
other
unknown
```

Stades possibles :

```text
seedling
vegetative
flowering
fruiting
harvest
post_harvest
unknown
```

---

## 16. Modèle FieldCrop

Table :

```text
field_crops
```

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

Contraintes :

- `id` est la clé primaire ;
- `field_id` est une clé étrangère vers `fields.id` ;
- `crop_id` est une clé étrangère vers `crops.id` ;
- une association ne peut pas référencer une parcelle inexistante ;
- une association ne peut pas référencer une culture inexistante ;
- une parcelle ne peut avoir qu’une seule culture principale active pour le MVP.

Statuts possibles :

```text
active
planned
completed
unknown
```

---

## 17. Relations SQLAlchemy

Relations attendues :

```text
Farm 1 ---- N Field
Field 1 ---- N FieldCrop
Crop 1 ---- N FieldCrop
```

Les relations SQLAlchemy doivent être explicites.

Exemple :

```python
farm.fields
field.farm
field.field_crops
field_crop.field
field_crop.crop
crop.field_crops
```

Ne pas ajouter de relations inutiles.

---

## 18. Alembic

Initialiser Alembic dans :

```text
services/backend/
```

Fichiers attendus :

```text
services/backend/alembic.ini
services/backend/alembic/env.py
services/backend/alembic/versions/
```

Alembic doit utiliser les métadonnées SQLAlchemy des modèles Agrivito.

Créer une migration initiale pour les tables :

```text
farmer_profiles
farms
fields
crops
field_crops
```

Commande attendue :

```bash
cd services/backend
alembic upgrade head
```

La migration doit :

- créer les tables ;
- créer les clés primaires ;
- créer les clés étrangères ;
- créer les contraintes utiles ;
- être réversible avec `alembic downgrade -1`.

Ne pas créer de migration destructive inutile.

---

## 19. Remplacement du stockage in-memory

Les services suivants doivent utiliser SQLAlchemy :

```text
farmer_service
farm_service
field_service
crop_service
field_crop_service
```

Le stockage in-memory du Sprint 3 doit être retiré du chemin principal d’exécution.

Les services doivent recevoir une session SQLAlchemy.

Exemple :

```python
def create_farm(db: Session, payload: FarmCreate) -> Farm:
    ...
```

Les services doivent gérer :

- création ;
- lecture ;
- liste ;
- ressource inexistante ;
- doublon ;
- relation parente inexistante ;
- commit ;
- rollback ;
- refresh.

---

## 20. Compatibilité API

Les endpoints existants doivent rester disponibles.

### Système

```http
GET /health
POST /discovery/question
```

### Profil agricole

```http
GET /farmer/profile
POST /farmer/profile
```

### Exploitations

```http
GET /farms
POST /farms
GET /farms/{farm_id}
```

### Parcelles

```http
GET /farms/{farm_id}/fields
POST /farms/{farm_id}/fields
GET /fields/{field_id}
```

### Cultures

```http
GET /crops
POST /crops
GET /crops/{crop_id}
```

### Association culture / parcelle

```http
POST /fields/{field_id}/crop
GET /fields/{field_id}/crop
```

Les contrats JSON existants doivent être conservés autant que possible.

Toute modification de contrat doit être minimale et documentée.

---

## 21. Codes HTTP

Utiliser des codes HTTP cohérents.

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

Exemples :

- profil créé : `201` ;
- exploitation créée : `201` ;
- ressource récupérée : `200` ;
- exploitation inexistante : `404` ;
- profil déjà existant : `409` ;
- payload invalide : `422` ;
- base indisponible : `503`.

---

## 22. Gestion des erreurs backend

Le backend doit gérer au minimum :

- `DATABASE_URL` absente ;
- connexion PostgreSQL impossible ;
- session SQLAlchemy invalide ;
- ressource inexistante ;
- ressource parente inexistante ;
- champ obligatoire manquant ;
- doublon simple ;
- association culture / parcelle invalide ;
- tentative d’ajouter une deuxième culture active à une parcelle.

Les erreurs SQL ne doivent pas exposer :

- mot de passe ;
- hôte complet sensible ;
- chaîne `DATABASE_URL` ;
- stack trace dans la réponse API.

Les logs techniques restent côté backend.

---

## 23. Connexion mobile Flutter

Les écrans agricoles Flutter doivent utiliser le backend FastAPI.

Flux attendu :

```text
Formulaire Flutter
       |
       v
Service HTTP Flutter
       |
       v
Endpoint FastAPI
       |
       v
PostgreSQL
```

Le mobile ne doit pas utiliser :

```text
supabase_flutter
Supabase SDK
connexion PostgreSQL directe
```

---

## 24. Services API Flutter

Créer ou compléter les services dans :

```text
apps/mobile/lib/services/
```

Services recommandés :

```text
farmer_api_service.dart
farm_api_service.dart
field_api_service.dart
crop_api_service.dart
field_crop_api_service.dart
```

Une classe consolidée est acceptable si elle reste claire.

Les services doivent :

- utiliser `AGRIVITO_API_BASE_URL` ;
- envoyer les payloads JSON ;
- décoder les réponses JSON ;
- gérer les erreurs HTTP ;
- gérer les timeouts ;
- ne pas contenir de secrets ;
- ne pas contenir d’URL Supabase.

---

## 25. Parcours mobile attendu

L’utilisateur doit pouvoir :

1. ouvrir l’application ;
2. accéder au profil agricole ;
3. créer son profil ;
4. fermer puis relancer le backend ;
5. retrouver son profil ;
6. créer une exploitation ;
7. afficher la liste des exploitations ;
8. ouvrir une exploitation ;
9. créer une parcelle ;
10. afficher les parcelles de l’exploitation ;
11. créer une culture ;
12. afficher la liste des cultures ;
13. associer une culture à une parcelle ;
14. afficher la culture active de la parcelle.

---

## 26. États UI Flutter

Les écrans agricoles doivent gérer :

```text
loading
success
empty
validation_error
network_error
backend_error
```

Exemples de messages :

```text
Chargement en cours...
Aucune exploitation enregistrée.
Impossible de contacter le serveur.
Une erreur est survenue.
Les informations ont été enregistrées.
```

Ne pas afficher de messages techniques incompréhensibles à l’utilisateur.

---

## 27. Base URL Flutter

Le mobile doit continuer à lire :

```text
AGRIVITO_API_BASE_URL
```

Exemple sur macOS ou iOS Simulator :

```bash
flutter run \
  --dart-define=AGRIVITO_API_BASE_URL=http://127.0.0.1:8000
```

Exemple Android Emulator :

```bash
flutter run \
  --dart-define=AGRIVITO_API_BASE_URL=http://10.0.2.2:8000
```

Aucune URL backend ne doit être codée en dur dans plusieurs fichiers.

---

## 28. Tests backend

Les tests backend doivent vérifier :

- `GET /health` ;
- `POST /discovery/question` ;
- création et lecture du profil ;
- unicité du profil utilisateur ;
- création et lecture d’une exploitation ;
- liste des exploitations ;
- création d’une parcelle ;
- liste des parcelles ;
- lecture d’une parcelle ;
- erreur si exploitation inexistante ;
- création d’une culture ;
- liste des cultures ;
- lecture d’une culture ;
- association culture / parcelle ;
- récupération de l’association ;
- erreur si parcelle inexistante ;
- erreur si culture inexistante ;
- interdiction de deux cultures actives ;
- persistance réelle pendant un test ;
- validation des payloads ;
- codes HTTP.

La CI ne doit jamais utiliser la vraie base Supabase personnelle.

---

## 29. Base de test backend

Pour les tests automatisés, utiliser une base isolée.

Options acceptables :

1. service PostgreSQL dans GitHub Actions ;
2. base PostgreSQL locale de test ;
3. SQLite uniquement pour les tests unitaires si la compatibilité SQLAlchemy est garantie.

La préférence CTO est :

```text
PostgreSQL service dans GitHub Actions
```

Exemple de variable CI :

```env
DATABASE_URL=postgresql+psycopg://postgres:postgres@localhost:5432/agrivito_test
```

La base de test doit être créée et supprimée indépendamment de Supabase.

---

## 30. Isolation des tests

Les tests doivent :

- créer un schéma propre ;
- ne pas dépendre de l’ordre d’exécution ;
- nettoyer les données ;
- ne pas utiliser de vraies données personnelles ;
- ne pas utiliser la base de production ;
- ne pas utiliser les identifiants Supabase du CEO.

---

## 31. Tests Flutter

Les tests Flutter doivent vérifier :

- lancement de l’application ;
- navigation principale ;
- accès au mode découverte ;
- accès au profil agricole ;
- affichage du loading ;
- affichage de la liste vide ;
- affichage d’une liste remplie ;
- création d’une exploitation ;
- erreur réseau simulée ;
- erreur backend simulée ;
- validation des formulaires ;
- utilisation d’un service API mocké ;
- absence d’erreur `flutter analyze`.

Commandes attendues :

```bash
cd apps/mobile
flutter analyze
flutter test
```

---

## 32. CI GitHub Actions

La CI doit contenir au minimum :

```text
Backend tests
Mobile checks
```

Le job backend doit :

1. démarrer PostgreSQL de test ;
2. installer les dépendances ;
3. définir une `DATABASE_URL` de test ;
4. lancer les migrations ;
5. lancer `pytest`.

Le job mobile doit :

1. installer Flutter ;
2. lancer `flutter pub get` ;
3. lancer `flutter analyze` ;
4. lancer `flutter test`.

Aucune vraie clé Supabase ne doit être nécessaire dans la CI.

---

## 33. README

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

Documenter :

- objectif du Sprint 4 ;
- architecture Flutter → FastAPI → PostgreSQL ;
- rôle de Supabase ;
- utilisation de `DATABASE_URL` ;
- création du `.env` local ;
- installation des dépendances ;
- lancement des migrations ;
- lancement du backend ;
- lancement du mobile ;
- exécution des tests ;
- limites connues ;
- consignes de sécurité.

---

## 34. Commandes de lancement backend

```bash
cd services/backend

python3 -m venv .venv
source .venv/bin/activate

pip install -r requirements.txt

alembic upgrade head

uvicorn app.main:app --reload
```

Vérification :

```bash
curl http://127.0.0.1:8000/health
```

Documentation API :

```text
http://127.0.0.1:8000/docs
```

---

## 35. Commandes de lancement mobile

```bash
cd apps/mobile

flutter pub get

flutter run \
  --dart-define=AGRIVITO_API_BASE_URL=http://127.0.0.1:8000
```

Pour Android Emulator :

```bash
flutter run \
  --dart-define=AGRIVITO_API_BASE_URL=http://10.0.2.2:8000
```

---

## 36. Hors périmètre strict

Ne pas développer dans le Sprint 4 :

- authentification Cognito réelle ;
- Supabase Auth ;
- Supabase Storage ;
- Supabase Realtime ;
- Supabase Edge Functions ;
- S3 réel ;
- OpenAI réel ;
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
- RDS ;
- Sprint 5.

---

## 37. Règles de sécurité

Ne jamais commiter :

- vraie `DATABASE_URL` ;
- mot de passe PostgreSQL ;
- mot de passe Supabase ;
- clé Supabase ;
- clé OpenAI ;
- secret AWS ;
- token ;
- fichier `.env` ;
- credentials ;
- données personnelles réelles.

Avant chaque commit :

```bash
git status
git check-ignore -v services/backend/.env
```

Résultat attendu :

```text
services/backend/.env
```

doit être ignoré.

---

## 38. Règles d’architecture

Respecter la stack validée :

```text
Mobile : Flutter
Backend : FastAPI
ORM : SQLAlchemy
Driver PostgreSQL : Psycopg
Migrations : Alembic
Base : PostgreSQL
Hébergement PostgreSQL MVP : Supabase
Cloud cible future : AWS
```

Ne pas introduire :

```text
Kubernetes
EKS
microservices
Firebase
MongoDB
DynamoDB
Supabase SDK Flutter
accès PostgreSQL direct depuis Flutter
nouvelle stack non validée
```

---

## 39. Règles produit

Agrivito doit rester :

- simple ;
- mobile-first ;
- fiable ;
- compréhensible ;
- orienté agriculteur ;
- prêt pour une future IA contextualisée.

Le Sprint 4 est un sprint de persistance et d’intégration.

Il ne doit pas devenir un sprint de nouvelles fonctionnalités métier.

---

## 40. Définition de Done

Le Sprint 4 est terminé uniquement si :

- `DATABASE_URL` est lue depuis l’environnement ;
- SQLAlchemy est configuré ;
- Psycopg est configuré ;
- Alembic est configuré ;
- la migration initiale fonctionne ;
- les cinq tables agricoles existent ;
- les clés étrangères existent ;
- le stockage in-memory backend est remplacé ;
- les données persistent après redémarrage ;
- les endpoints existants restent disponibles ;
- les contrats JSON restent cohérents ;
- les écrans Flutter utilisent les endpoints backend ;
- les états loading et erreur sont gérés ;
- les tests backend passent ;
- les tests mobile passent ;
- GitHub Actions est vert ;
- la CI n’utilise pas la vraie base Supabase ;
- aucun secret n’est présent dans Git ;
- aucune fonctionnalité hors périmètre n’est ajoutée.

---

## 41. Branche de développement

```text
codex/sprint-4-postgresql-persistence
```

Codex doit créer cette branche depuis `main`.

Il ne doit pas travailler directement sur `main`.

---

## 42. Pull Request attendue

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
- Ajout d'une base PostgreSQL de test en CI
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

## 43. Statut

**APPROVED**