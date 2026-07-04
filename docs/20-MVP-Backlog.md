---

title: MVP Backlog
version: 1.0
status: Draft
owner: CTO
approved_by: CEO
last_updated: 2026-06-29
------------------------

# AgriAI - MVP Backlog

## Objectif

Ce document définit le backlog MVP d’AgriAI.

Il sert de base pour préparer le travail de Codex.

Le backlog doit permettre de construire une première version utilisable par un agriculteur sur mobile.

---

# Principe de découpage

Le MVP est découpé en lots simples.

Chaque lot doit produire une valeur concrète.

Priorité absolue :

1. permettre à l’utilisateur de poser une question ;
2. permettre à l’utilisateur d’envoyer une photo ;
3. obtenir une réponse IA fiable ;
4. afficher un Trust Score ;
5. gérer le mode découverte ;
6. permettre la création de compte ;
7. sauvegarder l’historique pour les utilisateurs connectés.

---

# Vue globale des lots MVP

| Lot | Nom                        | Priorité |
| --- | -------------------------- | -------- |
| 1   | Initialisation projet      | P0       |
| 2   | Application mobile Flutter | P0       |
| 3   | Backend FastAPI            | P0       |
| 4   | Authentification Cognito   | P0       |
| 5   | Mode découverte            | P0       |
| 6   | Chat agricole IA           | P0       |
| 7   | Upload photo               | P0       |
| 8   | Diagnostic photo           | P0       |
| 9   | Trust Score                | P0       |
| 10  | Base de données PostgreSQL | P0       |
| 11  | Historique                 | P1       |
| 12  | Exploitation / cultures    | P1       |
| 13  | Voix / Darija              | P1       |
| 14  | Observabilité minimale     | P1       |
| 15  | Qualité / sécurité         | P1       |

---

# Lot 1 - Initialisation projet

## Objectif

Créer la structure de base du repository AgriAI.

## Tâches

### T1.1 - Créer le repository GitHub

Créer le repository principal :

```text
agri-ai
```

Structure cible :

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

### T1.2 - Ajouter les documents validés

Copier les documents `01` à `20` dans le dossier `docs/`.

### T1.3 - Créer README principal

Le README doit expliquer :

* vision courte du produit ;
* stack technique ;
* structure du projet ;
* comment lancer le mobile ;
* comment lancer le backend.

### T1.4 - Ajouter fichier `.gitignore`

Inclure :

* Python ;
* Flutter ;
* variables d’environnement ;
* fichiers temporaires ;
* secrets.

---

# Lot 2 - Application mobile Flutter

## Objectif

Créer la base mobile du MVP.

## Tâches

### T2.1 - Initialiser projet Flutter

Créer l’application Flutter dans :

```text
apps/mobile/
```

### T2.2 - Créer navigation de base

Écrans initiaux :

* écran d’accueil ;
* écran chat ;
* écran upload photo ;
* écran login/register ;
* écran historique ;
* écran profil.

### T2.3 - Créer design simple MVP

Le design doit être :

* simple ;
* mobile-first ;
* lisible ;
* utilisable sur terrain ;
* compatible français / Darija plus tard.

### T2.4 - Gérer configuration API

Prévoir une configuration pour appeler le backend FastAPI.

---

# Lot 3 - Backend FastAPI

## Objectif

Créer le backend API principal.

## Tâches

### T3.1 - Initialiser projet FastAPI

Créer le backend dans :

```text
services/backend/
```

### T3.2 - Créer structure modulaire

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

### T3.3 - Ajouter endpoint healthcheck

Créer :

```http
GET /health
```

Réponse attendue :

```json
{
  "status": "ok"
}
```

### T3.4 - Ajouter configuration environnement

Variables à prévoir :

* database URL ;
* OpenAI API key ;
* AWS region ;
* S3 bucket ;
* Cognito config ;
* environnement.

---

# Lot 4 - Authentification Cognito

## Objectif

Mettre en place l’authentification utilisateur.

## Tâches

### T4.1 - Configurer AWS Amplify Auth

Configurer Cognito via Amplify pour :

* inscription ;
* connexion ;
* déconnexion ;
* récupération utilisateur.

### T4.2 - Intégrer Auth dans Flutter

Écrans :

* register ;
* login ;
* logout ;
* profil utilisateur.

### T4.3 - Vérifier token côté backend

Le backend doit vérifier les tokens Cognito pour les endpoints protégés.

### T4.4 - Séparer endpoints publics et privés

Public :

* mode découverte ;
* healthcheck.

Privé :

* historique ;
* exploitation ;
* parcelles ;
* cultures ;
* diagnostics sauvegardés.

---

# Lot 5 - Mode découverte

## Objectif

Permettre l’usage sans compte.

## Tâches

### T5.1 - Créer session découverte

