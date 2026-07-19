# PROMPT CODEX - SPRINT 8

Tu es Lead Developer sur le projet Agrivito.

Agrivito est une plateforme intelligente d’assistance à la décision agricole.

Ton rôle est de développer le Sprint 8 du MVP en respectant strictement les documents validés dans le dossier `docs/`.

Tu ne dois prendre aucune décision d’architecture.

---

# Étape obligatoire avant de coder

Avant toute modification de code, lis intégralement :

```text
docs/08-Product-Roadmap.md
docs/09-MVP-Scope.md
docs/12-MVP-User-Stories.md
docs/13-Domain-Model.md
docs/14-Quality-Reliability-Standards.md
docs/15-AI-Architecture.md
docs/16-Data-Architecture.md
docs/17-API-Design.md
docs/18-MVP-Technical-Architecture.md
docs/19-Technology-ADRs.md
docs/20-MVP-Backlog.md
docs/21-Codex-Handbook.md
docs/23-Brand-Name-Decision.md
docs/29-Sprint-7-Plan.md
docs/30-Sprint-8-Plan.md
```

Ces documents sont la source de vérité.

Important :

```text
AgriAI = ancien nom de travail
Agrivito = nom officiel du produit
```

Toutes les nouvelles implémentations doivent utiliser `Agrivito` ou `agrivito`.

---

# Règle bloquante sur la branche

Tu dois créer et utiliser exactement :

```text
codex/sprint-8-supabase-auth-data-ownership
```

Aucun autre nom de branche n’est autorisé.

Avant toute modification :

```bash
git checkout main
git pull origin main
git checkout -b codex/sprint-8-supabase-auth-data-ownership
```

Tu ne dois jamais travailler directement sur `main`.

Tu ne dois jamais merger toi-même la Pull Request.

---

# Nom du Sprint

```text
Sprint 8 - Supabase Authentication and Data Ownership Foundation
```

---

# Objectif

Ajouter une authentification réelle au MVP Agrivito avec Supabase Auth, protéger les endpoints privés et garantir qu’un utilisateur ne peut accéder qu’à ses propres données.

Supabase Auth est utilisé pour le MVP afin de réduire les coûts et accélérer les tests produit.

L’architecture doit rester indépendante du fournisseur d’identité afin de permettre une migration future vers AWS Cognito.

---

# Architecture obligatoire

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

Règles obligatoires :

- Flutter utilise Supabase uniquement pour l’authentification ;
- Flutter ne doit jamais accéder directement aux tables métier ;
- FastAPI reste l’unique point d’accès aux données métier ;
- FastAPI valide tous les JWT ;
- le backend extrait lui-même le `user_id` depuis le token ;
- le client ne choisit jamais librement son `user_id` ;
- Supabase Auth ne doit pas être couplé directement aux services métier ;
- les données métier restent dans PostgreSQL via SQLAlchemy ;
- aucune migration Cognito n’est développée dans ce sprint ;
- aucun appel Supabase réel ne doit être obligatoire dans la CI.

---

# Périmètre autorisé

Tu peux développer uniquement :

1. configuration Supabase Auth ;
2. intégration Flutter Supabase Auth ;
3. inscription email/mot de passe ;
4. connexion ;
5. déconnexion ;
6. restauration de session ;
7. récupération de mot de passe ;
8. écran utilisateur authentifié ;
9. abstraction backend `AuthProvider` ;
10. `SupabaseAuthProvider` ;
11. modèle `AuthenticatedUser` ;
12. dépendance `get_current_user()` ;
13. validation JWT ;
14. validation issuer ;
15. validation audience ;
16. protection des endpoints privés ;
17. suppression des `user_id` libres ;
18. association des données au current user ;
19. isolation des exploitations ;
20. isolation des parcelles ;
21. isolation des cultures ;
22. isolation des médias ;
23. isolation des diagnostics ;
24. maintien du mode découverte ;
25. gestion des erreurs d’authentification ;
26. migration DB si nécessaire ;
27. tests backend ;
28. tests Flutter ;
29. CI en mode mock ;
30. mise à jour des README ;
31. mise à jour des ADR et documents techniques ;
32. maintien des Sprints 1 à 7.

---

# Hors périmètre strict

Ne pas développer :

- Cognito réel ;
- migration automatique Supabase vers Cognito ;
- OAuth Google ;
- OAuth Apple ;
- OAuth Facebook ;
- MFA avancé ;
- RBAC avancé ;
- gestion d’organisation ;
- portail coopérative ;
- administration ;
- paiement ;
- abonnement ;
- marketplace ;
- RAG ;
- voix ;
- Darija vocale ;
- déploiement AWS ;
- Sprint 9.

