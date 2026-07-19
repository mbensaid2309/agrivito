# PROMPT CODEX - SPRINT 7

Tu es Lead Developer sur le projet Agrivito.

Agrivito est une plateforme intelligente d’assistance à la décision agricole.

Ton rôle est de développer le Sprint 7 du MVP en respectant strictement les documents validés dans le dossier `docs/`.

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
docs/27-Sprint-5-Plan.md
docs/28-Sprint-6-Plan.md
docs/29-Sprint-7-Plan.md
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
codex/sprint-7-photo-diagnosis-foundation
```

Aucun autre nom de branche n’est autorisé.

Avant toute modification :

```bash
git checkout main
git pull origin main
git checkout -b codex/sprint-7-photo-diagnosis-foundation
```

Tu ne dois jamais travailler directement sur `main`.

Tu ne dois jamais merger toi-même la Pull Request.

---

# Nom du Sprint

```text
Sprint 7 - Photo Diagnosis Foundation
```

---

# Objectif

Ajouter le premier diagnostic photo réel Agrivito.

À la fin du Sprint 7, l’utilisateur doit pouvoir :

- sélectionner un média déjà uploadé ;
- ajouter une question ;
- lancer une analyse visuelle ;
- recevoir une évaluation de la qualité de la photo ;
- recevoir des observations visuelles ;
- recevoir plusieurs hypothèses prudentes ;
- recevoir des recommandations simples ;
- recevoir des questions complémentaires ;
- recevoir des précautions ;
- recevoir un Trust Score visuel ;
- être invité à reprendre la photo si nécessaire ;
- consulter le résultat depuis Flutter.

Le diagnostic doit utiliser OpenAI Vision uniquement depuis FastAPI.

---

# Architecture obligatoire

```text
Application Flutter
        |
        | HTTP / JSON
        v
Backend FastAPI
        |
        v
Photo Diagnosis Orchestrator
        |
        +------------------------------+
        |                              |
        v                              v
Media Service                    Agricultural Context
        |                              |
        v                              v
MediaStorageProvider             PostgreSQL
        |
        v
Image bytes
        |
        v
VisionProvider
        |
        +--> OpenAIVisionProvider
        |
        +--> MockVisionProvider
        |
        v
Photo Quality Engine
        |
        v
Trust Score Engine
        |
        v
Structured Diagnosis
        |
        v
