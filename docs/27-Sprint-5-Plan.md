---
title: Sprint 5 Plan
version: 1.0
status: Approved
owner: CTO
approved_by: CEO
last_updated: 2026-07-14
---

# Agrivito - Sprint 5 Plan

## 1. Nom du Sprint

**Sprint 5 - AI Text Diagnosis Foundation**

---

## 2. Objectif

Le Sprint 5 doit remplacer la réponse agricole mockée par une première capacité réelle de diagnostic texte utilisant OpenAI depuis le backend FastAPI.

À la fin du Sprint 5, Agrivito doit permettre à un utilisateur de poser une question agricole depuis l’application Flutter et de recevoir une réponse structurée, prudente, contextualisée et accompagnée d’un Trust Score calculé par Agrivito.

Le Sprint 5 constitue la première implémentation réelle du moteur d’assistance agronomique d’Agrivito.

---

## 3. Valeur produit

Le Sprint 5 doit transformer Agrivito d’une application avec réponses simulées en un véritable assistant agricole intelligent.

La valeur livrée doit être visible immédiatement pour l’utilisateur :

- poser une question agricole ;
- recevoir une réponse utile ;
- comprendre les hypothèses possibles ;
- connaître le niveau de confiance ;
- recevoir des recommandations prudentes ;
- savoir quelles informations supplémentaires fournir ;
- éviter une réponse affirmative lorsque le contexte est insuffisant.

Agrivito ne doit pas se comporter comme un chatbot générique.

Agrivito doit se comporter comme un assistant agronomique prudent, structuré et contextualisé.

---

## 4. Architecture cible Sprint 5

```text
Application Flutter
        |
        | HTTP / JSON
        v
Backend FastAPI
        |
        v
AI Orchestrator
        |
        +--------------------------+
        |                          |
        v                          v
Contexte agricole             OpenAI API
PostgreSQL                    LLM texte
        |                          |
        +-------------+------------+
                      |
                      v
              Trust Score Engine
                      |
                      v
            Réponse structurée API
```

Règles obligatoires :

- Flutter ne communique jamais directement avec OpenAI ;
- seul le backend FastAPI appelle OpenAI ;
- la clé OpenAI reste uniquement côté backend ;
- le contexte agricole est construit côté backend ;
- le Trust Score est calculé par Agrivito ;
- le LLM ne décide pas seul du niveau de confiance ;
- la réponse doit respecter un format structuré et stable ;
- le backend doit pouvoir fonctionner en mode mock pour les tests ;
- aucun appel OpenAI réel ne doit être effectué dans la CI.

---

## 5. Contexte actuel

Les Sprints précédents ont livré :

### Sprint 1

- repository structuré ;
- backend FastAPI ;
- application Flutter ;
- endpoint `GET /health` ;
- structure IA initiale ;
- Trust Score mocké ;
- CI GitHub Actions.

### Sprint 2

- mode découverte ;
- session découverte locale ;
- limite de trois questions ;
- endpoint `POST /discovery/question` ;
- réponse agricole mockée ;
- écrans Login et Register préparés.

### Sprint 3

- profil agricole ;
- exploitations ;
- parcelles ;
- cultures ;
- association culture / parcelle ;
- endpoints agricoles ;
- écrans agricoles Flutter.

### Sprint 4

- PostgreSQL ;
- Supabase utilisé uniquement comme PostgreSQL managé ;
- SQLAlchemy ;
- Psycopg ;
- Alembic ;
- modèles persistants ;
- migration initiale ;
- remplacement du stockage in-memory ;
- connexion Flutter aux endpoints agricoles ;
- tests PostgreSQL dans GitHub Actions.

Limites actuelles :

- la réponse agricole reste mockée ;
- aucun appel OpenAI réel n’existe ;
- aucun orchestrateur IA complet n’existe ;
- le contexte agricole n’est pas injecté dans une requête IA ;
- le Trust Score n’est pas encore calculé à partir de critères réels ;
- aucune politique anti-hallucination complète n’est appliquée ;
- l’écran Chat n’utilise pas encore un endpoint de diagnostic réel.

