# Agrivito Mobile

Application Flutter mobile-first du MVP Agrivito.

## Objectif Sprint 8

Authentifier reellement l'utilisateur avec Supabase Auth et transmettre sa
session au backend, sans donner au mobile un acces direct aux tables metier.

## Stack

- Flutter et Dart
- package `http` pour appeler uniquement le backend Agrivito
- package officiel `image_picker` pour la galerie et la camera
- package officiel `supabase_flutter`, limite a l'authentification

## Installation

```bash
cd apps/mobile
flutter pub get
```

## Lancement local

Avec le backend sur la machine :

```bash
flutter run \
  --dart-define=AGRIVITO_API_BASE_URL=http://127.0.0.1:8000 \
  --dart-define=SUPABASE_URL=https://PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=PUBLIC_ANON_KEY
```

Avec un emulateur Android :

```bash
flutter run --dart-define=AGRIVITO_API_BASE_URL=http://10.0.2.2:8000
```

## Tests et analyse

```bash
flutter analyze
flutter test
```

Les services HTTP sont injectables. Les tests utilisent des implementations
factices et n'appellent ni Supabase, ni le backend, ni OpenAI.

## Authentification et session

`AuthService` encapsule Supabase Auth : inscription, connexion, restauration de
session, reinitialisation du mot de passe et deconnexion. `AuthBootstrap`
initialise le SDK uniquement si les deux variables publiques sont presentes.
Une configuration manquante produit un message lisible au lieu d'un crash.

`AuthenticatedHttpClient` ajoute `Authorization: Bearer <token>` uniquement aux
routes privees. Un token absent ou expire demande une nouvelle connexion. Les
routes `/health` et `/discovery/*` restent publiques. Le token n'est jamais
affiche ou journalise.

## Upload photo

L'ecran `Envoyer une photo` permet :

- selection galerie ;
- capture camera ;
- previsualisation ;
- remplacement et annulation ;
- upload multipart vers `POST /media/upload` avec session, ou vers
  `POST /discovery/media/upload` en mode anonyme ;
- envoi du contexte exploitation/parcelle/culture disponible ;
- confirmation et erreurs lisibles.

Les etats geres couvrent repos, selection, previsualisation, envoi, succes,
validation, permission, reseau, backend et limite decouverte. Les messages de
permission distinguent camera et galerie. `image_picker` s'appuie sur les
permissions natives de chaque plateforme ; les futurs runners iOS/Android
devront conserver leurs descriptions d'usage camera/photos.

La limite du mode decouverte est d'une photo par session. Le service utilise
uniquement `AGRIVITO_API_BASE_URL` et ne contient aucune configuration AWS.

Apres un upload reussi, `Analyser cette photo` ouvre le diagnostic avec la
reference du media et la meme session. L'ecran `Analyser une photo` accepte
aussi l'identifiant d'un media deja uploade.

## Diagnostic photo

Flutter appelle `POST /ai/photo-diagnosis` avec JWT, ou
`POST /discovery/photo-diagnosis` en mode anonyme. Il envoie l'identifiant
media, la question, la langue et les identifiants agricoles utiles seulement
pour une session authentifiee.
L'ecran affiche :

- qualite photo et problemes detectes ;
- instructions de reprise ;
- resume et observations visibles ;
- hypotheses prudentes ;
- recommandations ;
- questions complementaires et precautions ;
- Trust Score calcule par le backend ;
- invitation a creer un compte apres l'analyse decouverte.

Les etats couvrent repos, chargement, succes, photo pauvre, reprise necessaire,
informations insuffisantes, erreurs reseau/provider, media introuvable et limite
decouverte. Flutter ne lit jamais S3, n'appelle jamais OpenAI et ne calcule
jamais la qualite ou le Trust Score.

## Diagnostic texte

Le Chat authentifie appelle :

```text
POST /ai/diagnosis
```

Le mode anonyme utilise `POST /discovery/question`. Le payload prive contient la
question, la langue et les identifiants agricoles lorsqu'ils sont disponibles.
L'ecran affiche separement :

- resume ;
- observations ;
- hypotheses ;
- recommandations ;
- questions complementaires ;
- precautions ;
- niveau et explication de confiance.

Les etats geres sont idle, chargement, succes, validation, erreur reseau, erreur
provider, informations insuffisantes et limite decouverte. Les couleurs ne sont
pas le seul indicateur du niveau de confiance.

Le mobile ne calcule jamais le Trust Score et ne contient ni prompt systeme,
ni cle OpenAI, ni reponse brute du fournisseur.

## Ecrans

- Home
- Chat avec diagnostic texte et mode decouverte
- Upload photo avec galerie, camera et previsualisation
- Diagnostic photo avec qualite, reprise et Trust Score
- Diagnostic Result
- Login, Register, Forgot Password et Profile authentifie via Supabase Auth
- History et Profile
- Profil agricole
- Exploitations, parcelles et cultures
- Association culture / parcelle

## Contexte agricole

Les ecrans agricoles utilisent FastAPI pour creer et relire profil, exploitation,
parcelles, cultures et association active. Ils gerent chargement, etat vide,
succes, validation et erreurs reseau/backend.

```text
Flutter -> FastAPI -> PostgreSQL
```

Flutter ne contient aucune connexion PostgreSQL et n'utilise jamais le SDK
Supabase Database. La cle anon/publishable est une configuration cliente
publique ; aucune cle `service_role` ou secret JWT ne doit etre fourni au mobile.

## Mode decouverte

- Une session locale non persistante est creee automatiquement.
- L'utilisateur peut poser jusqu'a trois questions.
- Le Chat anonyme utilise `POST /discovery/question` ; le Chat authentifie
  utilise `POST /ai/diagnosis` avec son JWT.
- Apres la limite, l'application invite a creer un compte.
- Le mobile n'appelle jamais OpenAI directement.

## Configuration backend

L'URL est centralisee dans `AGRIVITO_API_BASE_URL`. Sa valeur locale par defaut
est `http://127.0.0.1:8000`.

## Limites connues

- Pas de Cognito reel ni de migration automatique depuis Supabase Auth.
- Pas d'historique persistant complet.
- Le choix mock ou live est entierement decide par le backend.
- Le diagnostic photo ne garantit aucune maladie et traite une seule image.
- La video, la voix, le RAG et l'historique avance ne sont pas inclus.
- Aucun acces direct a OpenAI, PostgreSQL ou aux tables Supabase n'est present.
