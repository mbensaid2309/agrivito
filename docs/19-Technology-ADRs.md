---

title: Technology ADRs
version: 1.0
status: Approved
owner: CTO
approved_by: CEO
last_updated: 2026-06-29
------------------------

# AgriAI - Technology ADRs

## Objectif

Ce document définit les premières décisions technologiques du MVP AgriAI.

Chaque décision est formulée sous forme d’ADR simplifiée.

Le but est de choisir une stack simple, rapide à développer, fiable et compatible avec l’évolution future d’AgriAI.

---

# Synthèse des choix MVP

| Domaine                   | Décision MVP                                              |
| ------------------------- | --------------------------------------------------------- |
| Application mobile        | Flutter                                                   |
| Backend API               | Python FastAPI                                            |
| Plateforme cloud MVP      | AWS                                                       |
| Accélérateur mobile/cloud | AWS Amplify                                               |
| Authentification          | Amazon Cognito via Amplify Auth                           |
| Stockage média            | Amazon S3 via Amplify Storage                             |
| Base de données métier    | Amazon RDS PostgreSQL                                     |
| IA / LLM                  | OpenAI API                                                |
| Vision photo              | OpenAI Vision                                             |
| Voix / transcription      | OpenAI Speech / Realtime selon besoin                     |
| Base de connaissance MVP  | PostgreSQL + documents structurés                         |
| RAG futur                 | PostgreSQL + pgvector ou moteur vectoriel dédié plus tard |
| Hébergement backend       | AWS App Runner                                            |
| Observabilité             | Amazon CloudWatch + OpenTelemetry progressivement         |
| CI/CD                     | GitHub Actions + Amplify/App Runner                       |
| Repository                | GitHub                                                    |

---

# ADR-001 - Application mobile

## Décision

Utiliser **Flutter** pour l’application mobile MVP.

## Pourquoi

Flutter permet de développer une application mobile avec une seule base de code pour Android et iOS.

C’est adapté à AgriAI car le MVP est Mobile First.

## Alternatives étudiées

* React Native ;
* application native Android ;
* application native iOS ;
* PWA.

## Raisons du choix

* développement rapide ;
* bonne expérience mobile ;
* compatible Android et iOS ;
* bon support caméra ;
* bon support audio ;
* possibilité d’évoluer plus tard vers web si nécessaire.

## Décision CTO

Flutter est retenu pour le MVP mobile AgriAI.

---

# ADR-002 - Backend API

## Décision

Utiliser **Python FastAPI** pour le backend API.

## Pourquoi

AgriAI est fortement lié à l’IA, au traitement de données, à la vision, à la voix et à l’orchestration.

Python est l’écosystème le plus naturel pour ce type de backend.

FastAPI est adapté pour construire rapidement des API modernes, typées et documentées.

## Alternatives étudiées

* Node.js / NestJS ;
* Django ;
* Go ;
* Java Spring Boot.

## Raisons du choix

* excellent écosystème IA ;
* développement rapide ;
* API claire ;
* documentation OpenAPI automatique ;
* compatible avec une architecture modulaire ;
* facile à connecter aux services IA.

## Décision CTO

FastAPI est retenu pour le MVP.

---

# ADR-003 - Plateforme cloud MVP

## Décision

Utiliser **AWS** comme plateforme cloud principale du MVP.

## Pourquoi

Le CEO possède déjà un compte AWS.

AWS permet de démarrer rapidement avec Amplify, Cognito, S3, App Runner et RDS.

L’objectif du MVP est de livrer vite, sans complexifier l’infrastructure.

## Alternatives étudiées

* Google Cloud Platform ;
* Azure ;
* Supabase cloud ;
* Firebase ;
* hébergement VPS classique.

## Raisons du choix

* compte AWS déjà disponible ;
* AWS Amplify accélère le démarrage mobile ;
* services managés matures ;
* bon support pour authentification, stockage et backend ;
* possibilité d’évoluer progressivement vers une architecture plus robuste.

## Décision CTO

AWS est retenu comme plateforme cloud principale du MVP.

---

# ADR-004 - Accélérateur mobile/cloud

## Décision

Utiliser **AWS Amplify** comme accélérateur MVP.

## Pourquoi

Amplify permet de connecter rapidement une application mobile à plusieurs services AWS.

Il facilite notamment :

* authentification ;
* stockage fichiers ;
* configuration mobile ;
* intégration backend ;
* déploiement futur d’une interface web.

## Alternatives étudiées

* Supabase ;
* Firebase ;
* Appwrite ;
* backend entièrement custom ;
* intégration AWS manuelle dès le départ.

