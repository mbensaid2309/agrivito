---
title: Sprint 8 Plan
version: 1.0
status: Approved
owner: CTO
approved_by: CEO
last_updated: 2026-07-19
---

# Agrivito - Sprint 8 Plan

## 1. Nom du Sprint

**Sprint 8 - Supabase Authentication and Data Ownership Foundation**

## 2. Objectif

Ajouter une authentification réelle au MVP Agrivito avec Supabase Auth, sécuriser les endpoints privés et garantir qu’un utilisateur ne peut accéder qu’à ses propres données.

Supabase Auth est utilisé pour le MVP afin de réduire les coûts et accélérer les tests produit. L’architecture doit rester indépendante du fournisseur afin de permettre une migration future vers AWS Cognito.

## 3. Valeur produit

À la fin du Sprint 8, un utilisateur doit pouvoir :

- créer un compte ;
- se connecter et se déconnecter ;
- récupérer son mot de passe ;
- conserver sa session ;
- accéder uniquement à son profil et à ses données ;
- utiliser le mode découverte sans compte.

## 4. Architecture cible

```text
Flutter
   |
   | Supabase Auth
   v
JWT Supabase
   |
   v
FastAPI
   |
   | validation JWT
   v
CurrentUser
   |
   v
Services métier
   |
   v
PostgreSQL
```

Abstraction obligatoire :

```text
AuthProvider
   |
   +--> SupabaseAuthProvider
   |
   +--> CognitoAuthProvider plus tard
```

Règles :

- Flutter utilise Supabase uniquement pour l’authentification ;
- FastAPI reste l’unique accès aux données métier ;
- Flutter n’accède jamais directement aux tables métier ;
- FastAPI valide tous les JWT ;
- le backend extrait lui-même le `user_id` ;
- le client ne choisit jamais librement son `user_id` ;
- les services métier ne dépendent pas directement de Supabase.

## 5. Périmètre Sprint 8

1. configuration Supabase Auth ;
2. intégration Flutter ;
3. inscription email/mot de passe ;
4. connexion ;
5. déconnexion ;
6. persistance de session ;
7. récupération de mot de passe ;
8. abstraction backend `AuthProvider` ;
9. `SupabaseAuthProvider` ;
10. validation JWT FastAPI ;
11. extraction de `CurrentUser` ;
12. protection des endpoints privés ;
13. suppression des `user_id` libres ;
14. contrôle de propriété des données ;
15. isolation des exploitations, parcelles, cultures, médias et diagnostics ;
16. maintien du mode découverte ;
17. tests backend et Flutter ;
18. CI en mode mock ;
19. documentation et ADR ;
20. maintien des Sprints 1 à 7.

## 6. Hors périmètre strict

- Cognito réel ;
- migration automatique vers Cognito ;
- OAuth Google, Apple ou Facebook ;
- MFA avancé ;
- RBAC avancé ;
- portail coopérative ;
- paiement ;
- abonnement ;
- marketplace ;
- déploiement AWS ;
- Sprint 9.

## 7. Fournisseur d’identité backend

Interface conceptuelle :

```python
class AuthProvider:
    def verify_access_token(self, token: str) -> AuthenticatedUser:
        ...
```

Modèle conceptuel :

```python
class AuthenticatedUser:
    id: str
    email: str | None
    roles: list[str]
    provider: str
```

Implémentation Sprint 8 :

```text
SupabaseAuthProvider
```

## 8. Configuration backend

```env
AUTH_PROVIDER=supabase
AUTH_MODE=mock
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_JWT_SECRET=
SUPABASE_JWKS_URL=
AUTH_AUDIENCE=authenticated
AUTH_ISSUER=
```

Règles :

- aucune vraie valeur dans Git ;
- `AUTH_MODE=mock` pour la CI ;
- `AUTH_MODE=live` pour Supabase réel ;
- issuer et audience doivent être vérifiés ;
- aucune service role key dans Flutter.

## 9. Configuration Flutter

Variables via `--dart-define` :

```text
SUPABASE_URL
SUPABASE_ANON_KEY
AGRIVITO_API_BASE_URL
```

Règles :

- seule la clé anonyme publique est autorisée ;
- aucune service role key ;
- aucune valeur codée en dur.

## 10. Écrans Flutter

Créer ou finaliser :

```text
LoginScreen
RegisterScreen
ForgotPasswordScreen
AuthenticatedProfileScreen
```

Fonctions :

- inscription ;
- connexion ;
- déconnexion ;
- mot de passe oublié ;
- affichage de l’utilisateur courant ;
- redirection selon l’état de session ;
- maintien du mode découverte.

## 11. Gestion de session

Le mobile doit :

