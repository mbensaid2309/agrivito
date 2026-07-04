# Agrivito Mobile

Application Flutter du MVP Agrivito.

## Objectif

Poser le socle mobile du mode decouverte Sprint 2 avec une session locale, une limite de 3 questions, un Chat connecte au backend discovery et des ecrans Login / Register prepares pour Cognito via Amplify.

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

- Pas d'authentification Cognito effective au Sprint 2.
- Pas d'appel OpenAI depuis le mobile.
- Pas d'historique persistant complet.
- La session decouverte est locale et non persistante.
- Les reponses discovery sont mockees cote backend.