Ne pas introduire :

- accès direct Flutter vers PostgreSQL ;
- accès direct Flutter vers les tables métier Supabase ;
- service role key dans Flutter ;
- framework d’authentification supplémentaire ;
- Firebase Auth ;
- Auth0 ;
- Keycloak ;
- Cognito SDK ;
- nouvelle technologie non validée.

---

# Travail demandé

## 1. Vérifier le socle existant

Vérifier :

```text
services/backend/
apps/mobile/
.github/workflows/
README.md
```

Vérifier que les fonctions des Sprints 1 à 7 restent présentes :

```http
GET /health
POST /discovery/question
POST /discovery/photo-diagnosis
POST /ai/diagnosis
POST /ai/photo-diagnosis
POST /media/upload
GET /media/{media_id}
```

Vérifier également les endpoints agricoles existants.

Ne casse pas les Sprints 1 à 7.

---

## 2. Ajouter les dépendances Flutter

Ajouter uniquement les dépendances nécessaires à Supabase Auth.

Package recommandé :

```text
supabase_flutter
```

Règles :

- utiliser une version stable ;
- ne pas ajouter plusieurs SDK d’authentification ;
- ne pas ajouter Cognito ;
- ne pas ajouter de package inutile.

---

## 3. Ajouter la configuration Flutter

Utiliser :

```text
SUPABASE_URL
SUPABASE_ANON_KEY
AGRIVITO_API_BASE_URL
```

Exemple :

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://example.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=public-anon-key \
  --dart-define=AGRIVITO_API_BASE_URL=http://127.0.0.1:8000
```

Règles :

- aucune valeur réelle committée ;
- aucune URL codée en dur ;
- seule la clé anonyme publique peut être utilisée ;
- aucune service role key dans Flutter ;
- aucune clé backend dans Flutter.

---

## 4. Initialiser Supabase dans Flutter

Initialiser Supabase avant le lancement de l’application.

Gérer :

- configuration absente ;
- configuration invalide ;
- mode test ;
- erreurs d’initialisation ;
- démarrage sans fuite de secret.

Ne pas bloquer les tests Flutter avec un appel réseau réel.

---

## 5. Créer une abstraction Flutter pour l’authentification

Créer un service dédié, par exemple :

```text
apps/mobile/lib/services/auth_service.dart
```

Le reste de l’application ne doit pas appeler directement le SDK Supabase partout.

Le service doit gérer :

```text
signUp
signIn
signOut
resetPassword
currentSession
currentUser
authStateChanges
getAccessToken
```

---

## 6. Créer ou finaliser les écrans Flutter

Créer ou compléter :

```text
LoginScreen
RegisterScreen
ForgotPasswordScreen
AuthenticatedProfileScreen
```

Fonctions attendues :

### Login

- email ;
- mot de passe ;
- validation ;
- connexion ;
- erreur identifiants ;
- lien mot de passe oublié ;
- lien inscription ;
- accès mode découverte.

### Register

- email ;
- mot de passe ;
- confirmation mot de passe ;
- validation ;
- inscription ;
- message de confirmation email si nécessaire.

### Forgot Password

- saisie email ;
- demande de réinitialisation ;
- confirmation utilisateur.

### Authenticated Profile

- email utilisateur ;
- état de session ;
- bouton déconnexion ;
- accès aux données privées.

---

## 7. États Flutter

Gérer :

```text
idle
loading
authenticated
unauthenticated
registration_success
invalid_credentials
email_not_confirmed
password_reset_sent
network_error
provider_error
session_expired
configuration_error
```

Messages recommandés :

```text
Connexion en cours...
Compte créé.
Identifiants incorrects.
Vérifiez votre adresse email.
Un lien de réinitialisation a été envoyé.
Votre session a expiré.
Le service d’authentification est temporairement indisponible.
```

---

## 8. Restaurer la session

Au démarrage :

1. lire la session Supabase ;
2. déterminer si l’utilisateur est connecté ;
3. afficher le bon parcours ;
4. écouter les changements de session ;
5. gérer le refresh token via le SDK ;
6. gérer la déconnexion ;
7. nettoyer l’état local.

Ne jamais stocker le mot de passe.

---

## 9. Ajouter le JWT aux appels backend

Tous les appels privés doivent envoyer :

```http
Authorization: Bearer <access_token>
```

Créer ou compléter un client API centralisé.

Le client doit :

- récupérer le token courant ;
- ajouter le header ;
- ne pas ajouter le token aux endpoints publics ;
- gérer 401 ;
- signaler une session expirée ;
- permettre une nouvelle connexion ;
- ne pas logger le token.

---

## 10. Ajouter la configuration backend

Ajouter :

```env
AUTH_PROVIDER=supabase
AUTH_MODE=mock
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_JWT_SECRET=
SUPABASE_JWKS_URL=
AUTH_AUDIENCE=authenticated
AUTH_ISSUER=
AUTH_TIMEOUT_SECONDS=10
```

Mettre à jour :

```text
services/backend/.env.example
```

Règles :

- aucune vraie valeur ;
- `AUTH_MODE=mock` en CI ;
- `AUTH_MODE=live` pour Supabase réel ;
- ne jamais utiliser la service role key pour vérifier un token ;
- vérifier audience et issuer ;
- configuration centralisée.

---

## 11. Créer AuthProvider

Créer une abstraction backend.

Interface conceptuelle :

```python
class AuthProvider:
    def verify_access_token(self, token: str) -> AuthenticatedUser:
        ...