PostgreSQL
```

Règles obligatoires :

- Flutter ne communique jamais directement avec OpenAI ;
- Flutter ne lit jamais directement S3 ;
- FastAPI reste l’unique point d’accès ;
- les images sont lues via `MediaStorageProvider` ;
- le contexte agricole est récupéré côté backend ;
- le Trust Score est calculé côté Agrivito ;
- le LLM ne décide pas seul du score ;
- la sortie du provider est validée ;
- aucun appel OpenAI réel ne doit être effectué dans la CI ;
- le mode mock doit permettre tous les tests.

---

# Périmètre autorisé

Tu peux développer uniquement :

1. endpoint `POST /ai/photo-diagnosis` ;
2. `PhotoDiagnosisOrchestrator` ;
3. abstraction `VisionProvider` ;
4. `OpenAIVisionProvider` ;
5. `MockVisionProvider` ;
6. lecture sécurisée du média ;
7. validation du média ;
8. vérification du statut du média ;
9. vérification du MIME ;
10. `PhotoQualityEngine` ;
11. contexte agricole ;
12. prompt Vision Agrivito ;
13. parser de sortie Vision ;
14. format de réponse structuré ;
15. observations visuelles ;
16. hypothèses prudentes ;
17. recommandations ;
18. questions complémentaires ;
19. précautions ;
20. demande de reprise de photo ;
21. Trust Score visuel ;
22. table `diagnoses` ;
23. migration Alembic ;
24. modèle SQLAlchemy ;
25. schémas Pydantic ;
26. persistance du diagnostic ;
27. association diagnostic / média ;
28. affichage Flutter ;
29. gestion des états UI ;
30. mode découverte limité ;
31. tests backend ;
32. tests Flutter ;
33. CI en mode mock ;
34. mise à jour des README ;
35. maintien des Sprints 1 à 6.

---

# Hors périmètre strict

Ne pas développer :

- diagnostic garanti ;
- classification certaine ;
- diagnostic vétérinaire ;
- comparaison multi-images ;
- vidéo ;
- segmentation d’image ;
- détection d’objet spécialisée ;
- OCR ;
- modèle IA entraîné en interne ;
- fine-tuning ;
- RAG ;
- pgvector ;
- historique avancé ;
- workflow asynchrone ;
- file d’attente ;
- Lambda ;
- Step Functions ;
- notification ;
- météo ;
- marketplace ;
- Cognito réel ;
- déploiement AWS ;
- Sprint 8.

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
- Firebase ;
- MongoDB ;
- DynamoDB ;
- microservice IA séparé ;
- nouvelle technologie non validée.

---

# Travail demandé

## 1. Vérifier le socle existant

Vérifier que les éléments des Sprints précédents existent :

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
POST /ai/diagnosis

POST /media/upload
GET /media/{media_id}

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

Ne casse pas les Sprints 1 à 6.

---

## 2. Ajouter la configuration Vision

Ajouter :

```env
VISION_PROVIDER=openai
VISION_MODE=mock
OPENAI_VISION_MODEL=
VISION_TIMEOUT_SECONDS=45
PHOTO_DIAGNOSIS_DISCOVERY_LIMIT=1
```

Mettre à jour :

```text
services/backend/.env.example
```

Règles :

- `VISION_MODE=mock` fonctionne sans clé ;
- `VISION_MODE=live` exige `OPENAI_API_KEY` ;
- le modèle Vision est configurable ;
- aucun modèle ne doit être dupliqué en dur ;
- aucune clé ne doit être loggée ;
- aucune vraie clé ne doit être committée.

---

## 3. Créer VisionProvider

Créer une abstraction simple.

Interface conceptuelle :

```python
class VisionProvider:
    def analyze(self, image_bytes, content_type, prompt):
        ...