---

## 6. Périmètre Sprint 5

Le Sprint 5 couvre :

1. création de l’endpoint `POST /ai/diagnosis` ;
2. création d’un AI Orchestrator ;
3. intégration OpenAI côté backend ;
4. configuration par variable `OPENAI_API_KEY` ;
5. construction du contexte agricole ;
6. récupération optionnelle du profil ;
7. récupération optionnelle de l’exploitation ;
8. récupération optionnelle de la parcelle ;
9. récupération optionnelle de la culture ;
10. création d’un format de réponse structuré ;
11. création d’un service de diagnostic texte ;
12. création d’un Trust Score Engine MVP ;
13. création de règles anti-hallucination ;
14. gestion des informations insuffisantes ;
15. gestion des erreurs OpenAI ;
16. gestion des timeouts ;
17. connexion de l’écran Chat Flutter ;
18. maintien du mode découverte ;
19. limitation de trois questions en mode découverte ;
20. tests backend avec OpenAI mocké ;
21. tests Flutter avec API mockée ;
22. mise à jour des README ;
23. maintien de la CI verte ;
24. maintien de toutes les fonctions des Sprints 1 à 4.

---

## 7. Décision d’architecture OpenAI

OpenAI est le fournisseur LLM validé pour le MVP.

L’intégration doit respecter les règles suivantes :

### Autorisé

- OpenAI API côté backend ;
- modèle texte configurable ;
- réponse structurée ;
- timeout configurable ;
- retries limités ;
- mock OpenAI pour les tests ;
- journalisation technique sans données sensibles ;
- prompts versionnés dans le code backend.

### Interdit

- appel OpenAI directement depuis Flutter ;
- clé OpenAI dans Flutter ;
- clé OpenAI dans GitHub ;
- clé OpenAI dans les README ;
- clé OpenAI dans les logs ;
- appel OpenAI réel dans la CI ;
- dépendance directe entre les routes API et le SDK OpenAI ;
- réponse libre non validée ;
- Trust Score fourni uniquement par le LLM ;
- sauvegarde incontrôlée des données utilisateur chez le fournisseur.

---

## 8. Configuration

Ajouter les variables suivantes :

```env
OPENAI_API_KEY=
OPENAI_MODEL=
OPENAI_TIMEOUT_SECONDS=30
AI_PROVIDER=openai
AI_MODE=live
```

Le fichier local réel reste :

```text
services/backend/.env
```

Mettre à jour :

```text
services/backend/.env.example
```

Avec uniquement des valeurs fictives :

```env
APP_NAME=agrivito-backend
APP_ENV=local
LOG_LEVEL=INFO
DATABASE_URL=postgresql+psycopg://user:password@host:5432/database?sslmode=require
OPENAI_API_KEY=replace-with-your-openai-api-key
OPENAI_MODEL=replace-with-approved-model
OPENAI_TIMEOUT_SECONDS=30
AI_PROVIDER=openai
AI_MODE=mock
```

Règles :

- `AI_MODE=mock` doit permettre de lancer les tests sans appel externe ;
- `AI_MODE=live` active les appels OpenAI réels ;
- si `AI_MODE=live`, `OPENAI_API_KEY` est obligatoire ;
- le modèle doit être configurable ;
- aucun modèle ne doit être codé en dur dans plusieurs fichiers.

---

## 9. Dépendances backend

Ajouter uniquement la dépendance nécessaire :

```text
openai
```

Réutiliser les dépendances existantes :

```text
FastAPI
Pydantic
SQLAlchemy
Psycopg
Alembic
```

Ne pas ajouter :

- LangChain ;
- LlamaIndex ;
- base vectorielle ;
- framework multi-agents ;
- outil RAG ;
- nouvelle base de données ;
- dépendance non nécessaire au Sprint 5.