Permettre une session anonyme limitée.

### T5.2 - Créer endpoint question découverte

```http
POST /discovery/question
```

### T5.3 - Créer endpoint photo découverte

```http
POST /discovery/photo-diagnosis
```

### T5.4 - Limiter l’usage découverte

Prévoir une limite simple :

* nombre de questions ;
* nombre de photos ;
* invitation à créer un compte.

### T5.5 - Ne pas sauvegarder durablement sans consentement

Les données découverte ne doivent pas être conservées durablement.

---

# Lot 6 - Chat agricole IA

## Objectif

Permettre à l’utilisateur de poser une question agricole et recevoir une réponse fiable.

## Tâches

### T6.1 - Créer endpoint diagnostic texte

```http
POST /ai/diagnosis
```

Entrées :

* question ;
* langue ;
* culture optionnelle ;
* contexte optionnel ;
* mode découverte ou compte.

### T6.2 - Créer AI Orchestrator

Responsabilités :

* recevoir la demande ;
* construire le contexte ;
* appeler OpenAI ;
* appliquer les règles anti-hallucination ;
* produire une réponse structurée.

### T6.3 - Créer format de réponse standard

Réponse :

* résumé ;
* diagnostic ou hypothèses ;
* Trust Score ;
* explication ;
* recommandation ;
* questions complémentaires ;
* précautions.

### T6.4 - Support langue

Prévoir au minimum :

* français ;
* Darija ;
* arabe standard ;
* anglais.

---

# Lot 7 - Upload photo

## Objectif

Permettre l’envoi de photos depuis le mobile.

## Tâches

### T7.1 - Intégrer capture photo Flutter

L’utilisateur doit pouvoir :

* prendre une photo ;
* choisir une photo ;
* prévisualiser ;
* envoyer.

### T7.2 - Configurer stockage S3 via Amplify Storage

Les photos doivent être stockées dans S3.

### T7.3 - Envoyer métadonnées au backend

Métadonnées :

* utilisateur si connecté ;
* session découverte si anonyme ;
* date ;
* type média ;
* culture optionnelle ;
* conversation optionnelle.

### T7.4 - Protéger l’accès aux fichiers

Un utilisateur ne doit pas accéder aux médias d’un autre utilisateur.

---

# Lot 8 - Diagnostic photo

## Objectif

Analyser une photo agricole et produire un diagnostic prudent.

## Tâches

### T8.1 - Créer service Vision

Le backend doit appeler OpenAI Vision.

### T8.2 - Évaluer qualité photo

Critères :

* netteté ;
* lumière ;
* distance ;
* partie visible ;
* culture identifiable ;
* symptômes visibles.

### T8.3 - Produire analyse visuelle

Sortie :

* éléments observés ;
* symptômes possibles ;
* limites ;
* besoin d’une autre photo si nécessaire.

### T8.4 - Combiner photo + contexte

Le diagnostic doit combiner :

* photo ;
* question utilisateur ;
* culture ;
* région ;
* historique si disponible.

---

# Lot 9 - Trust Score

## Objectif

Afficher un niveau de confiance pour chaque diagnostic important.

## Tâches

### T9.1 - Implémenter calcul Trust Score MVP

Critères simples :

* qualité photo ;
* contexte fourni ;
* clarté des symptômes ;
* cohérence de la réponse ;
* qualité des sources/connaissances disponibles.

### T9.2 - Convertir score en niveau

Niveaux :

* élevé ;
* moyen ;
* faible ;
* insuffisant.

### T9.3 - Adapter le comportement IA

Selon score :

* élevé : réponse claire ;
* moyen : réponse prudente ;
* faible : hypothèses + questions ;
* insuffisant : refus de conclure.

### T9.4 - Afficher Trust Score dans Flutter

Affichage simple :

* score ;
* niveau ;
* explication courte.

---

# Lot 10 - Base de données PostgreSQL

## Objectif

Créer les premières tables métier.

## Tâches

### T10.1 - Configurer RDS PostgreSQL

Créer base PostgreSQL MVP.

### T10.2 - Configurer migrations

Utiliser un outil de migration.

### T10.3 - Créer tables principales

Tables MVP :

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

### T10.4 - Créer repositories backend

Créer couche d’accès aux données.

---

# Lot 11 - Historique

## Objectif

Permettre aux utilisateurs connectés de retrouver leurs échanges.

## Tâches

### T11.1 - Sauvegarder conversation

Sauvegarder messages utilisateur et réponses AgriAI.

### T11.2 - Sauvegarder diagnostic

Sauvegarder :

* diagnostic ;
* hypothèses ;
* recommandation ;
* Trust Score ;
* média associé.

### T11.3 - Créer endpoints historique

```http
GET /history/conversations
GET /history/diagnoses
```