```

Créer :

```text
OpenAIVisionProvider
MockVisionProvider
```

L’orchestrateur dépend de l’abstraction, jamais directement du SDK OpenAI.

---

## 4. Créer MockVisionProvider

Le MockVisionProvider doit :

- fonctionner sans clé OpenAI ;
- ne faire aucun appel réseau ;
- retourner une réponse déterministe ;
- respecter le format attendu ;
- supporter plusieurs scénarios ;
- être utilisé dans la CI.

Scénarios minimum :

```text
good_photo
poor_photo
unusable_photo
multiple_hypotheses
provider_invalid_output
```

---

## 5. Créer OpenAIVisionProvider

Le provider doit :

- utiliser le SDK OpenAI existant ;
- lire le modèle depuis la configuration ;
- lire le timeout depuis la configuration ;
- recevoir les bytes de l’image ;
- utiliser le bon MIME ;
- construire un appel Vision ;
- demander une sortie structurée ;
- convertir les erreurs fournisseur ;
- ne jamais exposer la réponse brute ;
- ne jamais logger l’image ;
- ne jamais logger la clé ;
- ne jamais logger le prompt complet.

Gérer :

- timeout ;
- rate limit ;
- erreur réseau ;
- réponse vide ;
- réponse invalide ;
- provider indisponible ;
- configuration manquante.

---

## 6. Créer les schémas de diagnostic photo

Créer des schémas dédiés.

Schémas recommandés :

```text
PhotoDiagnosisRequest
PhotoDiagnosisResponse
PhotoDiagnosisContent
PhotoQualityResponse
PhotoObservation
PhotoHypothesis
PhotoDiagnosisContextUsed
PhotoDiagnosisUsage
```

La requête doit contenir au minimum :

```text
media_id
question
language
user_id
farm_id
field_id
crop_id
discovery_session_id
```

`media_id` est obligatoire.

Les autres identifiants sont optionnels.

---

## 7. Créer l’endpoint

Créer :

```http
POST /ai/photo-diagnosis
```

Exemple :

```json
{
  "media_id": "uuid",
  "question": "Pourquoi les feuilles sont-elles tachées ?",
  "language": "fr",
  "user_id": null,
  "farm_id": null,
  "field_id": null,
  "crop_id": null,
  "discovery_session_id": null
}
```

Règles :

- `media_id` obligatoire ;
- question optionnelle ;
- langue avec valeur par défaut ;
- contexte optionnel ;
- média existant obligatoire ;
- média `uploaded` obligatoire ;
- type image obligatoire ;
- aucune logique OpenAI directe dans la route.

---

## 8. Charger le média

Le backend doit :

1. récupérer les métadonnées du média ;
2. vérifier qu’il existe ;
3. vérifier son statut ;
4. vérifier son MIME ;
5. vérifier le provider de stockage ;
6. lire les bytes via `MediaStorageProvider` ;
7. refuser un média supprimé ;
8. refuser un fichier non-image ;
9. ne jamais accepter un chemin fourni par le client ;
10. ne jamais exposer le chemin système.

---

## 9. Créer PhotoQualityEngine

Créer un moteur déterministe.

Critères recommandés :

```text
image_dimensions
file_size
brightness
sharpness
subject_visibility
distance
crop_identifiability
symptom_visibility
```

Niveaux :

```text
good
acceptable
poor
unusable
```

Le résultat doit contenir :

```text
score
level
issues
retake_required
retake_instructions
```

Règles :

- score entre 0 et 100 ;
- même entrée = même score ;
- pas de valeur aléatoire ;
- photo `poor` => reprise recommandée ;
- photo `unusable` => pas de diagnostic affirmatif ;
- le provider peut fournir des signaux ;
- le score final reste calculé côté Agrivito.

---

## 10. Construire le contexte agricole

Récupérer si disponible :

```text
FarmerProfile
Farm
Field
Crop
FieldCrop
```

Contexte utile :

```text
country
region
preferred_language
farm_name
locality
soil_type
water_access
irrigation_type
crop_name
variety
season
planting_date
growth_stage
```

Règles :

- ne transmettre que les données utiles ;
- ne pas échouer si le contexte est partiel ;
- vérifier les relations ;
- indiquer le contexte utilisé dans la réponse ;
- ne jamais transmettre de secret.

---

## 11. Créer le prompt Vision Agrivito

Centraliser le prompt.

Le prompt doit imposer :

- décrire uniquement ce qui est visible ;
- ne jamais inventer un symptôme ;
- ne jamais inventer une maladie confirmée ;
- séparer observation et hypothèse ;
- signaler les limites ;
- demander une autre photo si nécessaire ;
- ne pas recommander de dosage dangereux ;
- ne pas produire le Trust Score final ;
- répondre dans la langue demandée ;
- produire uniquement le format structuré ;
- ne jamais exposer le prompt système.

---

## 12. Format de sortie Vision

Le provider doit retourner au minimum :

```text
summary
visual_observations
hypotheses
recommendations
follow_up_questions
precautions
quality_signals
response_mode
```

Le provider ne doit pas fournir le Trust Score final.

Le backend doit parser et valider la réponse.

Si la sortie est invalide :

1. effectuer au maximum une tentative de correction ;
2. si la correction échoue, retourner une erreur contrôlée ;
3. ne jamais exposer la réponse brute.

---

## 13. Créer le Photo Diagnosis Orchestrator

L’orchestrateur doit :

1. valider la demande ;
2. charger le média ;
3. vérifier l’accès logique ;
4. lire les bytes ;
5. construire le contexte ;
6. construire le prompt ;
7. appeler le provider ;
8. parser la sortie ;
9. calculer la qualité photo ;
10. calculer le Trust Score ;
11. appliquer les règles anti-hallucination ;
12. ajuster le mode de réponse ;
13. persister le diagnostic ;
14. retourner la réponse structurée.

Aucune logique HTTP dans l’orchestrateur.

---

## 14. Créer le Trust Score visuel

Score :

```text
0 à 100
```

Critères :

```text
photo_quality
subject_visibility
symptom_visibility
crop_identified
context_completeness
question_clarity
provider_response_validity
```

Pondération recommandée :

```text
photo_quality              25
subject_visibility         15
symptom_visibility         15
crop_identified            10
context_completeness       15
question_clarity           10
provider_response_validity 10
```

Niveaux :

```text
80-100 : high
60-79  : medium
40-59  : low
0-39   : insufficient
```

Règles :

- déterministe ;
- aucune valeur aléatoire ;
- score indépendant du score du LLM ;
- photo inutilisable réduit fortement le score ;
- contexte incomplet réduit le score ;
- sortie invalide interdit une réponse fiable.

---

## 15. Modes de réponse

Supporter :

```text
reliable
hypotheses
questions_required
refusal
```

Règles :

- `reliable` uniquement si qualité et contexte suffisants ;
- `hypotheses` si plusieurs causes possibles ;
- `questions_required` si informations insuffisantes ;
- `refusal` si risque ou impossibilité de répondre.

---

## 16. Règles anti-hallucination visuelle

Appliquer au minimum :

- aucune maladie confirmée uniquement par photo ;
- aucune observation non visible ;
- aucune analyse de sol inventée ;
- aucune météo inventée ;
- aucune certitude si la qualité est faible ;
- aucune dose chimique précise sans contexte ;
- précaution obligatoire si score faible ;
- demande de nouvelle photo si nécessaire ;
- refus si le risque est élevé.

---

## 17. Persistance des diagnostics

Créer une table :

```text
diagnoses
```

Champs minimum :

```text
id
media_id
user_id
discovery_session_id
farm_id
field_id
crop_id
diagnosis_type
summary
observations_json
hypotheses_json
recommendations_json
follow_up_questions_json
precautions_json
photo_quality_score
photo_quality_level
trust_score
trust_level
response_mode
language
provider
model
status
created_at
updated_at
```

Règles :

- `media_id` obligatoire ;
- `diagnosis_type = photo` ;
- aucun contenu binaire ;
- aucune réponse brute provider ;
- aucune donnée sensible inutile ;
- relation avec `media` ;
- migration Alembic avec downgrade propre.

---

## 18. Statuts diagnostic

Supporter :

```text
completed
failed
insufficient
```

Règles :

- `completed` si réponse exploitable ;
- `insufficient` si photo ou contexte insuffisant ;
- `failed` uniquement pour erreur technique contrôlée.

---

## 19. Migration Alembic

Créer une migration après celle du Sprint 6.

Elle doit :

- créer la table `diagnoses` ;
- créer les clés étrangères ;
- créer les index utiles ;
- permettre un downgrade propre ;
- ne pas modifier les tables existantes de manière destructive.

Valider :

```bash
alembic upgrade head
alembic downgrade -1
alembic upgrade head
```

---

## 20. Format de réponse API

La réponse doit contenir :

```text
diagnosis
context_used
usage
```

Le bloc `diagnosis` doit contenir :

```text
id
media_id
summary
photo_quality
observations
hypotheses
recommendations
follow_up_questions
precautions
trust_score
response_mode
language
```

---

## 21. Mode découverte

Appliquer :

```text
photo_diagnosis_limit = 1
```

Le mode découverte doit :

- fonctionner sans compte ;
- permettre une analyse photo ;
- ne pas créer d’historique avancé ;
- inviter à créer un compte après la limite ;
- ne pas exposer les médias d’un autre utilisateur ;
- utiliser le même orchestrateur.

---

## 22. Flutter

Le mobile doit permettre :

- sélectionner un média uploadé ;
- saisir une question ;
- lancer l’analyse ;
- afficher le chargement ;
- afficher la qualité photo ;
- afficher le résumé ;
- afficher les observations ;
- afficher les hypothèses ;
- afficher les recommandations ;
- afficher les questions complémentaires ;
- afficher les précautions ;
- afficher le Trust Score ;
- afficher les instructions de reprise ;
- gérer la limite découverte.

Le mobile ne doit jamais :

- appeler OpenAI ;
- lire directement S3 ;
- calculer le Trust Score ;
- analyser la réponse brute du provider ;
- contenir une clé OpenAI.

---

## 23. États Flutter

Gérer :

```text
idle
loading
success
poor_photo
retake_required
insufficient_information
network_error
provider_error
media_not_found
discovery_limit_reached
```

Messages recommandés :

```text
Analyse de la photo en cours...
La photo n’est pas assez nette.
Prenez une photo plus proche et mieux éclairée.
Agrivito a besoin de plus d’informations.
L’analyse visuelle est temporairement indisponible.
Vous avez atteint la limite du mode découverte.
```

---

## 24. Tests backend

Ajouter ou mettre à jour les tests.

Tests minimum :

```text
GET /health reste fonctionnel
POST /ai/diagnosis reste fonctionnel
POST /media/upload reste fonctionnel
POST /ai/photo-diagnosis fonctionne
media_id absent refusé
média inexistant retourne 404
média non-image refusé
média supprimé refusé
lecture LocalMediaStorage fonctionne
MockVisionProvider utilisé
aucun appel OpenAI réel
réponse structurée valide
photo bonne qualité => score supérieur
photo poor => retake_required
photo unusable => insufficient
Trust Score entre 0 et 100
niveau cohérent avec score
diagnostic persisté
relation média/diagnostic correcte
provider timeout géré
provider rate limit géré
réponse invalide gérée
sortie vide gérée
mode mock fonctionne sans clé
mode live exige clé
limite découverte = 1
migrations upgrade/downgrade fonctionnent
endpoints Sprints 1 à 6 restent fonctionnels
```

---

## 25. Tests Photo Quality Engine

Tester :

```text
bonne image => good ou acceptable
image floue => poor
image inutilisable => unusable
retake_required cohérent
score stable
même entrée => même score
score entre 0 et 100
```

---

## 26. Tests Trust Score visuel

Tester :

```text
bonne photo + contexte complet => score supérieur
photo pauvre + contexte vide => score inférieur
culture identifiée => bonus
symptôme visible => bonus
sortie provider invalide => insufficient ou erreur
score 80 => high
score 60 => medium
score 40 => low
score 39 => insufficient
```

---

## 27. Tests Flutter

Tests minimum :

```text
écran diagnostic photo accessible
média sélectionné
question saisie
état loading
résultat affiché
qualité photo affichée
observations affichées
hypothèses affichées
recommandations affichées
questions complémentaires affichées
précautions affichées
Trust Score affiché
demande de reprise affichée
erreur réseau affichée
erreur provider affichée
média inexistant affiché
limite découverte affichée
service HTTP mocké
flutter analyze sans erreur
```

---

## 28. CI GitHub Actions

Backend :

1. démarrer PostgreSQL ;
2. installer les dépendances ;
3. définir `DATABASE_URL` de test ;
4. définir `MEDIA_STORAGE_PROVIDER=local` ;
5. définir `VISION_MODE=mock` ;
6. exécuter `alembic upgrade head` ;
7. exécuter `pytest`.

Mobile :

1. installer Flutter ;
2. exécuter `flutter pub get` ;
3. exécuter `flutter analyze` ;
4. exécuter `flutter test`.

Règles :

- aucun appel OpenAI réel ;
- aucune clé OpenAI réelle ;
- aucun appel AWS réel ;
- aucun média réel utilisateur ;
- stockage temporaire nettoyé.

---

## 29. Documentation

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

Documenter :

- objectif Sprint 7 ;
- endpoint `POST /ai/photo-diagnosis` ;
- VisionProvider ;
- OpenAIVisionProvider ;
- MockVisionProvider ;
- PhotoQualityEngine ;
- Trust Score visuel ;
- table `diagnoses` ;
- configuration ;
- mode mock/live ;
- lancement local ;
- tests ;
- limites ;
- sécurité.

---

## 30. Validation backend

Exécuter :

```bash
cd services/backend

