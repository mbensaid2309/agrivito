# Agrivito Mobile

Application Flutter initiale du MVP Agrivito.

## Objectif

Poser la base mobile du Sprint 1 avec une navigation simple, les premiers ecrans et un appel `GET /health` vers le backend FastAPI.

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

## Ecrans Sprint 1

- Home
- Chat
- Diagnostic Result
- Login
- Register
- History
- Profile

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

- Pas d'authentification Cognito effective au Sprint 1.
- Pas d'appel OpenAI depuis le mobile.
- Les ecrans metier affichent des donnees provisoires pour valider la navigation.
