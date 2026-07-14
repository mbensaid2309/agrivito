# PROMPT CODEX - SPRINT 5

Tu es Lead Developer sur le projet Agrivito.

Agrivito est une plateforme intelligente d’assistance à la décision agricole.

Ton rôle est de développer le Sprint 5 du MVP en respectant strictement les documents validés dans le dossier `docs/`.

Tu ne dois pas prendre de décision d’architecture.

---

# Étape obligatoire avant de coder

Avant de modifier ou créer du code, lis intégralement les documents suivants :

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
docs/25-Sprint-3-Plan.md
docs/26-Sprint-4-Plan.md
docs/27-Sprint-5-Plan.md
```

Ces documents sont la source de vérité.

Important :

```text
AgriAI = ancien nom de travail
Agrivito = nom officiel du produit
```

Toutes les nouvelles implémentations doivent utiliser **Agrivito** ou `agrivito`.

---

# Branche cible

Travaille sur la branche :

```text
codex/sprint-5-ai-text-diagnosis
```

Si la branche n’existe pas, crée-la depuis le dernier état de `main`.

Commandes attendues :

```bash
git checkout main
git pull origin main
git checkout -b codex/sprint-5-ai-text-diagnosis
```

Ne travaille jamais directement sur `main`.

Ne merge jamais toi-même la Pull Request.

---

# Objectif du Sprint 5

Développer la première capacité réelle de diagnostic texte Agrivito.

Nom du sprint :

```text
Sprint 5 - AI Text Diagnosis Foundation
```

À la fin du Sprint 5, Agrivito doit permettre :

- de poser une question agricole depuis Flutter ;
- d’envoyer cette question au backend FastAPI ;
- de construire un contexte agricole depuis PostgreSQL ;
- d’appeler OpenAI uniquement depuis le backend ;
- de produire une réponse structurée ;
- de calculer un Trust Score côté Agrivito ;
- de distinguer observation, hypothèse et recommandation ;
- de demander des informations complémentaires si nécessaire ;
- de refuser de conclure lorsque la fiabilité est insuffisante ;
- de maintenir le mode découverte ;
- de maintenir la limite de trois questions ;
- de conserver toutes les fonctionnalités des Sprints 1 à 4 ;
- de garder la CI entièrement verte.

---

# Architecture obligatoire

Architecture Sprint 5 :

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
- le backend valide la sortie du LLM ;
- le backend doit fonctionner en mode mock ;
- aucun appel OpenAI réel ne doit être effectué dans la CI.

---

# Périmètre autorisé Sprint 5

Tu peux développer uniquement :

1. endpoint `POST /ai/diagnosis` ;
2. AI Orchestrator ;
3. abstraction de provider IA ;
4. OpenAIProvider ;
5. MockAIProvider ;
6. configuration `OPENAI_API_KEY` ;
7. configuration `OPENAI_MODEL` ;
8. configuration `OPENAI_TIMEOUT_SECONDS` ;
9. configuration `AI_PROVIDER` ;
10. configuration `AI_MODE` ;
11. construction du contexte agricole ;
12. récupération optionnelle du profil ;
13. récupération optionnelle de l’exploitation ;
14. récupération optionnelle de la parcelle ;
15. récupération optionnelle de la culture ;
16. format de réponse structuré ;
17. parsing et validation de sortie IA ;
18. Trust Score Engine MVP ;
19. règles anti-hallucination ;
20. règles de prudence agronomique ;
21. gestion des erreurs fournisseur ;
22. gestion des timeouts ;
23. connexion du Chat Flutter ;
24. maintien du mode découverte ;
25. maintien de la limite de trois questions ;
26. tests backend avec provider mocké ;
27. tests Flutter avec API mockée ;
28. mise à jour README ;
29. maintien de PostgreSQL ;
30. maintien de la CI verte.

---

# Hors périmètre strict

Ne pas développer :

- diagnostic photo réel ;
- OpenAI Vision ;
- upload S3 réel ;
- capture photo complète ;
- Cognito réel ;
- Supabase Auth ;
- Supabase Storage ;
- historique complet des conversations ;
- historique complet des diagnostics ;
- voix ;
- synthèse vocale ;
- reconnaissance vocale ;
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
- fournisseurs ;
- IoT ;
- drone ;
- satellite ;
- déploiement AWS ;
- App Runner ;
- AWS RDS ;
- microservice IA ;
- agents autonomes ;
- Sprint 6.

Ne pas introduire :

- LangChain ;
- LlamaIndex ;
- CrewAI ;
- AutoGen ;
- Pinecone ;
- Weaviate ;
- Qdrant ;
- Elasticsearch ;
- Kubernetes ;
- EKS ;
- microservices ;
- Firebase ;
- MongoDB ;
- DynamoDB ;
- nouvelle technologie non validée.

---

# Travail demandé

## 1. Vérifier la base existante

Avant de coder, vérifier que les éléments des Sprints précédents existent toujours :

```text
services/backend/
apps/mobile/
.github/workflows/
README.md
```

Vérifier que les endpoints existants restent disponibles :

```http
GET /health
POST /discovery/question

