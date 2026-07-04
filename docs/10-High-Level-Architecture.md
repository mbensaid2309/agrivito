---

title: High Level Architecture
version: 1.0
status: Approved
owner: CTO
approved_by: CEO
last_updated: 2026-06-28
------------------------

# AgriAI - High Level Architecture

## Objectif

Ce document définit l'architecture logique du MVP AgriAI.

Il ne valide aucun choix technique définitif.

Les choix de technologies seront faits plus tard dans des ADR dédiés.

---

# Principe d'architecture

AgriAI doit être conçu comme une plateforme modulaire.

Chaque bloc doit avoir une responsabilité claire.

Le MVP doit rester simple, fiable et évolutif.

L'architecture doit permettre une évolution future vers :

* Copilote ;
* recommandations proactives ;
* données météo ;
* produits et matériels ;
* IoT ;
* pilotage d'équipements.

---

# Décision d'interface

AgriAI adopte une approche **Mobile First**.

Le canal principal du MVP est l'application mobile, car la majorité des agriculteurs utiliseront AgriAI directement depuis leur smartphone sur le terrain.

L'application web reste prévue, mais elle n'est pas prioritaire dans le MVP.

## Priorité des interfaces

| Interface | Priorité | Usage                                             |
| --------- | -------- | ------------------------------------------------- |
| Mobile    | MVP      | Usage terrain, photo, question rapide, diagnostic |
| Web       | V2       | Consultation, gestion avancée, tableau de bord    |
| Web Pro   | Vision   | Coopératives, conseillers, grandes exploitations  |

---

# Vue globale

```text
Agriculteur
    ↓
Application Mobile First
    ↓
Backend AgriAI
    ↓
Moteur IA
    ↓
Modules métier
    ↓
Bases de données
    ↓
Historique / Connaissances / Médias
```

---

# Blocs principaux

## 1. Application Mobile

Responsabilité :

* permettre à l'agriculteur d'utiliser AgriAI sur le terrain ;
* poser une question ;
* envoyer une photo ;
* consulter les réponses ;
* consulter l'historique ;
* gérer son exploitation ;
* gérer ses parcelles ;
* gérer ses cultures.

Le mobile est prioritaire pour le MVP.

---

## 2. Application Web Future

Responsabilité future :

* consultation avancée ;
* gestion plus confortable de l'exploitation ;
* tableaux de bord ;
* accès professionnel ;
* gestion multi-exploitations.

L'application web n'est pas prioritaire dans le MVP.

---

## 3. Backend AgriAI

Responsabilité :

* gérer les utilisateurs ;
* gérer les exploitations ;
* gérer les parcelles ;
* gérer les cultures ;
* gérer les conversations ;
* gérer les diagnostics ;
* appeler le moteur IA ;
* stocker les résultats ;
* exposer les services aux interfaces mobile et web futures.

Le backend est le cœur applicatif du MVP.

---

## 4. Moteur IA

Responsabilité :

* comprendre les questions ;
* analyser les photos ;
* générer des explications ;
* proposer des recommandations ;
* produire un Trust Score ;
* décider s'il faut répondre ou demander plus d'informations.

Le moteur IA ne doit jamais répondre sans contrôle de fiabilité.

---

## 5. Module Vision

Responsabilité :

* analyser les images envoyées ;
* détecter les symptômes visibles ;
* identifier les éléments utiles ;
* fournir des indices au moteur IA.

Exemples :

* feuille jaune ;
* tache noire ;
* fruit abîmé ;
* insecte visible ;
* stress hydrique apparent.

---

## 6. Module Knowledge

Responsabilité :

* fournir les connaissances agronomiques ;
* rechercher dans la base documentaire ;
* aider le moteur IA à produire des réponses fiables.

Ce module servira de base au futur RAG.

---

## 7. Module Trust Score

Responsabilité :

* évaluer la fiabilité d'une réponse ;
* indiquer le niveau de confiance ;
* déclencher des questions complémentaires si nécessaire ;
* empêcher les réponses trop affirmatives en cas de doute.

Règle :

Si le niveau de confiance est insuffisant, AgriAI doit demander plus d'informations.

---

## 8. Module Exploitation

Responsabilité :

* gérer les exploitations ;
* gérer les parcelles ;
* gérer les cultures ;
* relier les diagnostics à une culture ou une parcelle.

---

## 9. Module Historique

Responsabilité :

* conserver les conversations ;
* conserver les diagnostics ;
* permettre le suivi dans le temps ;
* préparer les futures capacités d'apprentissage.

---

## 10. Stockage Médias

Responsabilité :

* stocker les photos envoyées ;
* relier chaque photo à une conversation ou un diagnostic ;
* permettre une consultation future.

---

## 11. Base de données métier

Responsabilité :

* stocker les utilisateurs ;
* stocker les exploitations ;
* stocker les parcelles ;
* stocker les cultures ;
* stocker les diagnostics ;
* stocker les conversations.

Le choix technique de la base de données n'est pas encore décidé.

---

# Flux principal du MVP

## Diagnostic par photo

```text
Agriculteur
  ↓
Envoie une photo + question depuis mobile
  ↓
Application Mobile
  ↓
Backend AgriAI
  ↓
Module Vision
  ↓
Moteur IA
  ↓
Module Knowledge
  ↓
Module Trust Score
  ↓
Réponse / Questions complémentaires
  ↓
Historique
```

---

# Règles clés

## Règle 1

Le moteur IA ne doit jamais contourner le Trust Score.

---

## Règle 2

Une réponse incertaine doit être présentée comme incertaine.

---

## Règle 3

AgriAI doit toujours pouvoir demander plus d'informations.

---

## Règle 4

Les données de l'exploitation doivent être séparées des données IA.

---

## Règle 5

Le MVP doit rester simple, mais évolutif.

---

## Règle 6

L'expérience mobile est prioritaire dans toutes les décisions MVP.

---

# Exclusions MVP

Cette architecture ne couvre pas encore :

* IoT ;
* drones ;
* satellite ;
* marketplace ;
* paiement ;
* coopératives ;
* pilotage d'équipements ;
* automatisation d'irrigation ;
* portail web professionnel.

Ces éléments seront ajoutés plus tard.

---

# Décision CTO

L'architecture du MVP doit être pensée autour de la fiabilité et de l'usage terrain.

Le bloc le plus critique n'est pas le chat.

Le bloc le plus critique est le **Trust Score**.

Le canal prioritaire n'est pas le web.

Le canal prioritaire est le **mobile**.

Sans confiance et sans usage simple sur le terrain, AgriAI ne peut pas réussir.

---

**Statut : APPROVED**
