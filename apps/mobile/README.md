# Agrivito Mobile

Application Flutter du MVP Agrivito.

## Objectif

Permettre un parcours agricole Sprint 3 simple pour saisir un profil, des
exploitations, des parcelles et des cultures, tout en maintenant le mode
decouverte Sprint 2.

## Stack

- Flutter
- Dart
- package `http` pour appeler le backend

## Installation

```bash
cd apps/mobile
flutter pub get
```

## Lancement local

Avec backend local sur la machine :

```bash
flutter run --dart-define=AGRIVITO_API_BASE_URL=http://127.0.0.1:8000
```

Avec emulateur Android :

```bash
flutter run --dart-define=AGRIVITO_API_BASE_URL=http://10.0.2.2:8000
```

## Tests et verification

```bash
flutter analyze
flutter test
```

## Ecrans

- Home
- Chat avec mode decouverte
- Diagnostic Result
- Login prepare pour Cognito / Amplify
- Register prepare pour Cognito / Amplify
- History
- Profile
- Profil agricole
- Mes exploitations et detail d'exploitation
- Creation et liste des parcelles
- Mes cultures
- Association culture / parcelle

## Contexte agricole

Les donnees agricoles sont gerees par une couche locale in-memory. L'utilisateur
peut creer une exploitation, ajouter des parcelles, declarer des cultures et
associer une culture principale a une parcelle. Cette couche reste volontairement
simple en attendant la persistance backend PostgreSQL.

## Mode decouverte

Le mode decouverte fonctionne sans compte.

- Une session locale est creee automatiquement.
- L'utilisateur peut poser jusqu'a 3 questions.
- Le Chat appelle uniquement le backend FastAPI via `POST /discovery/question`.
- Le mobile n'appelle jamais OpenAI directement.
- Apres 3 questions, l'application invite a creer un compte plus tard.

## Configuration backend

L'URL backend est configuree par :

```text
AGRIVITO_API_BASE_URL
```

Par defaut, l'application utilise :

```text
http://127.0.0.1:8000
```

## Limites connues

- Pas d'authentification Cognito effective.
- Pas d'appel OpenAI depuis le mobile.
- Pas d'historique persistant complet.
- La session decouverte est locale et non persistante.
- Les reponses discovery sont mockees cote backend.
- Le contexte agricole mobile n'est pas persistant et est perdu au redemarrage.
- Les formulaires agricoles ne sont pas encore connectes aux endpoints backend.