```

Modèle :

```python
class AuthenticatedUser:
    id: str
    email: str | None
    roles: list[str]
    provider: str
```

Créer :

```text
SupabaseAuthProvider
MockAuthProvider
```

Le MockAuthProvider est utilisé dans les tests et la CI.

Ne pas implémenter CognitoAuthProvider maintenant.

---

## 12. Implémenter SupabaseAuthProvider

Le provider doit :

- vérifier la signature JWT ;
- vérifier l’expiration ;
- vérifier l’issuer ;
- vérifier l’audience ;
- extraire `sub` ;
- extraire l’email si présent ;
- extraire les rôles utiles ;
- retourner `AuthenticatedUser` ;
- convertir les erreurs en exceptions internes ;
- ne jamais logger le token complet.

Supporter selon la configuration validée :

```text
JWKS
ou secret JWT
```

Préférer JWKS si compatible avec la configuration Supabase retenue.

Ne pas inventer un mécanisme non supporté par la configuration réelle.

---

## 13. Créer get_current_user()

Créer une dépendance FastAPI :

```python
get_current_user()
```

Elle doit :

1. lire le header `Authorization` ;
2. vérifier le préfixe `Bearer` ;
3. récupérer le token ;
4. appeler `AuthProvider` ;
5. retourner `AuthenticatedUser` ;
6. retourner 401 si absent ou invalide.

Créer aussi si utile :

```python
get_optional_current_user()
```

Uniquement pour les parcours pouvant fonctionner en mode découverte ou authentifié.

---

## 14. Séparer endpoints publics et privés

### Publics

```http
GET /health
POST /discovery/question
POST /discovery/photo-diagnosis
```

### Privés

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

Adapter seulement aux endpoints réellement présents.

Ne pas créer artificiellement des endpoints non prévus sauf s’ils sont nécessaires au Sprint 8 et validés par le plan.

---

## 15. Supprimer les user_id libres

Pour les endpoints privés :

- retirer `user_id` des schémas d’entrée si possible ;
- sinon l’ignorer explicitement ;
- idéalement refuser toute tentative d’usurpation ;
- toujours utiliser `current_user.id` ;
- ne jamais faire confiance au client.

Exemple interdit :

```python
owner_id = request.user_id
```

Exemple attendu :

```python
owner_id = current_user.id
```

---

## 16. Propriété des données

Appliquer :

```text
current_user.id
   |
   +--> farmer_profiles.user_id
   +--> farms.user_id
   +--> fields via farm ownership
   +--> crops via ownership
   +--> media.user_id
   +--> diagnoses.user_id
