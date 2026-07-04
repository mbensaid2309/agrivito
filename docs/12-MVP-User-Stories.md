---

title: MVP User Stories
version: 1.0
status: Approved
owner: CTO
approved_by: CEO
last_updated: 2026-06-28
------------------------

# AgriAI - MVP User Stories

## Objectif

Ce document transforme le périmètre MVP en User Stories.

Chaque User Story doit permettre de préparer le développement futur avec Codex.

---

# Epic 1 - Accès utilisateur

## US-000 - Mode découverte sans compte

En tant qu'agriculteur,
je veux pouvoir tester AgriAI sans créer de compte,
afin de découvrir rapidement la valeur du produit.

### Critères d'acceptation

* L'utilisateur peut poser une question sans compte.
* L'utilisateur peut envoyer une photo sans compte.
* L'utilisation sans compte est limitée.
* L'utilisateur est invité à créer un compte pour sauvegarder son historique.
* Aucune donnée personnelle durable n'est conservée sans consentement.

---

## US-001 - Création de compte optionnelle

En tant qu'agriculteur,
je veux créer un compte lorsque je souhaite sauvegarder mes données,
afin de retrouver mon exploitation, mes cultures, mes conversations et mes diagnostics.

### Critères d'acceptation

* La création de compte n'est pas obligatoire pour découvrir AgriAI.
* L'utilisateur peut créer un compte.
* L'utilisateur peut se connecter.
* L'utilisateur peut se déconnecter.
* Les données utilisateur sont protégées.
* L'historique complet nécessite un compte.

---

## US-002 - Profil agriculteur

En tant qu'agriculteur,
je veux renseigner mon profil,
afin qu'AgriAI adapte ses réponses à mon contexte.

### Critères d'acceptation

* L'utilisateur peut renseigner son nom.
* L'utilisateur peut renseigner sa région.
* L'utilisateur peut choisir sa langue.
* L'utilisateur peut modifier son profil.
* Le profil nécessite un compte utilisateur.

---

# Epic 2 - Exploitation agricole

## US-003 - Création d'exploitation

En tant qu'agriculteur,
je veux créer mon exploitation,
afin qu'AgriAI comprenne mon environnement de travail.

### Critères d'acceptation

* L'utilisateur peut créer une exploitation.
* L'utilisateur peut renseigner le nom de l'exploitation.
* L'utilisateur peut renseigner la localisation.
* L'utilisateur peut modifier les informations.
* La création d'exploitation nécessite un compte.

---

## US-004 - Gestion des parcelles

En tant qu'agriculteur,
je veux ajouter mes parcelles,
afin de relier les diagnostics à une zone précise.

### Critères d'acceptation

* L'utilisateur peut créer une parcelle.
* L'utilisateur peut indiquer une surface approximative.
* L'utilisateur peut associer une culture à une parcelle.
* L'utilisateur peut modifier ou supprimer une parcelle.
* La gestion des parcelles nécessite un compte.

---

## US-005 - Gestion des cultures

En tant qu'agriculteur,
je veux déclarer plusieurs cultures,
afin qu'AgriAI puisse adapter ses recommandations.

### Critères d'acceptation

* L'utilisateur peut ajouter une ou plusieurs cultures.
* Une culture peut être liée à une parcelle.
* AgriAI ne limite pas l'utilisateur à une seule culture.
* L'utilisateur peut modifier ou supprimer une culture.
* La gestion complète des cultures nécessite un compte.

---

# Epic 3 - Chat IA agricole

## US-006 - Poser une question

En tant qu'agriculteur,
je veux poser une question à AgriAI,
afin d'obtenir une réponse agricole utile.

### Critères d'acceptation

* L'utilisateur peut écrire une question.
* L'utilisateur peut poser une question en mode découverte.
* AgriAI répond en langage clair.
* La réponse est liée au contexte agricole.
* La réponse est sauvegardée dans l'historique uniquement si l'utilisateur possède un compte.

---

## US-007 - Réponse fiable

En tant qu'agriculteur,
je veux recevoir une réponse fiable,
afin de pouvoir prendre une meilleure décision.

### Critères d'acceptation

* AgriAI ne doit pas inventer une réponse.
* AgriAI doit indiquer son niveau de confiance lorsque nécessaire.
* AgriAI doit poser des questions si le contexte est insuffisant.
* AgriAI doit présenter plusieurs hypothèses si le diagnostic n'est pas certain.

---

# Epic 4 - Diagnostic par photo

## US-008 - Upload de photo

En tant qu'agriculteur,
je veux envoyer une photo d'un problème agricole,
afin qu'AgriAI puisse l'analyser.

### Critères d'acceptation

* L'utilisateur peut envoyer une photo depuis son smartphone.
* L'utilisateur peut envoyer une photo en mode découverte.
* La photo est liée à une conversation.
* La photo est stockée uniquement si l'utilisateur possède un compte.
* La photo peut être retrouvée dans l'historique uniquement si l'utilisateur possède un compte.

---

## US-009 - Analyse de photo

En tant qu'agriculteur,
je veux qu'AgriAI analyse ma photo,
afin d'identifier les symptômes visibles.

### Critères d'acceptation

* AgriAI identifie les éléments visibles.
* AgriAI peut détecter des symptômes possibles.
* AgriAI ne donne pas de conclusion forte si l'image est insuffisante.
* AgriAI peut demander une meilleure photo.