GET /farmer/profile
POST /farmer/profile

GET /farms
POST /farms
GET /farms/{farm_id}

GET /farms/{farm_id}/fields
POST /farms/{farm_id}/fields
GET /fields/{field_id}

GET /crops
POST /crops
GET /crops/{crop_id}

POST /fields/{field_id}/crop
GET /fields/{field_id}/crop
```

Ne casse pas les Sprints 1, 2, 3 ou 4.

---

## 2. Ajouter la configuration IA

Mettre à jour la configuration backend pour supporter :

```env
OPENAI_API_KEY=
OPENAI_MODEL=
OPENAI_TIMEOUT_SECONDS=30
AI_PROVIDER=openai
AI_MODE=mock
```

Règles :

- `AI_MODE=mock` doit fonctionner sans clé OpenAI ;
- `AI_MODE=live` doit exiger `OPENAI_API_KEY` ;
- `OPENAI_MODEL` doit être configurable ;
- le timeout doit être configurable ;
- aucune valeur sensible ne doit être codée en dur ;
- aucune clé ne doit être loggée.

Mettre à jour :

```text
services/backend/.env.example
```

Avec uniquement des valeurs fictives.

Exemple :

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

Ne modifie pas la vraie valeur de :

```text
services/backend/.env
```

Ne l’affiche pas.

Ne la committe pas.

---

## 3. Ajouter la dépendance OpenAI

Mettre à jour :

```text
services/backend/requirements.txt
```

Ajouter uniquement :

```text
openai
```

Utiliser une version compatible avec la version Python déjà utilisée.

Ne pas ajouter de framework IA supplémentaire.

---

## 4. Créer la structure IA backend

Structure recommandée :

```text
services/backend/app/ai/
├── __init__.py
├── orchestrator.py
├── provider.py
├── openai_provider.py
├── mock_provider.py
├── prompts.py
├── response_parser.py
├── trust_score.py
└── exceptions.py
```

Une structure légèrement différente est acceptable si elle reste simple et lisible.

Ne pas créer de microservice séparé.

---

## 5. Créer l’abstraction AIProvider

Créer une abstraction simple permettant de séparer le backend du fournisseur OpenAI.

Interface conceptuelle :

```python
class AIProvider:
    def generate_diagnosis(self, request):
        ...