### T11.4 - Créer écran historique mobile

Afficher :

* anciennes conversations ;
* anciens diagnostics ;
* date ;
* culture associée ;
* Trust Score.

---

# Lot 12 - Exploitation / cultures

## Objectif

Permettre à l’utilisateur connecté de déclarer son exploitation et ses cultures.

## Tâches

### T12.1 - Créer endpoints farms

```http
POST /farms
GET /farms
PATCH /farms/{farm_id}
DELETE /farms/{farm_id}
```

### T12.2 - Créer endpoints fields

```http
POST /farms/{farm_id}/fields
GET /farms/{farm_id}/fields
```

### T12.3 - Créer endpoints crops

```http
POST /fields/{field_id}/crops
GET /farms/{farm_id}/crops
```

### T12.4 - Créer écrans mobile correspondants

Écrans simples :

* mon exploitation ;
* mes parcelles ;
* mes cultures.

---

# Lot 13 - Voix / Darija

## Objectif

Permettre une première expérience vocale simple.

## Tâches

### T13.1 - Enregistrer audio dans Flutter

L’utilisateur peut enregistrer une question vocale.

### T13.2 - Stocker audio dans S3

Audio lié à :

* utilisateur ;
* conversation ;
* diagnostic éventuel.

### T13.3 - Transcrire audio

Backend appelle service speech OpenAI.

### T13.4 - Afficher transcription

L’utilisateur doit voir ce qui a été compris.

### T13.5 - Demander confirmation si ambigu

Si confiance faible :

* afficher transcription ;
* demander confirmation avant diagnostic.

### T13.6 - Répondre en Darija simple

Première réponse texte en Darija.

Réponse vocale optionnelle si simple à intégrer.

---

# Lot 14 - Observabilité minimale

## Objectif

Suivre le comportement du MVP.

## Tâches

### T14.1 - Logs backend

Tracer :

* erreurs ;
* appels IA ;
* erreurs IA ;
* temps de réponse.

### T14.2 - Logs Trust Score

Tracer :

* score ;
* niveau ;
* raison score faible.

### T14.3 - Métriques produit MVP

Suivre :

* nombre de questions ;
* nombre de photos ;
* nombre de diagnostics ;
* mode découverte ;
* comptes créés ;
* langues utilisées.

### T14.4 - CloudWatch

Envoyer les logs backend vers Amazon CloudWatch.

---

# Lot 15 - Qualité / sécurité

## Objectif

Garantir une base saine avant premier test utilisateur.

## Tâches

### T15.1 - Sécuriser secrets

Aucun secret dans Git.

Variables via environnement sécurisé.

### T15.2 - Validation des entrées API

Toutes les entrées API doivent être validées.

### T15.3 - Tests backend minimum

Tests :

* healthcheck ;
* auth middleware ;
* endpoint diagnostic ;
* Trust Score ;
* repositories principaux.

### T15.4 - Tests mobile minimum

Tests :

* navigation ;
* login ;
* question texte ;
* upload photo ;
* affichage réponse.

### T15.5 - Règles anti-hallucination dans prompts

Les prompts système doivent intégrer :

* prudence ;
* Trust Score ;
* refus de certitude ;
* questions complémentaires ;
* pas d’invention.

---

# Priorité Sprint 1

Le premier sprint doit se concentrer sur :

1. structure repository ;
2. backend FastAPI minimal ;
3. app Flutter minimale ;
4. connexion mobile vers backend ;
5. endpoint question texte ;
6. premier appel OpenAI ;
7. format réponse structuré ;
8. Trust Score MVP simple.

---

# Définition de Done MVP

Le MVP est considéré prêt pour test initial si :

* l’utilisateur peut ouvrir l’application mobile ;
* il peut poser une question agricole ;
* il peut envoyer une photo ;
* il reçoit une réponse claire ;
* il voit un Trust Score ;
* il peut créer un compte ;
* son historique est sauvegardé ;
* il peut déclarer au moins une culture ;
* les données sont protégées ;
* les erreurs principales sont loguées.

---

# Hors périmètre MVP

Ne pas développer maintenant :

* paiement ;
* abonnement ;
* marketplace ;
* fournisseurs ;
* prix produits ;
* IoT ;
* satellite ;
* drone ;
* irrigation automatique ;
* pilotage d’équipement ;
* portail coopérative ;
* dashboard avancé ;
* modèle IA agricole propriétaire.

---

# Décision CTO

Le backlog MVP doit rester orienté valeur.

Codex ne doit pas commencer par des sujets secondaires.

La priorité est de livrer rapidement le cœur d’AgriAI :

* question ;
* photo ;
* diagnostic ;
* recommandation ;
* Trust Score ;
* historique ;
* mobile-first.

---

**Statut : APPROVED**