## Raisons du choix

* rapidité de mise en place ;
* adapté au MVP ;
* bonne intégration avec Cognito et S3 ;
* compatible Flutter ;
* réduit le temps de développement initial.

## Limite

Amplify ne doit pas contenir toute la logique métier critique.

La logique métier AgriAI doit rester dans le backend FastAPI.

## Décision CTO

AWS Amplify est retenu pour accélérer le MVP, sans enfermer l’architecture.

---

# ADR-005 - Authentification

## Décision

Utiliser **Amazon Cognito via Amplify Auth** pour l’authentification MVP.

## Pourquoi

Le MVP nécessite :

* création de compte ;
* connexion ;
* gestion utilisateur ;
* mode découverte ;
* historique pour utilisateurs connectés.

Cognito permet de gérer l’authentification sans développer une solution custom.

## Alternatives étudiées

* Auth custom ;
* Supabase Auth ;
* Firebase Auth ;
* Auth0 ;
* Keycloak.

## Raisons du choix

* intégré à AWS ;
* compatible Amplify ;
* compatible mobile ;
* évite de développer une authentification custom trop tôt ;
* peut évoluer vers email, téléphone ou fédération d’identité.

## Décision CTO

Amazon Cognito via Amplify Auth est retenu pour le MVP.

---

# ADR-006 - Stockage média

## Décision

Utiliser **Amazon S3 via Amplify Storage** pour les photos et audios.

## Pourquoi

Le MVP doit gérer :

* photos de cultures ;
* audios utilisateurs ;
* fichiers liés aux conversations ;
* fichiers liés aux diagnostics.

S3 est robuste, standard et adapté au stockage de médias.

## Alternatives étudiées

* Supabase Storage ;
* Firebase Storage ;
* stockage local serveur ;
* stockage fichier sur VM.

## Raisons du choix

* service AWS standard ;
* robuste ;
* scalable ;
* intégré avec Amplify ;
* compatible avec politiques d’accès ;
* adapté aux photos et audios.

## Décision CTO

Amazon S3 via Amplify Storage est retenu pour les médias MVP.

---

# ADR-007 - Base de données métier

## Décision

Utiliser **Amazon RDS PostgreSQL** comme base de données métier principale.

## Pourquoi

AgriAI manipule des données structurées :

* utilisateurs ;
* exploitations ;
* parcelles ;
* cultures ;
* conversations ;
* diagnostics ;
* recommandations ;
* Trust Scores.

PostgreSQL est fiable, robuste et adapté aux relations métier.

## Alternatives étudiées

* DynamoDB ;
* MongoDB ;
* Firebase Firestore ;
* MySQL ;
* Supabase PostgreSQL.

## Raisons du choix

* modèle relationnel clair ;
* transactions fiables ;
* données structurées ;
* compatible JSONB pour données semi-structurées ;
* compatible avec pgvector plus tard ;
* bonne base pour l’historique et la traçabilité.

## Limite

RDS demande plus d’attention opérationnelle qu’un backend purement serverless.

Pour le MVP, il faut garder une configuration simple et maîtrisée.

## Décision CTO

Amazon RDS PostgreSQL est retenu comme base centrale du MVP.

---

# ADR-008 - Backend API

## Décision

Héberger le backend **FastAPI** sur **AWS App Runner**.

## Pourquoi

FastAPI fonctionne naturellement comme une API web containerisée.

AWS App Runner permet de déployer une application web containerisée sans gérer directement les serveurs.

## Alternatives étudiées

* AWS Lambda ;
* AWS ECS Fargate ;
* EC2 ;
* Elastic Beanstalk ;
* Kubernetes / EKS ;
* Cloud Run.

## Raisons du choix

* simple pour démarrer ;
* compatible Docker ;
* adapté à une API FastAPI ;
* moins complexe qu’ECS ou EKS ;
* plus naturel que Lambda pour une API web continue ;
* cohérent avec AWS-first.

## Décision CTO

AWS App Runner est retenu pour héberger le backend FastAPI du MVP.

---

# ADR-009 - IA / LLM

## Décision

Utiliser **OpenAI API** comme fournisseur IA principal du MVP.

## Pourquoi

AgriAI a besoin de capacités fortes en :

* compréhension du langage ;
* raisonnement ;
* génération de réponses ;
* vision photo ;
* voix ;
* multilingue ;
* Darija autant que possible.

## Alternatives étudiées

* modèles open source auto-hébergés ;
* Mistral ;
* Anthropic ;
* Google Gemini ;
* modèles spécialisés agricoles.