```

Créer deux implémentations :

```text
OpenAIProvider
MockAIProvider
```

L’orchestrateur doit dépendre de l’abstraction, pas directement du SDK OpenAI.

---

## 6. Créer MockAIProvider

Le MockAIProvider doit :

- ne faire aucun appel réseau ;
- retourner une réponse déterministe ;
- respecter le format attendu ;
- fonctionner sans `OPENAI_API_KEY` ;
- être utilisé dans les tests ;
- être utilisable localement avec `AI_MODE=mock`.

La réponse mockée doit contenir :

```text
summary
observations
hypotheses
recommendations
follow_up_questions
precautions
response_mode
```

---

## 7. Créer OpenAIProvider

Le OpenAIProvider doit :

- utiliser le SDK OpenAI ;
- lire le modèle depuis la configuration ;
- lire le timeout depuis la configuration ;
- envoyer le prompt système ;
- envoyer le prompt utilisateur ;
- demander une sortie structurée ;
- récupérer la réponse ;
- ne jamais exposer la réponse brute directement à l’API ;
- convertir les erreurs fournisseur en erreurs internes ;
- ne jamais logger la clé OpenAI ;
- ne jamais logger le prompt système complet.

Gérer au minimum :

- timeout ;
- erreur réseau ;
- rate limit ;
- réponse vide ;
- réponse invalide ;
- indisponibilité fournisseur ;
- configuration manquante.

---

## 8. Créer les schémas de diagnostic

Créer les schémas dans :

```text
services/backend/app/schemas/ai_diagnosis.py
```

Schémas recommandés :

```text
AIDiagnosisRequest
AIDiagnosisResponse
DiagnosisContent
DiagnosisObservation
DiagnosisHypothesis
DiagnosisContextUsed
DiagnosisUsage
TrustScoreResponse
```

Réutiliser les schémas existants si cela est cohérent.

Le schéma de requête doit accepter au minimum :

```text
question
language
user_id
farm_id
field_id
crop_id
discovery_session_id
```

Les identifiants de contexte doivent rester optionnels.

---

## 9. Créer l’endpoint de diagnostic

Créer :

```http
POST /ai/diagnosis
```

Emplacement recommandé :

```text
services/backend/app/api/ai_diagnosis.py
```

Exemple de requête :

```json
{
  "question": "Pourquoi les feuilles de mes tomates jaunissent ?",
  "language": "fr",
  "user_id": "demo-user",
  "farm_id": null,
  "field_id": null,
  "crop_id": null,
  "discovery_session_id": null
}
```

Règles :

- `question` obligatoire ;
- question non vide ;
- langue avec valeur par défaut ;
- contexte optionnel ;
- ressources vérifiées si identifiants fournis ;
- aucune obligation d’avoir une exploitation ;
- réponse possible en mode découverte ;
- aucune logique OpenAI directe dans la route.

---

## 10. Format de réponse API

La réponse doit contenir au minimum :

```text
diagnosis
context_used
usage
```

Le bloc `diagnosis` doit contenir :

```text
summary
observations
hypotheses
recommendations
follow_up_questions
precautions
trust_score
response_mode
language
```

Exemple :

```json
{
  "diagnosis": {
    "summary": "Le jaunissement peut avoir plusieurs causes.",
    "observations": [
      "La question mentionne un jaunissement des feuilles."
    ],
    "hypotheses": [
      {
        "label": "Excès d'eau",
        "explanation": "Un sol trop humide peut affecter les racines."
      }
    ],
    "recommendations": [
      "Vérifier l'humidité du sol avant le prochain arrosage."
    ],
    "follow_up_questions": [
      "Depuis combien de temps les feuilles jaunissent-elles ?"
    ],
    "precautions": [
      "Ne pas appliquer de traitement sans diagnostic plus précis."
    ],
    "trust_score": {
      "score": 62,
      "level": "medium",
      "explanation": "Question claire mais contexte incomplet."
    },
    "response_mode": "hypotheses",
    "language": "fr"
  },
  "context_used": {
    "farmer_profile": true,
    "farm": false,
    "field": false,
    "crop": false
  },
  "usage": {
    "mode": "authenticated",
    "questions_used": null,
    "questions_limit": null,
    "remaining": null
  }
}
```

Conserver un contrat stable et typé.

---

## 11. Créer l’AI Orchestrator

Créer un orchestrateur responsable de :

1. valider la demande ;
2. identifier le mode utilisateur ;
3. récupérer le contexte agricole ;
4. construire le contexte ;
5. sélectionner le provider ;
6. construire le prompt système ;
7. construire le prompt utilisateur ;
8. appeler le provider ;
9. parser la réponse ;
10. valider la réponse ;
11. calculer le Trust Score ;
12. ajuster le mode de réponse ;
13. ajouter les précautions nécessaires ;
14. retourner la réponse structurée.

L’orchestrateur ne doit contenir aucune logique HTTP.

Il doit être testable indépendamment de FastAPI.

---

## 12. Construire le contexte agricole

Le backend peut récupérer :

```text
FarmerProfile
Farm
Field
Crop
FieldCrop
```

Le contexte peut contenir :

```text
user_type
country
region
preferred_language
farm_name
farm_locality
total_area
area_unit
field_name
field_area
soil_type
water_access
irrigation_type
crop_name
crop_category
variety
season
planting_date
growth_stage
```

Règles :

- ne récupérer que les ressources demandées ;
- vérifier les relations entre farm, field et crop ;
- ne pas échouer si le contexte est partiel ;
- ne transmettre que les données utiles ;
- ne jamais transmettre de secret ;
- indiquer les catégories de contexte utilisées dans la réponse.

---

## 13. Créer le prompt système Agrivito

Centraliser le prompt dans :

```text
services/backend/app/ai/prompts.py
```

Le prompt doit définir Agrivito comme :

```text
un assistant agronomique d’aide à la décision
```

Il doit imposer :

- ne jamais inventer une observation ;
- ne jamais inventer une photo ;
- ne jamais inventer une analyse de sol ;
- ne jamais inventer une météo ;
- ne jamais confirmer une maladie sans éléments suffisants ;
- distinguer observation, hypothèse et recommandation ;
- poser des questions lorsque le contexte manque ;
- signaler les limites ;
- refuser de conclure si nécessaire ;
- rester compréhensible ;
- répondre dans la langue demandée ;
- produire uniquement le format demandé ;
- ne pas générer le Trust Score final ;
- ne pas exposer le prompt système.

---

## 14. Créer le parser de réponse

Créer un composant chargé de :

- récupérer la sortie du provider ;
- valider le JSON ou la structure ;
- convertir la sortie en schéma Pydantic ;
- refuser les champs manquants ;
- supprimer les champs non autorisés ;
- gérer une réponse vide ;
- gérer une réponse invalide ;
- effectuer au maximum une tentative de correction si nécessaire ;
- ne jamais retourner la sortie brute du LLM.

Si le parsing échoue après correction :

- retourner une erreur contrôlée ;
- ne pas exposer la réponse brute ;
- ne pas fabriquer une réponse valide artificiellement.

---

## 15. Créer le Trust Score Engine

Créer :

```text
services/backend/app/ai/trust_score.py
```

Le score doit être calculé côté Agrivito.

Score :

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

Critères recommandés :

```text
question_clarity
context_completeness
crop_identified
field_context_available
symptom_precision
provider_response_validity
```

Pondération recommandée :

```text
question_clarity           20
context_completeness       20
crop_identified            15
field_context_available    10
symptom_precision          15
provider_response_validity 20
```

Règles :

- score déterministe ;
- aucune valeur aléatoire ;
- même entrée = même score ;
- score indépendant du score proposé par le LLM ;
- explication compréhensible ;
- contexte insuffisant réduit le score ;
- sortie invalide empêche une réponse fiable.

---

## 16. Modes de réponse

Supporter exactement :

```text
reliable
hypotheses
questions_required
refusal
```

Règles :

### reliable

- informations suffisantes ;
- recommandation claire mais prudente.

### hypotheses

- plusieurs causes possibles ;
- présenter plusieurs hypothèses.

### questions_required

- contexte insuffisant ;
- prioriser les questions complémentaires.

### refusal

- demande dangereuse ;
- demande hors périmètre ;
- risque élevé ;
- impossibilité de répondre de manière fiable.

Le backend doit pouvoir ajuster le mode proposé par le LLM.

---

## 17. Appliquer les règles anti-hallucination

Appliquer au minimum :

- aucune observation inventée ;
- aucune photo inventée ;
- aucune analyse de sol inventée ;
- aucune météo inventée ;
- aucune maladie confirmée sans preuves ;
- aucune certitude si plusieurs hypothèses existent ;
- aucune dose chimique sans contexte fiable ;
- aucune recommandation dangereuse ;
- questions complémentaires si nécessaire ;
- précaution obligatoire si score faible ;
- refus si sécurité insuffisante.

---

## 18. Gérer les demandes sensibles

Cas sensibles :

```text
pesticide
herbicide
fongicide
insecticide
dosage
mélange de produits
toxicité
contamination
risque santé
risque environnemental
```

Dans ces cas :

- éviter les dosages précis non contextualisés ;
- demander le produit exact si nécessaire ;
- demander la région ou le pays si nécessaire ;
- rappeler de vérifier l’étiquette officielle ;
- recommander un expert local lorsque nécessaire ;
- ne jamais encourager un usage non autorisé.

---

## 19. Maintenir le mode découverte

L’endpoint existant doit rester disponible :

```http
POST /discovery/question
```

Il peut utiliser le nouvel AI Orchestrator.

Règle :

```text
questions_limit = 3
```

Le mode découverte doit :

- utiliser le même moteur de diagnostic ;
- conserver son compteur ;
- ne pas sauvegarder durablement ;
- fonctionner sans compte ;
- inviter à créer un compte après la limite ;
- conserver autant que possible son contrat existant.

Ne supprime pas brutalement l’endpoint Sprint 2.

---

## 20. Gestion des erreurs

Gérer :

- `OPENAI_API_KEY` absente en mode live ;
- modèle absent ;
- timeout ;
- erreur réseau ;
- rate limit ;
- réponse vide ;
- réponse invalide ;
- parsing impossible ;
- provider indisponible ;
- contexte inexistant ;
- erreur interne.

Codes recommandés :

```text
400 Bad Request
404 Not Found
422 Unprocessable Entity
502 Bad Gateway
503 Service Unavailable
504 Gateway Timeout
```

Ne jamais exposer :

- clé OpenAI ;
- prompt système complet ;
- réponse brute sensible ;
- stack trace ;
- configuration interne ;
- credentials.

---

## 21. Logs

Ajouter des logs minimaux.

Autorisé :

```text
request_id
endpoint
provider
model
duration
success
failure
error_type
ai_mode
trust_score
response_mode
```

Interdit :

```text
OPENAI_API_KEY
DATABASE_URL
question complète en production par défaut
données personnelles
prompt système complet
réponse brute complète
credentials
```

---

## 22. Connecter Flutter au nouvel endpoint

Modifier le Chat Flutter pour appeler :

```http
POST /ai/diagnosis
```

Le mobile doit envoyer :

```text
question
language
user_id si disponible
farm_id si disponible
field_id si disponible
crop_id si disponible
discovery_session_id si nécessaire
```

Le mobile doit afficher :

```text
summary
observations
hypotheses
recommendations
follow_up_questions
precautions
trust_score
response_mode
```

Le mobile ne doit jamais :

- appeler OpenAI ;
- contenir une clé OpenAI ;
- calculer le Trust Score ;
- contenir le prompt système ;
- traiter une réponse brute du LLM.

---

## 23. UX Flutter

L’écran doit distinguer clairement :

```text
Résumé
Observations
Hypothèses
Recommandations
Questions complémentaires
Précautions
Niveau de confiance
```

Niveaux à afficher :

```text
Confiance élevée
Confiance moyenne
Confiance faible
Informations insuffisantes
```

Les couleurs ne doivent pas être le seul indicateur.

Ajouter une explication textuelle.

---

## 24. États Flutter

Gérer :

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

Messages simples :

```text
Analyse en cours...
Impossible de contacter Agrivito.
L'analyse est temporairement indisponible.
Agrivito a besoin de plus d'informations.
Vous avez atteint la limite du mode découverte.
```

Ne jamais afficher une erreur OpenAI brute.

---

## 25. Langues

Prévoir :

```text
fr
ar
darija
en
```

Exigence minimale :

- fonctionnement complet en français ;
- structure prête pour les autres langues ;
- langue envoyée au backend ;
- langue transmise au provider ;
- langue retournée dans la réponse ;
- aucun mélange involontaire.

La voix et la qualité avancée Darija restent hors périmètre.

---

## 26. Tests backend

Ajouter ou mettre à jour les tests dans :

```text
services/backend/tests/
```

Tests minimum :

```text
GET /health toujours OK
POST /discovery/question toujours OK
POST /ai/diagnosis OK
question vide refusée
question sans contexte acceptée
profil récupéré si disponible
farm récupérée si disponible
field récupérée si disponible
crop récupérée si disponible
ressource inexistante gérée
réponse structurée valide
Trust Score entre 0 et 100
niveau cohérent avec score
mode de réponse valide
question vague => questions_required ou hypotheses
contexte complet => score supérieur
provider mock utilisé
aucun appel OpenAI réel
timeout provider géré
rate limit simulé géré
réponse vide gérée
réponse invalide gérée
clé absente en mode live gérée
mode mock sans clé fonctionne
limite découverte = 3
endpoints Sprint 4 toujours fonctionnels
migrations toujours fonctionnelles
```

Tous les tests doivent fonctionner sans vraie clé OpenAI.

---

## 27. Tests Trust Score

Créer des tests spécifiques :

```text
question claire + contexte complet => score supérieur
question vague + aucun contexte => score inférieur
culture identifiée => bonus
parcelle connue => bonus
sortie provider invalide => erreur ou insufficient
score 80 => high
score 60 => medium
score 40 => low
score 39 => insufficient
même entrée => même score
```

---

## 28. Tests provider

Tests minimum :

```text
MockAIProvider retourne une réponse valide
MockAIProvider ne fait aucun appel réseau
OpenAIProvider transforme les erreurs
timeout transformé en erreur interne
rate limit transformé en erreur interne
réponse vide refusée
réponse JSON invalide refusée
clé absente refusée en mode live
clé non requise en mode mock
aucun secret dans les exceptions
```

---

## 29. Tests Flutter

Ajouter ou mettre à jour les tests dans :

```text
apps/mobile/test/
```

Tests minimum :

```text
application démarre
navigation vers Chat
saisie d'une question
état loading
résumé affiché
observations affichées
hypothèses affichées
recommandations affichées
questions complémentaires affichées
précautions affichées
Trust Score affiché
erreur réseau
erreur fournisseur
informations insuffisantes
limite découverte atteinte
contexte envoyé si disponible
service HTTP mocké
flutter analyze sans erreur
```

---

## 30. CI GitHub Actions

La CI doit garder au minimum :

```text
Backend tests
Mobile checks
```

Le job backend doit :

1. démarrer PostgreSQL ;
2. installer Python ;
3. installer les dépendances ;
4. définir `DATABASE_URL` de test ;
5. définir `AI_MODE=mock` ;
6. ne définir aucune vraie clé OpenAI ;
7. exécuter `alembic upgrade head` ;
8. exécuter `pytest`.

Le job mobile doit :

1. installer Flutter ;
2. exécuter `flutter pub get` ;
3. exécuter `flutter analyze` ;
4. exécuter `flutter test`.

Aucun appel OpenAI réel ne doit être possible dans la CI.

---

## 31. Documentation

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

Documenter :

- objectif Sprint 5 ;
- architecture IA ;
- endpoint `POST /ai/diagnosis` ;
- OpenAIProvider ;
- MockAIProvider ;
- `AI_MODE=mock` ;
- `AI_MODE=live` ;
- variables d’environnement ;
- Trust Score ;
- règles anti-hallucination ;
- lancement backend ;
- lancement mobile ;
- tests ;
- limites connues ;
- sécurité.

---

## 32. Commandes de validation backend

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

Vérifications :

```text
http://127.0.0.1:8000/health
http://127.0.0.1:8000/docs
```

---

## 33. Commandes de validation mobile

```bash
cd apps/mobile

