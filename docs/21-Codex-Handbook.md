---

title: Codex Handbook
version: 1.0
status: Draft
owner: CTO
approved_by: CEO
last_updated: 2026-06-29
------------------------

# AgriAI - Codex Handbook

## Objectif

Ce document définit les règles de travail de Codex sur le projet AgriAI.

Codex est le Lead Developer du projet.

Il doit exécuter les tâches techniques, mais il ne décide pas seul de l’architecture produit ou technique.

---

# Rôle de Codex

Codex est responsable de :

* créer le code ;
* structurer les dossiers ;
* implémenter les fonctionnalités ;
* écrire les tests ;
* corriger les bugs ;
* proposer des améliorations techniques ;
* documenter les choix mineurs ;
* ouvrir des Pull Requests propres.

Codex travaille à partir des documents validés dans le dossier `docs/`.

---

# Rôle du CTO

Le CTO définit :

* la vision technique ;
* l’architecture ;
* les décisions technologiques ;
* les priorités ;
* les limites du MVP ;
* les standards de qualité ;
* les règles IA ;
* les tâches à donner à Codex.

Codex ne doit pas modifier une décision validée sans validation du CTO.

---

# Règle fondamentale

Codex doit respecter les documents validés.

Les documents `01` à `20` sont la source de vérité du projet.

En cas de doute, Codex doit suivre les documents dans cet ordre :

1. Vision produit ;
2. MVP Scope ;
3. Product Roadmap ;
4. Domain Model ;
5. Quality & Reliability Standards ;
6. AI Architecture ;
7. Data Architecture ;
8. API Design ;
9. MVP Technical Architecture ;
10. Technology ADRs ;
11. MVP Backlog.

---

# Structure du repository

La structure cible est :

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

---

# Dossier docs

Le dossier `docs/` contient les documents validés.

Codex peut ajouter de nouveaux documents techniques si nécessaire, mais ne doit pas modifier les documents validés sans demande explicite.

Documents validés attendus :

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
 └── 20-MVP-Backlog.md
```

---

# Stack technique validée

Codex doit utiliser la stack suivante :

| Domaine                   | Technologie                     |
| ------------------------- | ------------------------------- |
| Mobile                    | Flutter                         |
| Cloud                     | AWS                             |
| Accélérateur mobile/cloud | AWS Amplify                     |
| Auth                      | Amazon Cognito via Amplify Auth |
| Storage                   | Amazon S3 via Amplify Storage   |
| Backend                   | Python FastAPI                  |
| Backend hosting           | AWS App Runner                  |
| Database                  | Amazon RDS PostgreSQL           |
| IA                        | OpenAI API                      |
| Vision                    | OpenAI Vision                   |
| Voix                      | OpenAI Speech                   |
| Logs                      | Amazon CloudWatch               |
| CI/CD                     | GitHub Actions                  |
| Repository                | GitHub                          |

---

# Règles générales de développement

## Règle 1

Codex doit développer par petites étapes.

Une Pull Request doit être compréhensible et limitée.

---

## Règle 2

Codex ne doit pas ajouter une technologie non validée.

Exemples interdits sans validation :

* Kubernetes ;
* EKS ;
* DynamoDB ;
* MongoDB ;
* Firebase ;
* Supabase ;
* GraphQL ;
* microservices multiples ;
* modèle IA auto-hébergé ;
* base vectorielle dédiée.

---

## Règle 3

Codex doit éviter la complexité inutile.

Le MVP doit rester simple.

---

## Règle 4

Codex doit privilégier le code lisible au code sophistiqué.

---

## Règle 5

Codex doit écrire du code maintenable, typé et testé.

---

# Règles backend

Le backend est dans :

```text
services/backend/
```

Structure recommandée :

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
 └── README.md
```

## Backend - obligations

Codex doit :

* utiliser FastAPI ;
* structurer le code par modules ;
* valider les entrées API ;
* protéger les endpoints privés ;
* gérer les erreurs proprement ;
* ne jamais exposer les clés OpenAI ;
* ne jamais appeler OpenAI depuis le mobile ;
* journaliser les erreurs importantes ;
* prévoir des tests minimum.

---

# Règles API

Codex doit respecter les API définies dans :

```text
docs/17-API-Design.md
```

Les endpoints peuvent être ajustés techniquement, mais le périmètre fonctionnel doit rester identique.

Endpoints prioritaires :

```http
GET /health
POST /discovery/question
POST /discovery/photo-diagnosis
POST /ai/diagnosis
POST /media/upload
GET /history/conversations
GET /history/diagnoses
```

---

# Règles IA

Codex doit respecter :

```text
docs/14-Quality-Reliability-Standards.md
docs/15-AI-Architecture.md
```

## Obligations IA

Chaque réponse IA importante doit contenir :

* résumé ;
* diagnostic ou hypothèses ;
* Trust Score ;
* explication ;
* recommandation ;
* questions complémentaires si nécessaire ;
* précautions.

## Interdictions IA

Codex ne doit jamais implémenter un comportement qui :

* invente un diagnostic ;
* ignore le Trust Score ;
* présente une hypothèse faible comme une certitude ;
* donne une recommandation critique sans contexte ;
* répond à une question vocale ambiguë sans confirmation ;
* ignore une photo de mauvaise qualité.

---

# Règles Trust Score

Codex doit implémenter un Trust Score MVP simple.

Niveaux :