## Raisons du choix

* très bonne qualité de raisonnement ;
* support multimodal ;
* vitesse d’intégration ;
* compatible MVP ;
* réduit fortement la complexité infrastructure.

## Limite

AgriAI ne doit pas dépendre aveuglément du LLM.

Le LLM doit être encadré par :

* contexte agricole ;
* base de connaissance ;
* Trust Score ;
* règles anti-hallucination ;
* questions complémentaires.

## Décision CTO

OpenAI API est retenu pour le MVP.

---

# ADR-010 - Vision photo

## Décision

Utiliser **OpenAI Vision** au démarrage pour l’analyse photo.

## Pourquoi

Le diagnostic photo est une fonctionnalité centrale du MVP.

Il faut démarrer vite sans construire un modèle vision agricole propriétaire dès le début.

## Alternatives étudiées

* modèle vision custom ;
* Google Vision ;
* AWS Rekognition ;
* modèle open source spécialisé ;
* classification manuelle.

## Raisons du choix

* intégration rapide ;
* cohérence avec le LLM ;
* capacité multimodale ;
* suffisant pour premier MVP ;
* permet de tester la valeur produit rapidement.

## Limite

OpenAI Vision ne doit pas être présenté comme un expert absolu.

La réponse doit toujours passer par le Trust Score.

## Décision CTO

OpenAI Vision est retenu pour le MVP.

---

# ADR-011 - Voix

## Décision

Utiliser les services voix OpenAI pour :

* transcription ;
* compréhension vocale ;
* éventuellement réponse vocale courte.

## Pourquoi

La voix est importante pour les agriculteurs marocains.

L’utilisateur doit pouvoir parler simplement, notamment en Darija.

## Alternatives étudiées

* Amazon Transcribe ;
* Google Speech-to-Text ;
* Whisper auto-hébergé ;
* services mobiles natifs ;
* Azure Speech.

## Raisons du choix

* intégration cohérente avec l’IA ;
* bonne couverture multilingue ;
* possibilité d’évolution vers interaction temps réel ;
* moins de complexité au MVP.

## Limite

La Darija doit être testée sérieusement.

Si la qualité est insuffisante, prévoir une alternative spécialisée ou un mode confirmation systématique.

## Décision CTO

OpenAI Speech est retenu pour le MVP, avec validation terrain Darija obligatoire.

---

# ADR-012 - Base de connaissance

## Décision

Démarrer avec une base de connaissance simple dans **PostgreSQL**.

## Pourquoi

Le MVP n’a pas besoin immédiatement d’un RAG complexe.

Il faut d’abord structurer les contenus agricoles fiables :

* fiches cultures ;
* maladies ;
* symptômes ;
* ravageurs ;
* bonnes pratiques ;
* recommandations de base ;
* sources validées.

## Alternatives étudiées

* RAG complet dès le départ ;
* base vectorielle dédiée ;
* documents non structurés uniquement ;
* recherche full-text seulement.

## Raisons du choix

* simplicité ;
* maîtrise ;
* traçabilité ;
* qualité ;
* compatibilité future avec RAG.

## Décision CTO

PostgreSQL est retenu pour la base de connaissance MVP.

---

# ADR-013 - RAG futur

## Décision

Prévoir le RAG plus tard avec **pgvector** ou une base vectorielle dédiée.

## Pourquoi

Le RAG sera utile lorsque AgriAI aura beaucoup de contenus agricoles validés.

Mais ce n’est pas nécessaire de commencer par une architecture RAG complexe.

## Alternatives futures

* pgvector ;
* Pinecone ;
* Weaviate ;
* Qdrant ;
* Amazon OpenSearch vectoriel ;
* Amazon Bedrock Knowledge Bases.

## Décision CTO

Le MVP prépare le RAG, mais ne démarre pas avec un RAG complexe.

---

# ADR-014 - Observabilité

## Décision

Démarrer avec :

* Amazon CloudWatch Logs ;
* logs backend ;
* logs erreurs IA ;
* traces simples ;
* métriques produit ;
* OpenTelemetry progressivement.

## Pourquoi

AgriAI doit comprendre :

* les erreurs ;
* les lenteurs ;
* les échecs IA ;
* les Trust Scores faibles ;
* les langues utilisées ;
* l’usage photo ;
* l’usage voix.

## Alternatives étudiées

* Datadog ;
* Grafana Cloud ;
* Sentry ;
* observabilité custom uniquement.

## Décision CTO

Démarrer simple avec Amazon CloudWatch + structure compatible OpenTelemetry.

---

# ADR-015 - CI/CD