```

Toute nouvelle donnée privée doit être associée à l’utilisateur authentifié.

---

## 17. Contrôler l’accès aux exploitations

Pour chaque opération :

- filtrer par `current_user.id` ;
- empêcher la lecture d’une exploitation étrangère ;
- empêcher la modification ;
- empêcher la suppression ;
- retourner 404 pour une ressource étrangère ;
- ne pas révéler son existence.

---

## 18. Contrôler l’accès aux parcelles

Vérifier :

- la parcelle existe ;
- la ferme parente appartient à l’utilisateur ;
- la création se fait uniquement sous une ferme autorisée ;
- les listes sont filtrées ;
- aucune parcelle étrangère n’est visible.

---

## 19. Contrôler l’accès aux cultures

Vérifier :

- la culture appartient à l’utilisateur ou à une parcelle autorisée ;
- l’association parcelle/culture est cohérente ;
- aucune culture étrangère n’est visible ;
- aucune modification indirecte d’une ressource étrangère.

---

## 20. Contrôler l’accès aux médias

Pour :

```http
POST /media/upload
GET /media/{media_id}
```

Règles :

- l’upload authentifié utilise `current_user.id` ;
- le client ne fournit pas le propriétaire ;
- un utilisateur ne lit pas un média étranger ;
- une session découverte reste distincte ;
- ne pas exposer un chemin système ;
- retourner 404 pour média étranger.

---

## 21. Contrôler l’accès aux diagnostics

Pour le diagnostic texte et photo :

- associer le diagnostic à `current_user.id` ;
- vérifier que le média appartient au current user ;
- vérifier la propriété des ressources agricoles ;
- ne jamais accepter un `user_id` libre ;
- ne jamais analyser un média étranger ;
- retourner 404 plutôt que révéler la ressource.

---

## 22. Gérer le profil utilisateur

Le profil agricole doit être associé au subject Supabase :

```text
current_user.id
```

Règles :

- un profil par utilisateur si le modèle le prévoit ;
- lecture uniquement du profil courant ;
- création ou mise à jour contrôlée ;
- aucun accès par identifiant arbitraire.

---

## 23. Vérifier le modèle de données

Inspecter :

```text
farmer_profiles
farms
fields
crops
media
diagnoses
```

Vérifier que la propriété est représentée directement ou indirectement.

Créer une migration seulement si nécessaire.

La migration doit :

- ajouter les colonnes ou index utiles ;
- préserver les données existantes ;
- avoir un downgrade propre ;
- ne pas faire de suppression destructive ;
- ne pas introduire de doublon inutile.

---

## 24. RLS et accès Supabase

Les tables métier restent utilisées par FastAPI.

Règles :

- pas d’accès public direct ;
- aucune policy publique large ;
- RLS activée si déjà prévue ;
- aucun accès Flutter via PostgREST aux tables métier ;
- aucune dépendance métier au SDK Supabase Database ;
- Supabase sert uniquement à Auth et PostgreSQL managé temporaire.

---

## 25. Mode découverte

Le mode découverte doit rester fonctionnel sans JWT.

Règles :

- endpoints découverte publics ;
- limites existantes conservées ;
- pas d’accès aux données authentifiées ;
- session découverte séparée ;
- pas d’historique privé complet ;
- invitation à créer un compte ;
- aucun rattachement automatique sans consentement.

---

## 26. Gestion des erreurs backend

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

```text
token absent
header invalide
token expiré
token mal signé
issuer invalide
audience invalide
subject absent
provider indisponible
configuration invalide
ressource étrangère
session expirée
```

Ne jamais exposer :

- JWT ;
- secret ;
- stack trace ;
- configuration interne ;
- détail permettant d’identifier une ressource étrangère.

---

## 27. Logs

Autorisé :

```text
request_id
provider
auth_success
auth_failure
error_type
endpoint
duration
user_id pseudonymisé
```

Interdit :

```text
JWT complet
refresh token
mot de passe
SUPABASE_JWT_SECRET
service role key
email complet non nécessaire
```

---

## 28. Tests backend

Tests minimum :

```text
GET /health accessible sans token
endpoint découverte accessible sans token
endpoint privé refuse sans token
header Bearer invalide refusé
token valide accepté
token expiré refusé
token mal signé refusé
issuer invalide refusé
audience invalide refusée
subject absent refusé
current_user correctement construit
MockAuthProvider fonctionne
aucun appel Supabase réel en CI
user_id du payload non utilisé
utilisateur A ne voit pas les farms de B
utilisateur A ne voit pas les fields de B
utilisateur A ne voit pas les crops de B
utilisateur A ne voit pas les médias de B
utilisateur A ne voit pas les diagnostics de B
upload média associé au current_user
diagnostic texte associé au current_user
diagnostic photo associé au current_user
média étranger refusé pour diagnostic photo
profil agricole isolé
mode découverte toujours fonctionnel
migrations upgrade/downgrade fonctionnent
endpoints Sprints 1 à 7 restent fonctionnels
```

---

## 29. Tests de sécurité backend

Tester :

```text
usurpation user_id impossible
token modifié refusé
token d’un autre issuer refusé
token d’une autre audience refusé
accès cross-user retourne 404
aucun token dans les logs
aucun secret dans les erreurs
aucune service role key utilisée
aucun accès direct public aux données métier
```

---

## 30. Tests Flutter

Tests minimum :

```text
écran login accessible
écran register accessible
écran mot de passe oublié accessible
validation email
validation mot de passe
confirmation mot de passe
inscription réussie mockée
erreur inscription affichée
connexion réussie mockée
identifiants invalides affichés
déconnexion fonctionne
restauration de session
session expirée
token ajouté aux appels privés
token absent sur endpoint public
401 déclenche parcours de reconnexion
mode découverte accessible
aucune service role key
flutter analyze sans erreur
```

Tous les appels Supabase doivent être mockés ou abstraits dans les tests.

---

## 31. CI GitHub Actions

Backend :

1. démarrer PostgreSQL ;
2. définir `AUTH_MODE=mock` ;
3. définir les variables factices nécessaires ;
4. installer les dépendances ;
5. exécuter `alembic upgrade head` ;
6. exécuter `pytest`.

Mobile :

1. installer Flutter ;
2. exécuter `flutter pub get` ;
3. exécuter `flutter analyze` ;
4. exécuter `flutter test`;
5. exécuter le build web si déjà présent dans la CI.

Règles :

- aucun appel Supabase réel ;
- aucune vraie clé ;
- aucun email réel ;
- aucun appel OpenAI réel ;
- aucun appel AWS réel ;
- tests déterministes.

---

## 32. Documentation

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
docs/17-API-Design.md
docs/18-MVP-Technical-Architecture.md
docs/19-Technology-ADRs.md
```