- restaurer la session au démarrage ;
- écouter les changements d’authentification ;
- fournir le JWT au backend ;
- renouveler le token via Supabase ;
- se déconnecter proprement ;
- nettoyer l’état local ;
- ne jamais stocker le mot de passe.

## 12. Appels API Flutter

Tous les appels privés doivent envoyer :

```http
Authorization: Bearer <access_token>
```

Le client doit gérer :

- absence de session ;
- token expiré ;
- réponse 401 ;
- redirection vers la connexion ;
- suppression des faux `user_id`.

## 13. Validation JWT FastAPI

Créer :

```python
get_current_user()
```

Elle doit :

1. lire le header Authorization ;
2. vérifier le format Bearer ;
3. valider la signature ;
4. vérifier l’expiration ;
5. vérifier l’issuer ;
6. vérifier l’audience ;
7. extraire le `sub` ;
8. construire `AuthenticatedUser` ;
9. retourner 401 si le token est invalide.

## 14. Endpoints publics

```http
GET /health
POST /discovery/question
POST /discovery/photo-diagnosis
```

## 15. Endpoints privés

Protéger au minimum :

```http
GET /farmer/profile
POST /farmer/profile

GET /farms
POST /farms
GET /farms/{farm_id}
PATCH /farms/{farm_id}
DELETE /farms/{farm_id}

GET /farms/{farm_id}/fields
POST /farms/{farm_id}/fields
GET /fields/{field_id}

GET /crops
POST /crops
GET /crops/{crop_id}

POST /fields/{field_id}/crop
GET /fields/{field_id}/crop

POST /media/upload
GET /media/{media_id}

POST /ai/diagnosis
POST /ai/photo-diagnosis
```

Tout endpoint privé doit utiliser `get_current_user()`.

## 16. Propriété des données

Le backend associe les données à `current_user.id` :

```text
current_user.id
   |
   +--> farmer_profiles.user_id
   +--> farms.user_id
   +--> fields via farm ownership
   +--> crops via user ou field ownership
   +--> media.user_id
   +--> diagnoses.user_id
```

Le backend ne doit jamais prendre `user_id` depuis le corps d’une requête privée.

## 17. Contrôles d’accès

Avant toute lecture ou modification :

- vérifier que la ressource appartient à l’utilisateur ;
- vérifier la cohérence farm/field/crop ;
- vérifier la propriété du média ;
- vérifier la propriété du diagnostic ;
- retourner 404 pour une ressource étrangère ;
- ne jamais révéler les données d’un autre utilisateur.

## 18. Base de données

Vérifier la propriété directe ou indirecte des tables :

```text
farmer_profiles
farms
fields
crops
media
diagnoses
```

Créer une migration uniquement si nécessaire.

Règles :

- pas de duplication inutile ;
- pas de suppression destructive ;
- downgrade propre ;
- index utiles sur les colonnes de propriété.

## 19. RLS Supabase

- aucune policy publique large ;
- aucune lecture directe des tables métier depuis Flutter ;
- le backend reste responsable des contrôles d’accès ;
- conserver ou renforcer la révocation de l’accès public direct.

## 20. Mode découverte

Le mode découverte doit continuer sans compte :

- aucun JWT requis ;
- limites existantes conservées ;
- aucun accès aux données privées ;
- invitation à créer un compte ;
- rattachement futur d’une session hors Sprint 8.

## 21. Gestion des erreurs

Gérer :

```text
401 Unauthorized
403 Forbidden
404 Not Found
409 Conflict
422 Unprocessable Entity
503 Service Unavailable
```

Cas minimum :

- token absent ;
- token invalide ;
- token expiré ;
- audience invalide ;
- issuer invalide ;
- ressource étrangère ;
- fournisseur indisponible ;
- configuration invalide.

## 22. Logs

Autorisé :

```text
request_id
authenticated_user_id pseudonymisé
provider
auth_success
auth_failure
error_type
endpoint
duration
```

Interdit :

```text
JWT complet
refresh token
mot de passe
SUPABASE_JWT_SECRET
service role key
```

## 23. Tests backend

Tests minimum :

- endpoint public accessible sans token ;
- endpoint privé refusé sans token ;
- token valide accepté ;
- token expiré refusé ;
- token mal signé refusé ;
- audience invalide refusée ;
- issuer invalide refusé ;
- `CurrentUser` correctement extrait ;
- `user_id` du payload refusé ou ignoré ;
- utilisateur A ne voit pas les farms de B ;
- utilisateur A ne voit pas les fields de B ;
- utilisateur A ne voit pas les crops de B ;
- utilisateur A ne voit pas les médias de B ;
- utilisateur A ne voit pas les diagnostics de B ;
- upload média associé au current user ;
- diagnostic texte associé au current user ;
- diagnostic photo associé au current user ;
- mode découverte fonctionne sans token ;
- mode mock fonctionne sans Supabase réel ;
- Sprints 1 à 7 toujours fonctionnels.