Le Sprint 5 doit rester simple.

---

## 10. Structure backend recommandée

```text
services/backend/app/
├── ai/
│   ├── orchestrator.py
│   ├── provider.py
│   ├── openai_provider.py
│   ├── mock_provider.py
│   ├── prompts.py
│   ├── response_parser.py
│   ├── trust_score.py
│   └── exceptions.py
├── api/
│   └── ai_diagnosis.py
├── schemas/
│   └── ai_diagnosis.py
├── services/
│   └── ai_diagnosis_service.py
└── core/
    └── config.py
```

Une structure légèrement différente est acceptable si elle reste simple et cohérente.

Ne pas créer de microservice IA séparé.

Le moteur IA reste dans le backend FastAPI pour le MVP.

---

## 11. Endpoint principal

Créer :

```http
POST /ai/diagnosis
```

Exemple de requête :

```json
{
  "question": "Pourquoi les feuilles de mes tomates jaunissent ?",
  "language": "fr",
  "user_id": "demo-user",
  "farm_id": "optional-farm-id",
  "field_id": "optional-field-id",
  "crop_id": "optional-crop-id",
  "discovery_session_id": "optional-session-id"
}
```

Règles :

- `question` est obligatoire ;
- `question` ne doit pas être vide ;
- `language` a une valeur par défaut ;
- les identifiants de contexte sont optionnels ;
- le backend doit vérifier l’existence des ressources ;
- le backend doit récupérer uniquement le contexte utile ;
- le backend ne doit pas exiger une exploitation pour répondre ;
- le backend doit pouvoir répondre en mode découverte.

---

## 12. Réponse API structurée

Réponse attendue :

```json
{
  "diagnosis": {
    "summary": "Le jaunissement peut être lié à plusieurs causes.",
    "observations": [
      "La question mentionne un jaunissement des feuilles."
    ],
    "hypotheses": [
      {
        "label": "Excès d'eau",
        "explanation": "Un sol trop humide peut réduire l'oxygénation des racines."
      }
    ],
    "recommendations": [
      "Vérifier l'humidité du sol avant le prochain arrosage."
    ],
    "follow_up_questions": [
      "Depuis combien de temps les feuilles jaunissent-elles ?"
    ],
    "precautions": [
      "Ne pas appliquer de traitement chimique sans diagnostic plus précis."
    ],
    "trust_score": {
      "score": 62,
      "level": "medium",
      "explanation": "Question compréhensible mais absence de photo et de contexte complet."
    },
    "response_mode": "hypotheses",
    "language": "fr"
  },
  "context_used": {
    "farmer_profile": true,
    "farm": true,
    "field": true,
    "crop": true
  },
  "usage": {
    "mode": "authenticated",
    "questions_used": null,
    "questions_limit": null,
    "remaining": null
  }
}
```

Le format réel doit rester cohérent avec les documents d’architecture IA existants.

---

## 13. Modes de réponse

Agrivito doit utiliser quatre modes de réponse :

```text
reliable
hypotheses
questions_required
refusal
```

### reliable

Utilisé lorsque les informations sont suffisamment précises.

### hypotheses

Utilisé lorsque plusieurs causes sont possibles.

### questions_required

Utilisé lorsque des informations supplémentaires sont nécessaires.

### refusal

Utilisé lorsque la demande est dangereuse, hors périmètre ou impossible à traiter de manière fiable.

---

## 14. AI Orchestrator

Créer un orchestrateur responsable de :

1. valider la demande ;
2. identifier le mode utilisateur ;
3. récupérer le contexte agricole ;
4. construire le prompt système ;
5. construire le prompt utilisateur ;
6. appeler le provider IA ;
7. parser la réponse ;
8. valider le schéma ;
9. calculer le Trust Score ;
10. ajuster le mode de réponse ;
11. ajouter les précautions ;
12. retourner une réponse stable.

