---

title: Sprint 1 Plan
version: 1.0
status: Approved
owner: CTO
approved_by: CEO
last_updated: 2026-06-29
------------------------

# AgriAI - Sprint 1 Plan

## Objectif

Ce document définit le premier sprint de développement du MVP AgriAI.

Le Sprint 1 doit créer le socle technique minimal permettant de démarrer le développement proprement avec Codex.

---

# Objectif du Sprint 1

À la fin du Sprint 1, AgriAI doit avoir :

* un repository GitHub structuré ;
* les documents validés dans `docs/` ;
* une application Flutter initialisée ;
* un backend FastAPI initialisé ;
* un endpoint backend `/health` fonctionnel ;
* une première connexion mobile vers backend ;
* une structure prête pour l’IA ;
* une structure prête pour AWS Amplify ;
* une base propre pour les prochains sprints.

---

# Durée recommandée

Sprint 1 recommandé :

```text
1 semaine
```

Le but n’est pas de développer tout le MVP.

Le but est de créer une base propre et stable.

---

# Priorité Sprint 1

Le Sprint 1 doit se concentrer uniquement sur :

1. structure repository ;
2. documentation ;
3. backend minimal ;
4. mobile minimal ;
5. communication mobile → backend ;
6. premières règles qualité ;
7. préparation intégration IA.

---

# Hors périmètre Sprint 1

Ne pas développer dans le Sprint 1 :

* authentification complète ;
* upload photo complet ;
* diagnostic photo complet ;
* historique complet ;
* base RDS complète ;
* interface avancée ;
* paiement ;
* marketplace ;
* IoT ;
* satellite ;
* drone ;
* portail coopérative ;
* automatisation agricole.

---

# Tâches Sprint 1

## S1-T1 - Créer le repository GitHub

### Objectif

Créer le repository principal :

```text
agri-ai
```

### Structure attendue

```text
agri-ai/
 ├── docs/
 ├── apps/
 │    └── mobile/
 ├── services/
 │    └── backend/
 ├── infra/
 ├── scripts/
 └── README.md
```

### Critères d’acceptation

* repository créé ;
* structure présente ;
* README présent ;
* `.gitignore` présent ;
* dossiers vides conservés avec `.gitkeep` si nécessaire.

---

## S1-T2 - Ajouter les documents validés

### Objectif

Ajouter les documents validés du projet.

### Fichiers attendus

```text
docs/
 ├── 01-Vision.md
 ├── 02-Mission-Values.md
 ├── 03-Product-Principles.md
 ├── 04-Product-Scope.md
 ├── 05-Business-Capabilities.md
 ├── 06-Personas.md
 ├── 07-Business-Model.md
 ├── 08-Product-Roadmap.md
 ├── 09-MVP-Scope.md
 ├── 10-High-Level-Architecture.md
 ├── 11-Technology-Decision-Framework.md
 ├── 12-MVP-User-Stories.md
 ├── 13-Domain-Model.md
 ├── 14-Quality-Reliability-Standards.md
 ├── 15-AI-Architecture.md
 ├── 16-Data-Architecture.md
 ├── 17-API-Design.md
 ├── 18-MVP-Technical-Architecture.md
 ├── 19-Technology-ADRs.md
 ├── 20-MVP-Backlog.md
 └── 21-Codex-Handbook.md
```

### Critères d’acceptation

* tous les documents sont présents ;
* aucun document validé n’est modifié ;
* les noms de fichiers sont corrects ;
* le README référence le dossier `docs/`.

---

## S1-T3 - Créer le README principal

### Objectif

Créer un README clair pour orienter les développeurs.

### Contenu attendu

Le README doit contenir :

* nom du projet ;
* vision courte ;
* stack technique ;
* structure du repository ;
* instructions backend ;
* instructions mobile ;
* règles de contribution ;
* lien vers les documents clés.

### Critères d’acceptation

* README lisible ;
* stack conforme au document `19-Technology-ADRs.md` ;
* structure conforme au document `21-Codex-Handbook.md`.

---

## S1-T4 - Initialiser le backend FastAPI

### Objectif

Créer le backend dans :

```text
services/backend/
```

### Structure attendue

```text
services/backend/
 ├── app/
 │    ├── main.py
 │    ├── api/
 │    ├── core/
 │    ├── models/
 │    ├── schemas/
 │    ├── services/
 │    └── repositories/
 ├── tests/
 ├── Dockerfile
 ├── requirements.txt
 ├── .env.example
 └── README.md
```

### Critères d’acceptation

* FastAPI démarre localement ;
* endpoint `/health` disponible ;
* Dockerfile présent ;
* `.env.example` présent ;
* structure modulaire créée.

---

## S1-T5 - Créer endpoint healthcheck

### Objectif

Créer un endpoint simple pour vérifier que le backend fonctionne.

### Endpoint

```http
GET /health
```

### Réponse attendue

```json
{
  "status": "ok",
  "service": "agri-ai-backend"
}
```

### Critères d’acceptation

* endpoint fonctionne localement ;
* test automatique présent ;
* réponse JSON conforme.

---

## S1-T6 - Ajouter configuration backend

### Objectif

Préparer la gestion de configuration.

### Variables attendues dans `.env.example`

```text
APP_ENV=local
APP_NAME=agri-ai-backend
AWS_REGION=
AWS_S3_BUCKET=
AWS_COGNITO_USER_POOL_ID=
AWS_COGNITO_CLIENT_ID=
DATABASE_URL=
OPENAI_API_KEY=
LOG_LEVEL=INFO
```

### Critères d’acceptation

* aucune valeur secrète réelle ;
* backend lit la configuration proprement ;
* erreur claire si variable critique absente.

---

## S1-T7 - Ajouter tests backend minimum

### Objectif

Avoir une première base de tests.

