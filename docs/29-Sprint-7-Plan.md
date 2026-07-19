---
title: Sprint 7 Plan
version: 1.0
status: Approved
owner: CTO
approved_by: CEO
last_updated: 2026-07-19
---

# Agrivito - Sprint 7 Plan

## 1. Nom du Sprint

**Sprint 7 - Photo Diagnosis Foundation**

## 2. Objectif

Le Sprint 7 doit permettre à Agrivito d’analyser une photo agricole déjà uploadée, de combiner cette image avec une question utilisateur et le contexte agricole disponible, puis de produire un diagnostic visuel structuré, prudent et accompagné d’un Trust Score.

L’analyse doit être réalisée via OpenAI Vision depuis le backend FastAPI uniquement. Le Sprint 7 constitue la première capacité réelle d’analyse visuelle d’Agrivito.

## 3. Valeur produit

À la fin du Sprint 7, un agriculteur doit pouvoir :

- sélectionner une photo déjà envoyée ;
- ajouter une question ou un commentaire ;
- demander une analyse ;
- recevoir une évaluation de la qualité de l’image ;
- connaître les éléments visuellement observés ;
- consulter plusieurs hypothèses possibles ;
- recevoir des recommandations simples ;
- savoir si une autre photo est nécessaire ;
- consulter un niveau de confiance ;
- comprendre les limites de l’analyse.

Agrivito ne doit jamais présenter une hypothèse visuelle comme une certitude médicale, agronomique ou phytosanitaire.

## 4. Architecture cible Sprint 7

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
Vision Provider
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
PostgreSQL diagnosis record
```

Règles obligatoires :

- Flutter ne communique jamais directement avec OpenAI ;
- seul FastAPI appelle OpenAI Vision ;
- le média est lu via `MediaStorageProvider` ;
- aucune URL publique permanente n’est nécessaire ;
- la photo est validée avant analyse ;
- le contexte agricole est récupéré côté backend ;
- le Trust Score est calculé côté Agrivito ;
- le LLM ne décide pas seul du score ;
- aucun appel OpenAI réel n’est effectué dans la CI ;
- le mode mock permet tous les tests.

## 5. Contexte actuel

Les Sprints précédents ont livré :

### Sprint 5

- AI Orchestrator texte ;
- OpenAIProvider ;
- MockAIProvider ;
- Trust Score Engine ;
- réponses structurées ;
- règles anti-hallucination.

### Sprint 6

- table `media` ;
- upload photo ;
- `MediaStorageProvider` ;
- `LocalMediaStorage` ;
- `S3MediaStorage` ;
- capture et sélection Flutter ;
- prévisualisation ;
- validation MIME et taille ;
- persistance des métadonnées.

Limites actuelles :

- aucune analyse visuelle ;
- aucun endpoint de diagnostic photo ;
- aucune table de diagnostic photo ;
- aucune évaluation de qualité d’image ;
- aucun provider Vision ;
- aucun affichage de résultat photo dans Flutter.

## 6. Périmètre Sprint 7

Le Sprint 7 couvre :

1. création de `POST /ai/photo-diagnosis` ;
2. création d’un orchestrateur de diagnostic photo ;
3. création d’un provider Vision ;
4. création de `OpenAIVisionProvider` ;
5. création de `MockVisionProvider` ;
6. lecture sécurisée du média ;
7. validation du média ;
8. vérification du statut du média ;
9. évaluation de la qualité photo ;
10. construction du contexte agricole ;
11. combinaison image + question + contexte ;
12. format de réponse structuré ;
13. analyse des éléments visibles ;
14. hypothèses prudentes ;
15. recommandations simples ;
16. questions complémentaires ;
17. demande éventuelle d’une nouvelle photo ;
18. Trust Score visuel ;
19. persistance du diagnostic ;
20. table `diagnoses` ou équivalent ;
21. migration Alembic ;
22. association diagnostic / média ;
23. affichage Flutter ;
24. gestion des états UI ;
25. mode découverte ;
26. tests backend ;
27. tests Flutter ;
28. CI en mode mock ;
29. mise à jour des README ;
30. maintien des Sprints 1 à 6.

## 7. Hors périmètre strict

Ne pas développer :

- reconnaissance garantie d’une maladie ;
- classification médicale certaine ;
- traitement vétérinaire ;
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

## 8. Endpoint principal

Créer :

```http
POST /ai/photo-diagnosis
```

Exemple de requête :

```json
{
  "media_id": "uuid",
  "question": "Pourquoi les feuilles sont-elles tachées ?",
  "language": "fr",
  "user_id": "optional-user-id",
  "farm_id": "optional-farm-id",
  "field_id": "optional-field-id",
  "crop_id": "optional-crop-id",
  "discovery_session_id": "optional-session-id"
}
```

Règles :

- `media_id` obligatoire ;
- `question` optionnelle mais recommandée ;
- `language` avec valeur par défaut ;
- contexte agricole optionnel ;
- média existant obligatoire ;
- média au statut `uploaded` obligatoire ;
- média de type image obligatoire ;
- aucune logique OpenAI directement dans la route.

## 9. Réponse structurée

Le bloc de réponse doit contenir :

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
context_used
usage
```