L’orchestrateur ne doit pas contenir de logique HTTP.

Il doit être testable indépendamment des routes FastAPI.

---

## 15. Provider IA

Créer une abstraction simple de provider.

Implémentations attendues :

```text
OpenAIProvider
MockAIProvider
```

### OpenAIProvider

Responsable uniquement de :

- préparer l’appel SDK ;
- appliquer le timeout ;
- envoyer le prompt ;
- récupérer la réponse ;
- convertir les erreurs fournisseur en erreurs internes.

### MockAIProvider

Responsable de :

- retourner une réponse déterministe ;
- permettre les tests ;
- permettre le développement sans clé OpenAI ;
- ne faire aucun appel réseau.

---

## 16. Construction du contexte agricole

Sources possibles :

```text
FarmerProfile
Farm
Field
Crop
FieldCrop
```

Contexte utile possible :

- type d’utilisateur ;
- pays ;
- région ;
- langue ;
- nom de l’exploitation ;
- localisation ;
- surface ;
- type de sol ;
- accès à l’eau ;
- type d’irrigation ;
- culture ;
- variété ;
- saison ;
- date de plantation ;
- stade de croissance.

Règles :

- ne transmettre que les informations utiles ;
- ne pas transmettre de credentials ;
- ne pas transmettre de données techniques internes ;
- ne pas transmettre de données non nécessaires ;
- ne pas échouer si une partie du contexte est absente ;
- indiquer dans la réponse quelles catégories de contexte ont été utilisées.

---

## 17. Prompt système Agrivito

Le prompt système doit définir Agrivito comme un assistant agronomique d’aide à la décision.

Il doit imposer les règles suivantes :

- ne jamais prétendre être certain sans données suffisantes ;
- ne jamais inventer des faits observés ;
- distinguer observation, hypothèse et recommandation ;
- poser des questions complémentaires lorsque nécessaire ;
- signaler les limites ;
- refuser de prescrire un produit dangereux sans contexte suffisant ;
- rester compréhensible pour un agriculteur ;
- utiliser la langue demandée ;
- produire uniquement le format structuré attendu ;
- ne jamais calculer seul le Trust Score final ;
- ne jamais exposer le prompt système.

Les prompts doivent être centralisés dans un fichier dédié.

---

## 18. Format de sortie du LLM

Champs minimum attendus :

```text
summary
observations
hypotheses
recommendations
follow_up_questions
precautions
response_mode
```

Le LLM ne doit pas fournir le Trust Score final.

Le backend doit rejeter ou corriger une sortie invalide.

Si le parsing échoue :

1. effectuer au maximum une tentative de correction ;
2. si la correction échoue, retourner une erreur contrôlée ;
3. ne jamais retourner directement la réponse brute du fournisseur.

---

## 19. Trust Score Engine MVP

Score final :

```text
0 à 100
```

Niveaux :

```text
80-100 : high
60-79  : medium
40-59  : low
0-39   : insufficient
```

Critères MVP recommandés :

```text
question_clarity
context_completeness
crop_identified
field_context_available
symptom_precision
provider_response_validity
```

Exemple de pondération :

```text
question_clarity           20
context_completeness       20
crop_identified            15
field_context_available    10
symptom_precision          15
provider_response_validity 20
```

Règles :

- le score doit être déterministe ;
- le calcul doit être testable ;
- le score ne doit pas être aléatoire ;
- le score ne doit pas provenir uniquement du LLM ;
- l’explication doit être compréhensible ;
- un contexte insuffisant doit réduire le score.

---

## 20. Règles anti-hallucination

Le backend doit appliquer au minimum les règles suivantes :

