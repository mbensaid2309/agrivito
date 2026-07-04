# PROMPT CODEX - SPRINT 1

Tu es Lead Developer sur le projet Agrivito.

Agrivito est une plateforme intelligente d’assistance à la décision agricole.

Ton rôle est de développer le socle technique initial du MVP en respectant strictement les documents validés dans le dossier `docs/`.

---

# Étape obligatoire avant de coder

Avant de modifier ou créer du code, lis les documents suivants :

```text
docs/19-Technology-ADRs.md
docs/20-MVP-Backlog.md
docs/21-Codex-Handbook.md
docs/22-Sprint-1-Plan.md
docs/23-Brand-Name-Decision.md
```

Tu dois respecter ces documents comme source de vérité.

Point important :

```text
AgriAI = ancien nom de travail
Agrivito = nom produit officiel
```

Toutes les nouvelles implémentations doivent utiliser **Agrivito**.

---

# Objectif du Sprint 1

Créer le socle technique initial du projet Agrivito.

À la fin du Sprint 1, le repository doit contenir :

```text
agrivito/
 ├── docs/
 ├── prompts/
 │    └── PROMPT-CODEX-SPRINT-1.md
 ├── apps/
 │    └── mobile/
 ├── services/
 │    └── backend/
 ├── infra/
 ├── scripts/
 ├── .github/
 │    └── workflows/
 ├── .gitignore
 └── README.md
```

---

# Travail demandé

## 1. Repository

Créer ou vérifier la structure du repository :

```text
agrivito/
 ├── docs/
 ├── prompts/
 │    └── PROMPT-CODEX-SPRINT-1.md
 ├── apps/
 │    └── mobile/
 ├── services/
 │    └── backend/
 ├── infra/
 ├── scripts/
 ├── .github/
 │    └── workflows/
 ├── .gitignore
 └── README.md
```

Ajouter `.gitkeep` dans les dossiers vides si nécessaire.

Ne pas créer de dossier `agri-ai`.

Ne pas créer `PROMPT-CODEX-SPRINT-1.md` à la racine.

Le prompt Sprint 1 doit rester dans :

```text
prompts/PROMPT-CODEX-SPRINT-1.md
```

---

## 2. Backend FastAPI

Initialiser le backend dans :

```text
services/backend/
```

Structure attendue :

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

Créer l’endpoint :

```http
GET /health
```

Réponse attendue :

```json
{
  "status": "ok",
  "service": "agrivito-backend"
}
```

---

## 3. Configuration backend

Créer `.env.example` dans :

```text
services/backend/.env.example
```

Contenu attendu :

```text
APP_ENV=local
APP_NAME=agrivito-backend
AWS_REGION=
AWS_S3_BUCKET=
AWS_COGNITO_USER_POOL_ID=
AWS_COGNITO_CLIENT_ID=
DATABASE_URL=
OPENAI_API_KEY=
LOG_LEVEL=INFO
```

Aucun secret réel ne doit être ajouté dans Git.

---

## 4. Tests backend

Ajouter des tests minimum :

* test `/health` ;
* test chargement application ;
* test configuration minimale ;
* test Trust Score mocké.

Les tests doivent être documentés dans le README backend.

---

## 5. Docker backend

Ajouter un `Dockerfile` backend dans :

```text
services/backend/Dockerfile
```

Le backend doit pouvoir démarrer en container.

Le endpoint `/health` doit répondre depuis le container.

Documenter les commandes Docker dans :

```text
services/backend/README.md
```

---

## 6. Application Flutter

Initialiser l’application Flutter dans :

```text
apps/mobile/
```

Créer les écrans initiaux :

* Home ;
* Chat ;
* Diagnostic Result ;
* Login ;
* Register ;
* History ;
* Profile.

Créer une navigation simple entre les écrans.

Prévoir une configuration pour l’URL backend.

Le nom affiché dans l’application doit être :

```text
Agrivito
```

---

## 7. Connexion mobile vers backend

Depuis l’application mobile :

* appeler `GET /health` ;
* afficher le statut backend ;
* afficher une erreur claire si le backend est indisponible.

La réponse attendue du backend est :

```json
{
  "status": "ok",
  "service": "agrivito-backend"
}
```

---

## 8. Structure IA backend

Créer la structure :

```text
services/backend/app/services/ai/
 ├── orchestrator.py
 ├── llm_service.py
 ├── vision_service.py
 ├── speech_service.py
 ├── trust_score_service.py
 └── prompts/
```

Pas d’appel réel OpenAI obligatoire dans le Sprint 1.

---

## 9. Trust Score MVP mocké

Créer un service Trust Score simple capable de retourner :

```json
{
  "score": 70,
  "level": "moyen",
  "explanation": "Score provisoire MVP."
}
```

Les niveaux doivent respecter :

| Score  | Niveau      | Comportement           |
| ------ | ----------- | ---------------------- |
| 80-100 | élevé       | réponse claire         |
| 60-79  | moyen       | réponse prudente       |
| 40-59  | faible      | hypothèses + questions |
| 0-39   | insuffisant | pas de conclusion      |

---

## 10. README

Créer ou compléter :

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

Les README doivent expliquer :

* objectif ;
* stack ;
* installation ;
* lancement local ;
* tests ;
* Docker pour backend ;
* limites connues.

Le README principal doit utiliser le nom :

```text
Agrivito
```

et non :

```text
AgriAI
```

---

## 11. CI GitHub Actions

Créer une CI minimale dans :

```text
.github/workflows/
```

Pipeline attendu :

Backend :

* installer dépendances ;
* lancer tests.

Mobile :

* installer Flutter ;
* lancer analyse statique ou vérification minimale.

Pas de déploiement automatique obligatoire dans Sprint 1.

---

# Contraintes strictes

Tu dois respecter strictement les documents validés.

Ne pas ajouter de technologie non validée.

Ne pas développer :

* paiement ;
* abonnement ;
* marketplace ;
* fournisseurs ;
* IoT ;
* satellite ;
* drone ;
* irrigation automatique ;
* pilotage d’équipement ;
* portail coopérative ;
* dashboard avancé.

Ne jamais appeler OpenAI depuis le mobile.

Ne jamais mettre de secret dans Git.

Ne pas introduire Kubernetes, EKS, microservices multiples, DynamoDB, MongoDB, Firebase ou Supabase.

Faire simple, lisible et maintenable.

---

# Règles de nommage

Utiliser :

```text
Agrivito
```

pour le nom produit affiché.

Utiliser :

```text
agrivito
```

pour les noms techniques.

Exemples :

```text
agrivito-backend
agrivito-mobile
agrivito-api
```

Ne pas utiliser `agri-ai` dans les nouveaux fichiers, dossiers, services ou configurations.

---

# Livrable attendu

Créer une Pull Request claire avec :

```markdown
## Objectif

## Changements

## Tests réalisés

## Instructions de lancement

## Limites connues

## Documents respectés
```

La PR doit rester limitée au Sprint 1.

Ne pas commencer les fonctionnalités du Sprint 2 sans validation.