Le bloc `photo_quality` doit contenir :

```text
score
level
issues
retake_required
retake_instructions
```

## 10. Photo Quality Engine

Créer un moteur déterministe d’évaluation de qualité.

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

Règles :

- une photo `unusable` ne produit pas de diagnostic affirmatif ;
- une photo `poor` génère une demande de nouvelle photo ;
- le score est calculé côté Agrivito ;
- le provider Vision peut fournir des observations, mais pas le score final.

## 11. Provider Vision

Créer une abstraction :

```python
class VisionProvider:
    def analyze(self, image_bytes, content_type, prompt):
        ...
```

Implémentations :

```text
OpenAIVisionProvider
MockVisionProvider
```

### OpenAIVisionProvider

Doit :

- utiliser le SDK OpenAI ;
- lire le modèle depuis la configuration ;
- recevoir les bytes de l’image ;
- utiliser le bon MIME ;
- produire une sortie structurée ;
- appliquer un timeout ;
- convertir les erreurs en exceptions internes ;
- ne jamais exposer la réponse brute.

### MockVisionProvider

Doit :

- fonctionner sans clé ;
- ne faire aucun appel réseau ;
- retourner une réponse déterministe ;
- être utilisé dans la CI ;
- supporter plusieurs scénarios de test.

## 12. Configuration

Ajouter :

```env
VISION_PROVIDER=openai
VISION_MODE=mock
OPENAI_VISION_MODEL=
VISION_TIMEOUT_SECONDS=45
PHOTO_DIAGNOSIS_DISCOVERY_LIMIT=1
```

Règles :

- `VISION_MODE=mock` par défaut dans la CI ;
- `VISION_MODE=live` exige une clé OpenAI ;
- le modèle Vision est configurable ;
- aucun modèle n’est dupliqué en dur ;
- aucune clé n’est exposée.

## 13. Persistance des diagnostics

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
- stockage structuré ou JSON acceptable selon les ADR ;
- aucun contenu binaire en base ;
- aucune réponse brute du provider en base ;
- aucune donnée sensible inutile ;
- downgrade Alembic propre.

## 14. Statuts diagnostic

```text
completed
failed
insufficient
```

- `completed` si réponse exploitable ;
- `insufficient` si photo inutilisable ou contexte insuffisant ;
- `failed` pour une erreur technique contrôlée.

## 15. Orchestrateur photo

Créer un orchestrateur responsable de :

1. valider la requête ;
2. charger le média ;
3. vérifier l’accès logique ;
4. lire le contenu via le storage provider ;
5. vérifier le MIME ;
6. construire le contexte agricole ;
7. construire le prompt Vision ;
8. appeler le provider ;
9. parser la sortie ;
10. calculer la qualité photo ;
11. calculer le Trust Score ;
12. appliquer les règles anti-hallucination ;
13. déterminer le mode de réponse ;
14. persister le diagnostic ;
15. retourner une réponse structurée.

Aucune logique HTTP dans l’orchestrateur.

## 16. Prompt Vision Agrivito

Le prompt doit imposer :

- décrire uniquement ce qui est visible ;
- ne jamais inventer un symptôme ;
- ne jamais confirmer une maladie sans réserve ;
- séparer observation et hypothèse ;
- signaler les limites visuelles ;
- demander une autre photo si nécessaire ;
- ne pas donner de dosage dangereux ;
- ne pas produire le Trust Score final ;
- répondre dans la langue demandée ;
- produire uniquement le format attendu ;
- ne jamais exposer le prompt système.

## 17. Règles anti-hallucination visuelle

- aucune maladie confirmée uniquement par photo ;
- aucune analyse de sol inventée ;
- aucune météo inventée ;
- aucune observation hors image ;
- aucune certitude si la qualité est insuffisante ;
- aucune recommandation chimique précise sans contexte ;
- obligation de demander une autre photo si nécessaire ;
- précaution obligatoire si score faible ;
- mode `refusal` ou `questions_required` si risque élevé.

## 18. Trust Score visuel

Score de 0 à 100.

Critères recommandés :

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

Le score doit être déterministe.