Documenter :

- décision Supabase Auth pour le MVP ;
- motivation coût et rapidité ;
- abstraction AuthProvider ;
- migration future vers Cognito ;
- configuration Flutter ;
- configuration backend ;
- validation JWT ;
- endpoints publics ;
- endpoints privés ;
- propriété des données ;
- mode découverte ;
- tests ;
- sécurité ;
- limites connues.

---

## 33. ADR obligatoire

Ajouter ou compléter une ADR :

```text
ADR - Supabase Auth for MVP
```

Elle doit préciser :

```text
Contexte
Décision
Alternatives
Conséquences
Sécurité
Réversibilité
Migration future vers Cognito
```

Décision :

- Supabase Auth est retenu pour le MVP ;
- FastAPI valide les tokens ;
- Flutter n’accède pas aux tables métier ;
- les services métier dépendent de CurrentUser, pas de Supabase ;
- Cognito reste une option future.

---

## 34. Validation backend

Exécuter :

```bash
cd services/backend

python3 -m venv .venv
source .venv/bin/activate

pip install -r requirements.txt

export AUTH_MODE=mock

alembic upgrade head
alembic downgrade -1
alembic upgrade head

pytest

uvicorn app.main:app --reload
```

Vérifier :

```text
http://127.0.0.1:8000/health
http://127.0.0.1:8000/docs
```

---

## 35. Validation Flutter

Exécuter :

```bash
cd apps/mobile

flutter pub get
flutter analyze
flutter test
flutter build web
```

Pour un test réel Supabase, uniquement avec des valeurs fournies par le propriétaire du projet :

```bash
flutter run \
  --dart-define=SUPABASE_URL=<SUPABASE_URL> \
  --dart-define=SUPABASE_ANON_KEY=<SUPABASE_ANON_KEY> \
  --dart-define=AGRIVITO_API_BASE_URL=http://127.0.0.1:8000
```

Ne jamais commiter ces valeurs.

---

# Contraintes de sécurité

Ne jamais commiter :

- `.env` ;
- `SUPABASE_JWT_SECRET` réel ;
- service role key ;
- access token ;
- refresh token ;
- mot de passe ;
- vraie `DATABASE_URL` ;
- vraie clé OpenAI ;
- credentials AWS ;
- données personnelles réelles.

Avant chaque commit :

```bash
git status
git diff --check
git check-ignore -v services/backend/.env
```

Rechercher aussi les secrets potentiels dans le diff.

---

# Contraintes de qualité

Le code doit être :

- simple ;
- lisible ;
- typé ;
- maintenable ;
- testable ;
- indépendant du provider ;
- cohérent avec les documents approuvés ;
- cohérent avec les Sprints précédents.

Ne pas sur-concevoir.

Ne pas intégrer Cognito.

Ne pas ajouter d’OAuth social.