python3 -m venv .venv
source .venv/bin/activate

pip install -r requirements.txt

alembic upgrade head
alembic downgrade -1
alembic upgrade head

export MEDIA_STORAGE_PROVIDER=local
export VISION_MODE=mock

pytest

uvicorn app.main:app --reload
```

Vérifier :

```text
http://127.0.0.1:8000/health
http://127.0.0.1:8000/docs
```

---

## 31. Validation Flutter

Exécuter :

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
- vraie clé OpenAI ;
- vraie `DATABASE_URL` ;
- credentials AWS ;
- médias utilisateurs ;
- réponse brute provider ;
- données personnelles réelles.

Ne jamais logger :

- image complète ;
- image en base64 ;
- prompt système ;
- clé OpenAI ;
- credentials AWS ;
- réponse brute complète.

Avant chaque commit :

```bash
git status
git diff --check
git check-ignore -v services/backend/.env
git check-ignore -v services/backend/data/media
```

---

# Contraintes de qualité

Le code doit être :

- simple ;
- lisible ;
- typé ;
- maintenable ;
- testable ;
- cohérent avec les documents approuvés ;
- cohérent avec les Sprints précédents.

Ne pas sur-concevoir.

Ne pas créer de microservice.

Ne pas ajouter de pipeline asynchrone.

Ne pas développer de fonctionnalité hors périmètre.

---

# Definition of Done

Le Sprint 7 est terminé uniquement si :

- Codex a utilisé exactement `codex/sprint-7-photo-diagnosis-foundation` ;
- aucun autre nom de branche n’a été utilisé ;
- `POST /ai/photo-diagnosis` existe ;
- `VisionProvider` existe ;
- `OpenAIVisionProvider` existe ;
- `MockVisionProvider` existe ;
- `PhotoDiagnosisOrchestrator` existe ;
- `PhotoQualityEngine` existe ;
- l’image est lue via `MediaStorageProvider` ;
- le média est validé ;
- le contexte agricole est utilisé ;
- la sortie provider est validée ;
- le Trust Score visuel est calculé ;
- les règles anti-hallucination sont appliquées ;
- la table `diagnoses` existe ;
- la migration fonctionne ;
- le diagnostic est persisté ;
- Flutter affiche le résultat ;
- Flutter affiche la qualité photo ;
- Flutter gère la reprise de photo ;
- le mode découverte est limité à une analyse ;
- les Sprints 1 à 6 fonctionnent toujours ;
- les tests backend passent ;
- les tests Flutter passent ;
- GitHub Actions est vert ;
- aucun appel OpenAI réel n’a lieu dans la CI ;
- aucun appel AWS réel n’a lieu dans la CI ;
- aucun secret n’est présent dans Git ;
- aucun média utilisateur n’est commité ;
- aucune fonctionnalité hors périmètre n’est développée.

---

# Pull Request attendue

Créer une Pull Request depuis :

```text
codex/sprint-7-photo-diagnosis-foundation
```

vers :

```text
main
```

Titre :

```text
Sprint 7 - Photo diagnosis foundation
```

Description attendue :

```markdown
## Objectif