## 19. Mode découverte

```text
photo_diagnosis_limit = 1
```

Règles :

- analyse possible sans compte ;
- une seule analyse photo ;
- pas d’historique durable avancé ;
- réponse structurée ;
- invitation à créer un compte après la limite ;
- aucun accès au média d’un autre utilisateur.

## 20. Flutter

L’application doit permettre :

- sélectionner un média déjà uploadé ;
- saisir une question ;
- lancer le diagnostic ;
- afficher le chargement ;
- afficher la qualité photo ;
- afficher le résumé ;
- afficher les observations ;
- afficher les hypothèses ;
- afficher les recommandations ;
- afficher les questions complémentaires ;
- afficher les précautions ;
- afficher le Trust Score ;
- afficher une demande de nouvelle photo ;
- gérer la limite découverte.

Le mobile ne doit jamais :

- appeler OpenAI ;
- lire directement S3 ;
- calculer le Trust Score ;
- interpréter une réponse brute du provider.

## 21. États UI

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
```

## 22. Tests backend

Tests minimum :

- endpoint photo diagnosis fonctionne ;
- média inexistant retourne 404 ;
- média non-image refusé ;
- média supprimé refusé ;
- lecture local storage fonctionne ;
- MockVisionProvider utilisé ;
- aucun appel OpenAI réel ;
- réponse structurée valide ;
- photo bonne qualité => score supérieur ;
- photo mauvaise qualité => retake ;
- photo inutilisable => insufficient ;
- Trust Score cohérent ;
- diagnostic persisté ;
- relation média/diagnostic correcte ;
- erreur provider gérée ;
- timeout géré ;
- réponse invalide gérée ;
- limite découverte appliquée ;
- endpoints Sprints 1 à 6 toujours fonctionnels ;
- migrations upgrade/downgrade fonctionnent.

## 23. Tests Flutter

Tests minimum :

- écran diagnostic photo accessible ;
- média sélectionné ;
- question saisie ;
- état loading ;
- résultat affiché ;
- qualité photo affichée ;
- observations affichées ;
- hypothèses affichées ;
- recommandations affichées ;
- Trust Score affiché ;
- demande de nouvelle photo affichée ;
- erreur réseau affichée ;
- erreur provider affichée ;
- limite découverte affichée ;
- service HTTP mocké ;
- `flutter analyze` sans erreur.

## 24. CI GitHub Actions

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

Aucun appel OpenAI réel.

## 25. README

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
- Photo Quality Engine ;
- Trust Score visuel ;
- table `diagnoses` ;
- configuration ;
- mode mock/live ;
- limites ;
- sécurité ;
- tests.

## 26. Contraintes de sécurité

Ne jamais commiter :

- `.env` ;
- vraie clé OpenAI ;
- vraie `DATABASE_URL` ;
- credentials AWS ;
- médias utilisateurs ;
- réponses brutes provider ;
- données personnelles réelles.

Ne jamais logger :

- image complète ;
- base64 image ;
- prompt système ;
- clé OpenAI ;
- credentials ;
- réponse brute complète.

## 27. Definition of Done

Le Sprint 7 est terminé uniquement si :

- `POST /ai/photo-diagnosis` existe ;
- VisionProvider existe ;
- OpenAIVisionProvider existe ;
- MockVisionProvider existe ;
- Photo Quality Engine existe ;
- l’image est lue via MediaStorageProvider ;
- la photo est validée ;
- le contexte agricole est utilisé ;
- la réponse est structurée ;
- le Trust Score visuel est calculé ;
- les règles anti-hallucination sont appliquées ;
- la table `diagnoses` existe ;
- la migration fonctionne ;
- le diagnostic est persisté ;
- Flutter affiche le résultat ;
- Flutter gère la reprise de photo ;
- le mode découverte est limité ;
- les tests backend passent ;
- les tests Flutter passent ;
- GitHub Actions est vert ;
- aucun appel OpenAI réel n’a lieu dans la CI ;
- aucun secret n’est présent dans Git ;
- les Sprints 1 à 6 restent fonctionnels ;
- aucune fonctionnalité hors périmètre n’est développée.

## 28. Branche de développement

Codex doit créer et utiliser exactement :

```text
codex/sprint-7-photo-diagnosis-foundation
```

Règle bloquante :

```text
Aucun autre nom de branche n’est autorisé.
```

Codex doit partir du dernier état de `main`.

Codex ne doit jamais travailler directement sur `main`.

Codex ne doit jamais merger la Pull Request.

## 29. Pull Request attendue

Titre :

```text
Sprint 7 - Photo diagnosis foundation
```

Description :

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
```

## 30. Statut

**APPROVED**