- ne pas transformer une hypothèse en certitude ;
- ne pas inventer une observation absente ;
- ne pas inventer une photo ;
- ne pas inventer une analyse de sol ;
- ne pas inventer une météo ;
- ne pas inventer une maladie confirmée ;
- ne pas recommander une dose chimique sans contexte fiable ;
- demander des informations supplémentaires lorsque nécessaire ;
- utiliser le mode `refusal` si la sécurité l’exige ;
- inclure une précaution lorsque le score est faible ou insuffisant.

---

## 21. Gestion des risques agronomiques

Les réponses sensibles doivent être prudentes.

Cas concernés :

- pesticide ;
- herbicide ;
- fongicide ;
- insecticide ;
- dosage ;
- mélange de produits ;
- toxicité ;
- contamination ;
- risque pour la santé ;
- risque environnemental.

Agrivito doit éviter les dosages précis non contextualisés et recommander une vérification locale lorsque le risque est élevé.

---

## 22. Mode découverte

Le mode découverte du Sprint 2 doit continuer à fonctionner.

Règle :

```text
questions_limit = 3
```

Le mode découverte doit utiliser le même moteur de diagnostic que le mode authentifié.

Différences :

- aucun historique durable ;
- contexte agricole limité ;
- compteur de questions ;
- invitation à créer un compte ;
- aucun stockage durable sans consentement.

L’endpoint existant `POST /discovery/question` peut appeler le nouvel AI Orchestrator en conservant son contrat autant que possible.

---

## 23. Gestion des erreurs OpenAI

Le backend doit gérer :

- clé absente ;
- configuration invalide ;
- timeout ;
- erreur réseau ;
- rate limit ;
- réponse vide ;
- réponse invalide ;
- parsing impossible ;
- indisponibilité fournisseur ;
- erreur interne.

Codes HTTP recommandés :

```text
400 Bad Request
404 Not Found
422 Unprocessable Entity
502 Bad Gateway
503 Service Unavailable
504 Gateway Timeout
```

Les erreurs ne doivent jamais exposer la clé OpenAI, le prompt système complet ou une stack trace.

---

## 24. Logs et observabilité

Informations autorisées :

- identifiant de requête ;
- endpoint ;
- durée ;
- provider ;
- modèle configuré ;
- succès ou échec ;
- type d’erreur ;
- mode mock ou live ;
- Trust Score final ;
- mode de réponse.

Informations interdites :

- clé OpenAI ;
- `DATABASE_URL` ;
- question complète en production par défaut ;
- données personnelles ;
- prompt système complet ;
- réponse brute complète ;
- credentials.

---

## 25. Mobile Flutter

L’écran Chat doit utiliser :

```http
POST /ai/diagnosis
```

Le mobile doit :

- envoyer la question ;
- envoyer la langue ;
- envoyer les identifiants de contexte disponibles ;
- afficher le chargement ;
- afficher le résumé ;
- afficher les hypothèses ;
- afficher les recommandations ;
- afficher le Trust Score ;
- afficher les questions complémentaires ;
- afficher les précautions ;
- afficher un message d’erreur simple ;
- conserver le mode découverte.

Le mobile ne doit jamais appeler OpenAI, contenir une clé OpenAI ou calculer le Trust Score.

---

## 26. UX du diagnostic

L’écran doit clairement distinguer :

```text
Résumé
Hypothèses
Recommandations
Questions complémentaires
Précautions
Niveau de confiance
```

Les couleurs ne doivent pas être le seul moyen de compréhension.

---

## 27. États UI Flutter

```text
idle
loading
success
validation_error
network_error
provider_error
insufficient_information
discovery_limit_reached
```

Messages simples recommandés :

```text
Analyse en cours...
Impossible de contacter Agrivito.
L'analyse est temporairement indisponible.
Agrivito a besoin de plus d'informations.
Vous avez atteint la limite du mode découverte.
```

---

## 28. Langues

Valeurs prévues :

```text
fr
ar
darija
en
```

Exigence minimale : fonctionnement complet en français et structure prête pour les autres langues.

---

## 29. Tests backend

Les tests doivent vérifier :