### Tests attendus

* test `/health` ;
* test chargement application ;
* test configuration minimale.

### Critères d’acceptation

* tests exécutables localement ;
* README backend explique comment lancer les tests.

---

## S1-T8 - Initialiser application Flutter

### Objectif

Créer l’application mobile dans :

```text
apps/mobile/
```

### Critères d’acceptation

* projet Flutter créé ;
* application démarre localement ;
* structure claire ;
* configuration API prévue ;
* README mobile présent.

---

## S1-T9 - Créer écrans mobiles initiaux

### Objectif

Créer les premiers écrans sans logique complexe.

### Écrans attendus

* Home ;
* Chat ;
* Diagnostic Result ;
* Login ;
* Register ;
* History ;
* Profile.

### Critères d’acceptation

* navigation fonctionnelle ;
* design simple ;
* pas de logique métier complexe ;
* textes provisoires acceptés.

---

## S1-T10 - Connexion mobile vers backend

### Objectif

Vérifier que l’application mobile peut appeler le backend.

### Fonction attendue

Depuis l’application mobile :

* appeler `GET /health` ;
* afficher l’état du backend.

### Critères d’acceptation

* appel HTTP fonctionnel ;
* message affiché dans l’application ;
* erreur affichée proprement si backend indisponible.

---

## S1-T11 - Préparer structure IA backend

### Objectif

Créer l’arborescence IA sans intégration complète OpenAI.

### Structure attendue

```text
services/backend/app/services/ai/
 ├── orchestrator.py
 ├── llm_service.py
 ├── vision_service.py
 ├── speech_service.py
 ├── trust_score_service.py
 └── prompts/
```

### Critères d’acceptation

* fichiers présents ;
* services mockés ou vides proprement ;
* pas d’appel réel OpenAI obligatoire dans Sprint 1 ;
* architecture conforme au document `15-AI-Architecture.md`.

---

## S1-T12 - Implémenter Trust Score MVP mocké

### Objectif

Créer un premier service Trust Score simple.

### Règles initiales

Le service doit pouvoir retourner :

```json
{
  "score": 70,
  "level": "moyen",
  "explanation": "Score provisoire MVP."
}
```

### Critères d’acceptation

* service backend disponible ;
* test unitaire présent ;
* niveaux conformes au document `14-Quality-Reliability-Standards.md`.

---

## S1-T13 - Préparer Docker backend

### Objectif

Permettre au backend de tourner en container.

### Critères d’acceptation

* Dockerfile fonctionnel ;
* backend démarre dans le container ;
* `/health` répond depuis le container ;
* README backend contient la commande Docker.

---

## S1-T14 - Préparer CI GitHub Actions

### Objectif

Créer une première CI simple.

### Pipeline attendu

Pour le backend :

* installer dépendances ;
* lancer tests ;
* vérifier démarrage application.

Pour le mobile :

* installer Flutter ;
* lancer analyse statique si possible ;
* vérifier build ou analyse minimale.

### Critères d’acceptation

* fichier workflow présent ;
* pipeline documentée ;
* pas de déploiement automatique obligatoire au Sprint 1.

---

# Livrable attendu Sprint 1

À la fin du Sprint 1, le repository doit contenir :

```text
agri-ai/
 ├── docs/
 ├── apps/mobile/
 ├── services/backend/
 ├── infra/
 ├── scripts/
 ├── .github/workflows/
 ├── .gitignore
 └── README.md
```

---

# Définition de Done Sprint 1

Le Sprint 1 est terminé si :

* repository structuré ;
* documents validés présents ;
* backend FastAPI démarre ;
* `/health` fonctionne ;
* tests backend minimum passent ;
* app Flutter démarre ;
* navigation mobile initiale existe ;
* mobile appelle `/health` ;
* structure IA présente ;
* Trust Score mocké présent ;
* Docker backend fonctionne ;
* CI initiale présente.

---

# Prompt recommandé pour Codex - Sprint 1

```text
Tu es Lead Developer sur le projet AgriAI.

Avant de coder, lis les documents dans le dossier docs/, en particulier :
- 19-Technology-ADRs.md
- 20-MVP-Backlog.md
- 21-Codex-Handbook.md
- 22-Sprint-1-Plan.md

Objectif du Sprint 1 :
Créer le socle technique initial du projet AgriAI.

Travail demandé :
1. Créer ou vérifier la structure du repository.
2. Initialiser le backend FastAPI dans services/backend/.
3. Ajouter endpoint GET /health.
4. Ajouter tests backend minimum.
5. Ajouter Dockerfile backend.
6. Initialiser app Flutter dans apps/mobile/.
7. Créer écrans initiaux : Home, Chat, Diagnostic Result, Login, Register, History, Profile.
8. Ajouter un appel mobile vers GET /health.
9. Préparer structure IA backend dans app/services/ai/.
10. Ajouter service Trust Score MVP mocké.
11. Ajouter README principal + README backend + README mobile.
12. Ajouter CI GitHub Actions minimale.

Contraintes :
- Respecter strictement les documents validés.
- Ne pas ajouter de technologie non validée.
- Ne pas implémenter paiement, marketplace, IoT, satellite, drone.
- Ne pas appeler OpenAI depuis le mobile.
- Ne mettre aucun secret dans Git.
- Faire simple, lisible, maintenable.

Livrable attendu :
Une Pull Request claire avec :
- objectif ;
- changements ;
- tests réalisés ;
- instructions de lancement ;
- limites connues ;
- documents respectés.
```

---

# Décision CTO

Le Sprint 1 ne doit pas chercher à impressionner.

Il doit poser des fondations propres.

La bonne réussite du Sprint 1, c’est un projet qui démarre proprement, que Codex peut continuer sans confusion.

---

**Statut : APPROVED**