## Décision

Utiliser **GitHub Actions** avec déploiement vers AWS.

## Pourquoi

Le code sera hébergé sur GitHub.

GitHub Actions est suffisant pour :

* tests ;
* lint ;
* build mobile ;
* build backend ;
* build Docker ;
* déploiement App Runner ;
* contrôles qualité.

## Alternatives étudiées

* AWS CodePipeline ;
* GitLab CI ;
* CircleCI ;
* Jenkins.

## Décision CTO

GitHub Actions est retenu pour la CI/CD MVP.

---

# ADR-016 - Repository

## Décision

Utiliser **GitHub** comme repository principal.

## Pourquoi

GitHub est adapté pour :

* développement avec Codex ;
* Pull Requests ;
* issues ;
* documentation ;
* GitHub Actions ;
* collaboration future.

## Structure recommandée

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

## Décision CTO

GitHub est retenu comme base de développement.

---

# Architecture technique cible MVP

```text
Flutter Mobile App
        |
        | HTTPS
        v
AWS Amplify
        |
        |----------------------|
        |                      |
        v                      v
Amazon Cognito            Amazon S3
        |
        v
FastAPI Backend on AWS App Runner
        |
        v
Amazon RDS PostgreSQL
        |
        v
AI Orchestrator
        |
        |----------------------|----------------------|
        v                      v                      v
OpenAI LLM            OpenAI Vision            OpenAI Speech
        |
        v
Knowledge Layer in PostgreSQL
        |
        v
Trust Score Engine
```

---

# Règles d’architecture

## Règle 1

Le mobile ne doit jamais appeler directement OpenAI.

Tous les appels IA passent par le backend AgriAI.

---

## Règle 2

La logique métier ne doit pas être enfermée dans Amplify.

Amplify accélère le MVP, mais le cœur métier reste dans FastAPI.

---

## Règle 3

Les fichiers utilisateurs doivent être stockés dans S3 avec contrôle d’accès.

---

## Règle 4

Les diagnostics, recommandations et Trust Scores doivent être persistés dans PostgreSQL pour les utilisateurs connectés.

---

## Règle 5

Le mode découverte doit rester limité et ne doit pas conserver durablement les données personnelles sans consentement.

---

# Ce qu’on ne fait pas au MVP

Le MVP ne démarre pas avec :

* Kubernetes ;
* EKS ;
* microservices multiples ;
* modèle IA auto-hébergé ;
* RAG complexe ;
* base vectorielle dédiée ;
* marketplace ;
* paiement ;
* IoT ;
* drone ;
* satellite ;
* architecture événementielle complexe.

---

# Risques identifiés

## Risque 1 - Dépendance à OpenAI

Mitigation :

* isoler les appels IA dans un AI Orchestrator ;
* ne jamais appeler OpenAI directement depuis le mobile ;
* prévoir une interface fournisseur IA.

---

## Risque 2 - Qualité Darija voix

Mitigation :

* tester rapidement avec vrais audios ;
* afficher la transcription ;
* demander confirmation si ambigu ;
* prévoir alternative si qualité insuffisante.

---

## Risque 3 - Complexité AWS

Mitigation :

* utiliser Amplify pour accélérer ;
* éviter EKS au MVP ;
* éviter architecture trop distribuée ;
* garder FastAPI comme cœur métier clair.

---

## Risque 4 - Coût RDS

Mitigation :

* démarrer avec une petite instance ;
* surveiller les coûts ;
* éviter surdimensionnement ;
* ajuster selon traction réelle.

---

## Risque 5 - Mauvais diagnostic photo

Mitigation :

* Trust Score obligatoire ;
* demande de photo meilleure si besoin ;
* refus de certitude ;
* recommandations prudentes.

---

# Décision CTO globale

Pour le MVP AgriAI, la stack retenue est :

* **Flutter** pour le mobile ;
* **AWS Amplify** pour accélérer l’intégration mobile/cloud ;
* **Amazon Cognito** pour l’authentification ;
* **Amazon S3** pour les photos et audios ;
* **FastAPI** pour le backend métier ;
* **AWS App Runner** pour héberger le backend ;
* **Amazon RDS PostgreSQL** pour la base métier ;
* **OpenAI** pour LLM, vision et voix ;
* **Amazon CloudWatch** pour les premiers logs ;
* **GitHub + GitHub Actions** pour le développement et la CI/CD.

Cette stack est volontairement simple.

Elle permet de livrer vite, tester le marché, apprendre avec les premiers agriculteurs, puis renforcer progressivement l’architecture.

---

**Statut : APPROVED**