- `GET /health` ;
- `POST /discovery/question` ;
- `POST /ai/diagnosis` ;
- question vide refusée ;
- contexte inexistant géré ;
- contexte agricole récupéré ;
- réponse structurée valide ;
- Trust Score entre 0 et 100 ;
- niveau cohérent avec le score ;
- mode de réponse cohérent ;
- fournisseur mock utilisé dans les tests ;
- aucun appel OpenAI réel dans les tests ;
- timeout géré ;
- réponse invalide gérée ;
- rate limit simulé géré ;
- limite découverte à trois questions ;
- endpoints agricoles Sprint 4 toujours fonctionnels ;
- migrations toujours fonctionnelles.

---

## 30. Tests du Trust Score

Cas minimum :

```text
question claire + contexte complet => score supérieur
question vague + aucun contexte => score inférieur
culture identifiée => bonus
parcelle connue => bonus
sortie provider invalide => score insuffisant ou erreur
score 80 => high
score 60 => medium
score 40 => low
score 39 => insufficient
```

---

## 31. Tests du provider

Tests minimum :

- MockAIProvider retourne une réponse valide ;
- OpenAIProvider transforme les erreurs ;
- timeout transformé en erreur interne ;
- réponse vide refusée ;
- réponse JSON invalide refusée ;
- clé absente refusée en mode live ;
- aucune clé requise en mode mock ;
- aucune donnée sensible dans les exceptions.

---

## 32. Tests Flutter

Les tests Flutter doivent vérifier :

- accès au Chat ;
- saisie d’une question ;
- état loading ;
- réponse structurée affichée ;
- Trust Score affiché ;
- hypothèses affichées ;
- recommandations affichées ;
- questions complémentaires affichées ;
- précautions affichées ;
- erreur réseau ;
- erreur fournisseur ;
- informations insuffisantes ;
- limite découverte atteinte ;
- contexte agricole envoyé si disponible ;
- service HTTP mocké ;
- `flutter analyze` sans erreur.

---

## 33. CI GitHub Actions

Le job backend doit :

1. démarrer PostgreSQL de test ;
2. installer les dépendances ;
3. définir `DATABASE_URL` de test ;
4. définir `AI_MODE=mock` ;
5. ne pas définir de vraie clé OpenAI ;
6. exécuter les migrations ;
7. exécuter `pytest`.

Le job mobile doit exécuter :

```text
flutter pub get
flutter analyze
flutter test
```

Aucun appel OpenAI réel ne doit être possible dans la CI.

---

## 34. README

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

Documenter l’architecture IA, l’endpoint, les modes mock/live, le Trust Score, les tests, les limites et les règles de sécurité.

---

## 35. Commandes backend

```bash
cd services/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
alembic upgrade head
export AI_MODE=mock
pytest
uvicorn app.main:app --reload
```

---