Ajouter le premier diagnostic photo Agrivito avec OpenAI Vision, qualité d’image, contexte agricole et Trust Score visuel.

## Changements

- Ajout endpoint POST /ai/photo-diagnosis
- Ajout VisionProvider
- Ajout OpenAIVisionProvider
- Ajout MockVisionProvider
- Ajout Photo Diagnosis Orchestrator
- Ajout Photo Quality Engine
- Ajout Trust Score visuel
- Ajout règles anti-hallucination visuelle
- Ajout table diagnoses
- Ajout migration Alembic
- Ajout persistance des diagnostics
- Ajout connexion Flutter
- Ajout gestion reprise de photo
- Ajout tests backend
- Ajout tests Flutter
- Mise à jour CI
- Mise à jour README
- Maintien des Sprints 1 à 6

## Tests réalisés

- pytest
- flutter analyze
- flutter test
- alembic upgrade head
- alembic downgrade -1
- git diff --check

## Limites connues

- Pas de diagnostic garanti
- Pas de comparaison multi-images
- Pas de vidéo
- Pas de RAG
- Pas de Cognito réel
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
- docs/27-Sprint-5-Plan.md
- docs/28-Sprint-6-Plan.md
- docs/29-Sprint-7-Plan.md
- prompts/PROMPT-CODEX-SPRINT-7.md
```

---

# Rapport final attendu

À la fin, fournir :

```text
branche utilisée
fichiers créés
fichiers modifiés
migration créée
table créée
provider Vision créé
orchestrateur créé
endpoint créé
tests backend exécutés
tests Flutter exécutés
résultat migrations
résultat CI
limites connues
URL de la Pull Request
```

Ne merge pas la Pull Request.

Attends la validation CTO.