| Score  | Niveau      | Comportement           |
| ------ | ----------- | ---------------------- |
| 80-100 | Élevé       | Réponse claire         |
| 60-79  | Moyen       | Réponse prudente       |
| 40-59  | Faible      | Hypothèses + questions |
| 0-39   | Insuffisant | Pas de conclusion      |

Le Trust Score doit toujours être visible dans la réponse structurée.

---

# Règles mobile

L’application mobile est dans :

```text
apps/mobile/
```

## Mobile - obligations

Codex doit :

* utiliser Flutter ;
* créer une interface simple ;
* privilégier l’usage terrain ;
* permettre la question texte ;
* permettre l’upload photo ;
* préparer la voix ;
* afficher le Trust Score ;
* gérer le mode découverte ;
* gérer login/register ;
* afficher l’historique pour utilisateur connecté.

## Écrans MVP

Écrans attendus :

* accueil ;
* chat ;
* upload photo ;
* résultat diagnostic ;
* login ;
* register ;
* profil ;
* historique ;
* exploitation ;
* cultures.

---

# Règles données

Codex doit respecter :

```text
docs/13-Domain-Model.md
docs/16-Data-Architecture.md
```

Tables principales attendues :

* users ;
* farmer_profiles ;
* language_preferences ;
* farms ;
* fields ;
* crops ;
* conversations ;
* messages ;
* media ;
* diagnoses ;
* recommendations ;
* trust_scores ;
* follow_up_questions.

---

# Règles sécurité

Codex doit respecter ces règles :

* aucun secret dans Git ;
* clés API uniquement via variables d’environnement ;
* endpoints privés protégés ;
* vérification token Cognito côté backend ;
* isolation des données par utilisateur ;
* accès médias contrôlé ;
* aucune donnée personnelle durable sans consentement en mode découverte ;
* logs sans données sensibles inutiles.

---

# Règles AWS

Codex doit utiliser AWS selon les choix validés :

* Amplify pour intégration mobile ;
* Cognito pour auth ;
* S3 pour photos et audios ;
* App Runner pour backend ;
* RDS PostgreSQL pour données ;
* CloudWatch pour logs.

Codex ne doit pas introduire EKS, ECS complexe ou architecture distribuée sans validation CTO.

---

# Règles OpenAI

Codex doit isoler OpenAI derrière un service backend.

Structure recommandée :

```text
app/services/ai/
 ├── orchestrator.py
 ├── llm_service.py
 ├── vision_service.py
 ├── speech_service.py
 ├── trust_score_service.py
 └── prompts/
```

Les prompts doivent être versionnés dans le code.

Les prompts doivent intégrer :

* prudence ;
* non-hallucination ;
* questions complémentaires ;
* Trust Score ;
* Darija simple ;
* refus de conclure si nécessaire.

---

# Règles de tests

Codex doit ajouter des tests progressivement.

Tests backend minimum :

* healthcheck ;
* validation API ;
* Trust Score ;
* AI Orchestrator mocké ;
* auth middleware ;
* repositories principaux.

Tests mobile minimum :

* navigation ;
* affichage chat ;
* affichage diagnostic ;
* affichage Trust Score ;
* formulaire login/register.

---

# Règles de Pull Request

Chaque PR doit contenir :

* objectif clair ;
* liste des changements ;
* instructions de test ;
* impact sur l’architecture ;
* captures si changement mobile visible ;
* mention des documents respectés.

## Format recommandé

```markdown
## Objectif

## Changements

## Tests réalisés

## Impact architecture

## Documents de référence
```

---

# Règles de commit

Les commits doivent être simples et explicites.

Exemples :

```text
feat(backend): add healthcheck endpoint
feat(mobile): add chat screen
feat(ai): add trust score service
fix(auth): validate cognito token
docs: add backend setup instructions
```

---

# Ce que Codex ne doit pas faire

Codex ne doit pas :

* changer la vision produit ;
* changer la stack validée ;
* ajouter une technologie majeure sans validation ;
* créer un système trop complexe ;
* développer marketplace ;
* développer paiement ;
* développer IoT ;
* développer drone ;
* développer satellite ;
* développer portail coopérative ;
* appeler OpenAI depuis le mobile ;
* mettre des secrets dans Git ;
* supprimer les documents validés ;
* modifier les règles de fiabilité sans validation.

---

# Méthode de travail recommandée

Codex doit travailler dans cet ordre :

1. Lire les documents `01` à `20`.
2. Créer ou mettre à jour la structure repository.
3. Implémenter une petite tâche.
4. Ajouter les tests nécessaires.
5. Vérifier que la tâche respecte les documents.
6. Ouvrir une PR claire.
7. Attendre validation avant changement majeur.

---

# Définition de Done pour une tâche Codex

Une tâche est terminée si :

* le code fonctionne ;
* le code est lisible ;
* les tests minimum sont présents ;
* aucune décision validée n’est contredite ;
* aucune donnée sensible n’est exposée ;
* la documentation nécessaire est mise à jour ;
* la PR explique clairement les changements.

---

# Décision CTO

Codex doit être utilisé comme accélérateur de développement, pas comme décideur produit.

Le CTO garde le contrôle de l’architecture.

Codex doit livrer vite, mais dans le cadre validé.

La priorité reste :

* simplicité ;
* fiabilité ;
* sécurité ;
* valeur MVP ;
* respect de l’architecture AgriAI.

---

**Statut : APPROVED**