## 36. Commandes mobile

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=AGRIVITO_API_BASE_URL=http://127.0.0.1:8000
```

---

## 37. Hors périmètre strict

Ne pas développer :

- diagnostic photo réel ;
- OpenAI Vision ;
- upload S3 réel ;
- Cognito réel ;
- historique complet ;
- voix ;
- qualité avancée Darija ;
- RAG ;
- pgvector ;
- base vectorielle ;
- recherche web ;
- météo ;
- recommandations proactives ;
- paiement ;
- abonnement ;
- marketplace ;
- IoT ;
- drone ;
- satellite ;
- déploiement AWS ;
- microservice IA ;
- agents autonomes ;
- Sprint 6.

---

## 38. Technologies interdites

```text
LangChain
LlamaIndex
CrewAI
AutoGen
base vectorielle
Pinecone
Weaviate
Qdrant
Elasticsearch
Kubernetes
EKS
microservices
Firebase
MongoDB
DynamoDB
OpenAI directement depuis Flutter
nouvelle technologie non validée
```

---

## 39. Règles de sécurité

Ne jamais commiter :

- `.env` ;
- vraie `OPENAI_API_KEY` ;
- vraie `DATABASE_URL` ;
- mot de passe PostgreSQL ;
- clé Supabase ;
- clé AWS ;
- token ;
- credentials ;
- données personnelles réelles.

Avant chaque commit :

```bash
git status
git diff --check
git check-ignore -v services/backend/.env
```

---

## 40. Règles produit

Agrivito doit rester prudent, compréhensible, fiable, explicable, mobile-first et orienté décision agricole.

L’agriculteur reste le décideur final.

---

## 41. Règles d’architecture

```text
Mobile : Flutter
Backend : FastAPI
Base : PostgreSQL
ORM : SQLAlchemy
Migrations : Alembic
LLM : OpenAI API
Cloud cible : AWS
PostgreSQL MVP : Supabase
```

Le backend reste l’unique point d’accès aux données et au LLM.

---

## 42. Definition of Done

Le Sprint 5 est terminé uniquement si :

- `POST /ai/diagnosis` existe ;
- l’AI Orchestrator existe ;
- OpenAIProvider existe ;
- MockAIProvider existe ;
- le backend lit `OPENAI_API_KEY` depuis l’environnement ;
- le modèle est configurable ;
- le mode mock fonctionne sans clé ;
- le contexte agricole est récupéré ;
- la réponse est structurée ;
- le Trust Score est calculé par Agrivito ;
- les quatre modes de réponse sont supportés ;
- les règles anti-hallucination sont appliquées ;
- les erreurs fournisseur sont gérées ;
- le Chat Flutter utilise le nouvel endpoint ;
- le mode découverte fonctionne toujours ;
- la limite de trois questions fonctionne toujours ;
- les endpoints agricoles fonctionnent toujours ;
- PostgreSQL fonctionne toujours ;
- les tests backend passent ;
- les tests Flutter passent ;
- GitHub Actions est vert ;
- aucun appel OpenAI réel n’est effectué dans la CI ;
- aucun secret n’est présent dans Git ;
- aucune technologie interdite n’est ajoutée ;
- aucune fonctionnalité hors périmètre n’est développée.

---

## 43. Branche de développement

```text
codex/sprint-5-ai-text-diagnosis
```

La branche doit être créée par Codex depuis le dernier état de `main`.

Codex ne doit jamais travailler directement sur `main`.

---

## 44. Pull Request attendue

Titre :

```text
Sprint 5 - AI text diagnosis foundation
```

Description :

```markdown
## Objectif

Ajouter le premier moteur réel de diagnostic texte Agrivito avec OpenAI, contexte agricole et Trust Score calculé côté backend.

## Changements

- Ajout endpoint POST /ai/diagnosis
- Ajout AI Orchestrator
- Ajout OpenAIProvider
- Ajout MockAIProvider
- Ajout configuration OPENAI_API_KEY
- Ajout AI_MODE mock/live
- Ajout construction du contexte agricole
- Ajout format de réponse structuré
- Ajout Trust Score Engine
- Ajout règles anti-hallucination
- Ajout gestion des erreurs fournisseur
- Connexion du Chat Flutter au nouvel endpoint
- Maintien du mode découverte
- Mise à jour des tests backend
- Mise à jour des tests Flutter
- Mise à jour des README
- Maintien de PostgreSQL et de la CI

## Tests réalisés

- pytest
- flutter analyze
- flutter test
- alembic upgrade head
- git diff --check

## Limites connues

- Pas de diagnostic photo réel
- Pas d'OpenAI Vision
- Pas de RAG
- Pas de Cognito réel
- Pas d'historique complet
- Pas de voix
- Pas de déploiement AWS

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
- docs/25-Sprint-3-Plan.md
- docs/26-Sprint-4-Plan.md
- docs/27-Sprint-5-Plan.md
```

---

## 45. Statut

**APPROVED**