Ne pas ajouter de fonctionnalité hors périmètre.

---

# Definition of Done

Le Sprint 8 est terminé uniquement si :

- Codex a utilisé exactement `codex/sprint-8-supabase-auth-data-ownership` ;
- aucun autre nom de branche n’a été utilisé ;
- Supabase Auth est intégré dans Flutter ;
- inscription fonctionne ;
- connexion fonctionne ;
- déconnexion fonctionne ;
- mot de passe oublié fonctionne ;
- session restaurée ;
- JWT envoyé aux endpoints privés ;
- aucun JWT envoyé aux endpoints publics si non nécessaire ;
- AuthProvider existe ;
- SupabaseAuthProvider existe ;
- MockAuthProvider existe ;
- AuthenticatedUser existe ;
- get_current_user existe ;
- signature JWT vérifiée ;
- expiration vérifiée ;
- issuer vérifié ;
- audience vérifiée ;
- endpoints privés protégés ;
- endpoints publics accessibles ;
- user_id n’est plus choisi librement ;
- farms isolées par utilisateur ;
- fields isolés par utilisateur ;
- crops isolées par utilisateur ;
- médias isolés par utilisateur ;
- diagnostics isolés par utilisateur ;
- profil isolé par utilisateur ;
- mode découverte reste fonctionnel ;
- tests backend passent ;
- tests Flutter passent ;
- GitHub Actions est vert ;
- aucun appel Supabase réel n’est obligatoire en CI ;
- aucun appel OpenAI ou AWS réel n’a lieu en CI ;
- aucun secret n’est présent dans Git ;
- les Sprints 1 à 7 restent fonctionnels ;
- aucune fonctionnalité hors périmètre n’est développée.

---

# Pull Request attendue

Créer une Pull Request depuis :

```text
codex/sprint-8-supabase-auth-data-ownership
```

vers :

```text
main
```

Titre :

```text
Sprint 8 - Supabase authentication and data ownership
```

Description attendue :

```markdown
## Objectif

Ajouter Supabase Auth au MVP Agrivito et garantir la propriété et l’isolation des données utilisateur.

## Changements

- Ajout Supabase Auth Flutter
- Ajout inscription
- Ajout connexion
- Ajout déconnexion
- Ajout mot de passe oublié
- Ajout restauration de session
- Ajout AuthProvider
- Ajout SupabaseAuthProvider
- Ajout MockAuthProvider
- Ajout AuthenticatedUser
- Ajout get_current_user
- Ajout validation JWT FastAPI
- Vérification issuer et audience
- Protection des endpoints privés
- Suppression des user_id libres
- Isolation farms
- Isolation fields
- Isolation crops
- Isolation media
- Isolation diagnoses
- Isolation profil
- Maintien du mode découverte
- Ajout tests backend
- Ajout tests Flutter
- Mise à jour CI
- Mise à jour README et ADR
- Maintien des Sprints 1 à 7

## Tests réalisés

- pytest
- flutter analyze
- flutter test
- flutter build web
- alembic upgrade head
- alembic downgrade -1
- git diff --check

## Limites connues

- Pas de Cognito réel
- Pas d’OAuth social
- Pas de MFA avancé
- Pas de migration automatique vers Cognito
- Pas de déploiement AWS
- Supabase Auth utilisé uniquement pour le MVP

## Documents respectés

- docs/08-Product-Roadmap.md
- docs/09-MVP-Scope.md
- docs/12-MVP-User-Stories.md
- docs/13-Domain-Model.md
- docs/14-Quality-Reliability-Standards.md
- docs/15-AI-Architecture.md
- docs/16-Data-Architecture.md
- docs/17-API-Design.md
- docs/18-MVP-Technical-Architecture.md
- docs/19-Technology-ADRs.md
- docs/20-MVP-Backlog.md
- docs/21-Codex-Handbook.md
- docs/23-Brand-Name-Decision.md
- docs/29-Sprint-7-Plan.md
- docs/30-Sprint-8-Plan.md
- prompts/PROMPT-CODEX-SPRINT-8.md
```

---

# Rapport final attendu

À la fin, fournir :

```text
branche utilisée
fichiers créés
fichiers modifiés
migration créée si nécessaire
provider Auth créé
dépendance CurrentUser créée
endpoints protégés
contrôles de propriété ajoutés
tests backend exécutés
tests Flutter exécutés
résultat migrations
résultat CI
limites connues
URL de la Pull Request
```

Ne merge pas la Pull Request.

Attends la validation CTO.