flutter pub get
flutter analyze
flutter test

flutter run \
  --dart-define=AGRIVITO_API_BASE_URL=http://127.0.0.1:8000
```

Android Emulator :

```bash
flutter run \
  --dart-define=AGRIVITO_API_BASE_URL=http://10.0.2.2:8000
```

---

# Contraintes de sécurité

Ne jamais commiter :

- `.env` ;
- vraie `OPENAI_API_KEY` ;
- vraie `DATABASE_URL` ;
- mot de passe PostgreSQL ;
- clé Supabase ;
- clé AWS ;
- token ;
- credentials ;
- données personnelles réelles ;
- prompts contenant des secrets.

Avant chaque commit :

```bash
git status
git diff --check
git check-ignore -v services/backend/.env
```

---

# Contraintes de qualité

Le code doit être :

- simple ;
- lisible ;
- typé ;
- maintenable ;
- testable ;
- cohérent avec les Sprints précédents ;
- cohérent avec les documents approuvés.

Ne pas sur-concevoir.

Ne pas créer de framework interne complexe.

Ne pas ajouter de fonctionnalité hors périmètre.

Ne pas modifier l’architecture validée.

---

# Definition of Done

Le Sprint 5 est terminé uniquement si :

- la branche `codex/sprint-5-ai-text-diagnosis` existe ;
- `POST /ai/diagnosis` existe ;
- AI Orchestrator existe ;
- AIProvider existe ;
- OpenAIProvider existe ;
- MockAIProvider existe ;
- `OPENAI_API_KEY` est lue depuis l’environnement ;
- `OPENAI_MODEL` est configurable ;
- `OPENAI_TIMEOUT_SECONDS` est configurable ;
- `AI_MODE=mock` fonctionne sans clé ;
- `AI_MODE=live` supporte OpenAI ;
- le contexte agricole est récupéré ;
- le contexte est injecté dans le diagnostic ;
- la sortie fournisseur est validée ;
- le Trust Score est calculé par Agrivito ;
- les quatre modes de réponse sont supportés ;
- les règles anti-hallucination sont appliquées ;
- les erreurs fournisseur sont gérées ;
- le Chat Flutter utilise le nouvel endpoint ;
- le mode découverte fonctionne toujours ;
- la limite de trois questions fonctionne toujours ;
- les endpoints agricoles fonctionnent toujours ;
- PostgreSQL fonctionne toujours ;
- les migrations fonctionnent toujours ;
- les tests backend passent ;
- les tests Flutter passent ;
- GitHub Actions est vert ;
- aucun appel OpenAI réel n’est effectué dans la CI ;
- aucun secret n’est présent dans Git ;
- aucune technologie interdite n’est ajoutée ;
- aucune fonctionnalité hors périmètre n’est développée.

---

# Pull Request attendue

Créer une Pull Request depuis :

```text
codex/sprint-5-ai-text-diagnosis
```

vers :

```text
main
```

Titre :

```text
Sprint 5 - AI text diagnosis foundation
```

Description attendue :

```markdown
## Objectif

Ajouter le premier moteur réel de diagnostic texte Agrivito avec OpenAI, contexte agricole et Trust Score calculé côté backend.

## Changements

- Ajout endpoint POST /ai/diagnosis
- Ajout AI Orchestrator
- Ajout AIProvider
- Ajout OpenAIProvider
- Ajout MockAIProvider
- Ajout configuration OPENAI_API_KEY
- Ajout configuration OPENAI_MODEL
- Ajout AI_MODE mock/live
- Ajout construction du contexte agricole
- Ajout format de réponse structuré
- Ajout parser et validation de sortie
- Ajout Trust Score Engine
- Ajout règles anti-hallucination
- Ajout gestion des erreurs fournisseur
- Connexion du Chat Flutter au nouvel endpoint
- Maintien du mode découverte
- Maintien de PostgreSQL
- Mise à jour des tests backend
- Mise à jour des tests Flutter
- Mise à jour des README

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

# Rapport final attendu

À la fin, fournir :

```text
branche utilisée
fichiers créés
fichiers modifiés
provider utilisé
endpoint créé
tests backend exécutés
tests Flutter exécutés
résultat des migrations
résultat GitHub Actions
limites connues
URL de la Pull Request
```

Ne merge pas la Pull Request.

Attends la validation CTO.