---

## US-010 - Diagnostic agricole

En tant qu'agriculteur,
je veux recevoir un diagnostic probable,
afin de comprendre le problème de ma culture.

### Critères d'acceptation

* AgriAI propose un diagnostic si le niveau de confiance est suffisant.
* AgriAI explique pourquoi ce diagnostic est proposé.
* AgriAI affiche un Trust Score.
* AgriAI peut proposer plusieurs hypothèses.

---

# Epic 5 - Recommandations

## US-011 - Recommandation simple

En tant qu'agriculteur,
je veux recevoir une recommandation claire,
afin de savoir quoi faire ensuite.

### Critères d'acceptation

* La recommandation est simple à comprendre.
* La recommandation est adaptée au contexte.
* La recommandation ne remplace pas la décision de l'agriculteur.
* La recommandation indique les précautions nécessaires si besoin.

---

## US-012 - Questions complémentaires

En tant qu'agriculteur,
je veux qu'AgriAI me pose des questions si nécessaire,
afin d'améliorer la fiabilité de la réponse.

### Critères d'acceptation

* AgriAI demande plus d'informations si le contexte est insuffisant.
* Les questions sont simples.
* Les questions sont utiles pour améliorer le diagnostic.
* AgriAI ne force pas une réponse incertaine.

---

# Epic 6 - Trust Score

## US-013 - Affichage du Trust Score

En tant qu'agriculteur,
je veux voir le niveau de confiance d'AgriAI,
afin de comprendre la fiabilité de la réponse.

### Critères d'acceptation

* Le Trust Score est affiché pour les diagnostics importants.
* Le Trust Score est compréhensible.
* Un score faible déclenche une réponse prudente.
* Un score faible peut déclencher des questions complémentaires.

---

## US-014 - Réponse prudente

En tant qu'agriculteur,
je veux qu'AgriAI reconnaisse ses limites,
afin d'éviter les mauvaises recommandations.

### Critères d'acceptation

* AgriAI peut dire qu'il n'a pas assez d'informations.
* AgriAI peut recommander une vérification terrain.
* AgriAI peut demander l'avis d'un spécialiste si nécessaire.
* AgriAI ne doit jamais présenter une hypothèse faible comme une certitude.

---

# Epic 7 - Historique

## US-015 - Historique des conversations

En tant qu'agriculteur,
je veux consulter mes anciennes conversations,
afin de retrouver les conseils reçus.

### Critères d'acceptation

* Les conversations sont sauvegardées pour les utilisateurs avec compte.
* L'utilisateur peut les consulter.
* Les conversations sont liées à l'utilisateur.
* Les données restent privées.
* L'historique complet nécessite un compte.

---

## US-016 - Historique des diagnostics

En tant qu'agriculteur,
je veux consulter mes anciens diagnostics,
afin de suivre l'évolution de mes cultures.

### Critères d'acceptation

* Les diagnostics sont sauvegardés pour les utilisateurs avec compte.
* Un diagnostic peut être lié à une culture.
* Un diagnostic peut être lié à une parcelle.
* L'utilisateur peut consulter l'historique par date.
* L'historique complet nécessite un compte.

---

# Epic 8 - Mobile First

## US-017 - Expérience mobile terrain

En tant qu'agriculteur,
je veux utiliser AgriAI facilement depuis mon téléphone,
afin de l'utiliser directement sur le terrain.

### Critères d'acceptation

* L'interface est optimisée pour mobile.
* L'envoi de photo est simple.
* Les réponses sont lisibles sur petit écran.
* Les actions principales sont accessibles rapidement.

---

# Hors périmètre MVP

Les éléments suivants ne font pas partie du MVP :

* paiement ;
* marketplace ;
* comparaison de prix ;
* IoT ;
* satellite ;
* drone ;
* automatisation d'irrigation ;
* pilotage d'équipements ;
* portail web professionnel ;
* gestion coopérative ;
* tableaux de bord avancés.

---

# Priorité de développement MVP

| Priorité | User Story                            |
| -------- | ------------------------------------- |
| P1       | US-000 Mode découverte sans compte    |
| P1       | US-001 Création de compte optionnelle |
| P1       | US-003 Création d'exploitation        |
| P1       | US-005 Gestion des cultures           |
| P1       | US-006 Poser une question             |
| P1       | US-008 Upload de photo                |
| P1       | US-009 Analyse de photo               |
| P1       | US-010 Diagnostic agricole            |
| P1       | US-013 Trust Score                    |
| P2       | US-004 Gestion des parcelles          |
| P2       | US-011 Recommandation simple          |
| P2       | US-012 Questions complémentaires      |
| P2       | US-015 Historique conversations       |
| P2       | US-016 Historique diagnostics         |
| P3       | US-002 Profil agriculteur             |
| P3       | US-017 Expérience mobile terrain      |

---

# Décision CTO

Le MVP doit réduire la friction d'entrée tout en protégeant la fiabilité.

AgriAI doit permettre une découverte rapide sans compte, mais réserver l'historique complet, l'exploitation et le suivi sérieux aux utilisateurs connectés.

La priorité n'est pas d'avoir beaucoup de fonctionnalités.

La priorité est de fournir peu de fonctionnalités, mais fiables, utiles et simples à utiliser.

---

**Statut : APPROVED**