## 24. Tests Flutter

Tests minimum :

- écran login ;
- écran register ;
- écran mot de passe oublié ;
- inscription réussie ;
- erreur inscription ;
- connexion réussie ;
- mauvais identifiants ;
- déconnexion ;
- restauration de session ;
- session expirée ;
- JWT ajouté aux appels privés ;
- 401 redirige vers login ;
- mode découverte accessible ;
- aucune service role key ;
- `flutter analyze` sans erreur.

## 25. CI GitHub Actions

Backend :

1. démarrer PostgreSQL ;
2. configurer `AUTH_MODE=mock` ;
3. installer les dépendances ;
4. exécuter les migrations ;
5. exécuter `pytest`.

Mobile :

1. installer Flutter ;
2. exécuter `flutter pub get` ;
3. exécuter `flutter analyze` ;
4. exécuter `flutter test`.

Aucun appel réel Supabase, OpenAI ou AWS n’est obligatoire en CI.

## 26. Documentation

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
docs/17-API-Design.md
docs/18-MVP-Technical-Architecture.md
docs/19-Technology-ADRs.md
```

Ajouter une ADR :

```text
ADR - Supabase Auth for MVP
```

Décision :

- Supabase Auth est utilisé pour le MVP ;
- FastAPI valide les JWT ;
- les services métier restent indépendants du provider ;
- aucune donnée métier n’est accédée directement depuis Flutter ;
- une migration future vers Cognito reste possible.

## 27. Contraintes de sécurité

Ne jamais commiter :

- `.env` ;
- `SUPABASE_JWT_SECRET` réel ;
- service role key ;
- access token ;
- refresh token ;
- mot de passe ;
- vraie `DATABASE_URL` ;
- vraie clé OpenAI ;
- credentials AWS.

Avant chaque commit :

```bash
git status
git diff --check
git check-ignore -v services/backend/.env
```

## 28. Definition of Done

Le Sprint 8 est terminé uniquement si :

- Supabase Auth est intégré dans Flutter ;
- inscription, connexion, déconnexion et mot de passe oublié fonctionnent ;
- la session est restaurée ;
- le JWT est envoyé au backend ;
- `AuthProvider` existe ;
- `SupabaseAuthProvider` existe ;
- `CurrentUser` existe ;
- le JWT est validé côté FastAPI ;
- issuer et audience sont vérifiés ;
- les endpoints privés sont protégés ;
- les endpoints publics restent publics ;
- `user_id` n’est plus choisi librement ;
- farms, fields, crops, médias et diagnostics sont isolés par utilisateur ;
- le mode découverte reste fonctionnel ;
- les tests backend passent ;
- les tests Flutter passent ;
- la CI est verte ;
- aucun secret n’est présent dans Git ;
- aucun appel Supabase réel n’est obligatoire en CI ;
- les Sprints 1 à 7 restent fonctionnels.

## 29. Branche de développement

Codex doit créer et utiliser exactement :

```text
codex/sprint-8-supabase-auth-data-ownership
```

Règle bloquante :

```text
Aucun autre nom de branche n’est autorisé.
```

Codex doit partir du dernier état de `main`.

Codex ne doit jamais travailler directement sur `main`.

Codex ne doit jamais merger la Pull Request.

## 30. Pull Request attendue

Titre :

```text
Sprint 8 - Supabase authentication and data ownership
```

Description minimale :

```markdown
## Objectif

Ajouter Supabase Auth au MVP Agrivito et garantir la propriété et l’isolation des données utilisateur.

## Changements

- Ajout Supabase Auth Flutter
- Ajout inscription, connexion, déconnexion et mot de passe oublié
- Ajout restauration de session
- Ajout AuthProvider et SupabaseAuthProvider
- Ajout CurrentUser
- Ajout validation JWT FastAPI
- Protection des endpoints privés
- Suppression des user_id libres
- Isolation farms, fields, crops, media et diagnoses
- Maintien du mode découverte
- Ajout tests backend et Flutter
- Mise à jour CI, README et ADR
- Maintien des Sprints 1 à 7

## Tests réalisés

- pytest
- flutter analyze
- flutter test
- alembic upgrade head
- alembic downgrade -1
- git diff --check

## Limites connues

- Pas de Cognito réel
- Pas d’OAuth social
- Pas de MFA avancé
- Pas de migration automatique vers Cognito
- Pas de déploiement AWS
```

## 31. Statut

**APPROVED**