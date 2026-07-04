---

title: MVP Technical Architecture
version: 1.0
status: Draft
owner: CTO
approved_by: CEO
last_updated: 2026-06-28
------------------------

# AgriAI - MVP Technical Architecture

## Objectif

Ce document définit l’architecture technique cible du MVP AgriAI.

Il traduit les besoins produit, IA, données et API en architecture technique.

Les choix de technologies précis seront validés ensuite dans des ADR dédiées.

---

# Principe général

L’architecture MVP doit être :

* simple ;
* robuste ;
* mobile-first ;
* sécurisée ;
* évolutive ;
* compatible avec l’IA ;
* compatible avec la voix ;
* compatible avec la Darija ;
* facile à développer rapidement ;
* facile à maintenir.

---

# Vue globale

```text
Mobile App
   |
   | HTTPS
   v
Backend API
   |
   |--------------------|
   |                    |
   v                    v
Business Database     Media Storage
   |
   v
AI Orchestrator
   |
   |--------------------|--------------------|
   v                    v                    v
LLM Provider        Vision AI          Speech Services
   |
   v
Knowledge Layer
   |
   v
Trust Score Engine
```

---

# Composants principaux

## 1. Mobile App

L’application mobile est le canal principal du MVP.

Elle permet à l’agriculteur de :

* poser une question ;
* envoyer une photo ;
* envoyer une question vocale ;
* recevoir une réponse ;
* consulter son historique ;
* gérer son exploitation ;
* gérer ses cultures.

### Responsabilités

* interface utilisateur ;
* capture photo ;
* enregistrement vocal ;
* affichage du diagnostic ;
* affichage du Trust Score ;
* expérience simple terrain ;
* gestion du mode découverte ;
* gestion du mode compte.

---

## 2. Backend API

Le backend API est le point d’entrée principal du système.

### Responsabilités

* authentification ;
* gestion utilisateur ;
* gestion exploitation ;
* gestion parcelles ;
* gestion cultures ;
* gestion conversations ;
* gestion médias ;
* exposition des API mobiles ;
* sécurité ;
* contrôle d’accès ;
* orchestration des demandes IA.

Le backend ne doit pas contenir toute l’intelligence IA directement.

Il doit appeler un module d’orchestration IA.

---

## 3. AI Orchestrator

L’AI Orchestrator coordonne les traitements IA.

### Responsabilités

* comprendre la demande ;
* récupérer le contexte agricole ;
* appeler le moteur LLM ;
* appeler le module Vision si photo ;
* appeler le module Speech si voix ;
* interroger la base de connaissance ;
* calculer ou récupérer le Trust Score ;
* produire une réponse structurée ;
* décider si des questions complémentaires sont nécessaires.

---

## 4. LLM Provider

Le LLM Provider fournit les capacités de raisonnement et de génération de réponse.

### Responsabilités

* comprendre les questions agricoles ;
* générer des explications ;
* proposer des hypothèses ;
* formuler des recommandations ;
* adapter la réponse à la langue de l’utilisateur.

### Règle

Le LLM ne doit pas répondre seul sans garde-fous.

Il doit être encadré par :

* le contexte agricole ;
* la base de connaissance ;
* le Trust Score ;
* les règles anti-hallucination ;
* les règles de prudence.

---

## 5. Vision AI

Le module Vision AI analyse les photos envoyées par l’utilisateur.

### Responsabilités

* évaluer la qualité de la photo ;
* détecter les symptômes visibles ;
* identifier les éléments agricoles pertinents ;
* produire une analyse visuelle ;
* signaler si l’image est insuffisante.

### Règle

Une mauvaise photo doit déclencher une demande de nouvelle photo.

---

## 6. Speech Services

Les services Speech permettent l’usage vocal.

### Responsabilités

* transcrire la voix en texte ;
* détecter la langue ;
* gérer la Darija autant que possible ;
* générer éventuellement une réponse vocale courte ;
* fournir un niveau de confiance de transcription.

### Règle

Si la transcription est ambiguë, AgriAI doit demander confirmation.

---

## 7. Business Database

La base métier stocke les données principales.

### Données stockées

* utilisateurs ;
* profils ;
* préférences linguistiques ;
* exploitations ;
* parcelles ;
* cultures ;
* conversations ;
* messages ;
* diagnostics ;
* recommandations ;
* Trust Scores ;
* questions complémentaires.

### Règle

La base doit permettre de tracer chaque diagnostic et chaque recommandation.

---

## 8. Media Storage

Le stockage média contient les fichiers envoyés par l’utilisateur.

### Données stockées

* photos ;
* fichiers audio ;
* métadonnées ;
* liens vers conversations ;
* liens vers diagnostics.

### Règle

Les médias doivent être protégés et accessibles uniquement par l’utilisateur autorisé.

---

## 9. Knowledge Layer

La couche de connaissance contient les informations agricoles fiables.

Dans le MVP, elle peut commencer simplement.

### Responsabilités

* centraliser les connaissances validées ;
* fournir du contexte au moteur IA ;
* préparer le futur RAG ;
* éviter les réponses basées uniquement sur la mémoire du modèle.

### Sources possibles

* fiches cultures ;
* fiches maladies ;
* guides agronomiques ;
* documents validés ;
* contenus internes AgriAI.

---

## 10. Trust Score Engine

Le Trust Score Engine évalue le niveau de confiance.

### Responsabilités

* évaluer la qualité des informations ;
* prendre en compte la photo ;
* prendre en compte le contexte ;
* prendre en compte la qualité de la source ;
* produire un score ;
* décider du comportement de réponse.

### Comportements possibles

* réponse claire ;
* réponse prudente ;
* hypothèses ;
* questions complémentaires ;
* refus de conclure.

---

# Flux principal : question texte

```text
Utilisateur
  -> Mobile App
  -> Backend API
  -> AI Orchestrator
  -> Contexte agricole
  -> Knowledge Layer
  -> LLM Provider
  -> Trust Score Engine
  -> Réponse
  -> Historique
```

---

# Flux principal : photo diagnostic

```text
Utilisateur envoie photo
  -> Mobile App
  -> Media Storage
  -> Backend API
  -> AI Orchestrator
  -> Vision AI
  -> Contexte agricole
  -> Knowledge Layer
  -> LLM Provider
  -> Trust Score Engine
  -> Diagnostic / Questions / Recommandation
  -> Historique
```

---

# Flux principal : question vocale

```text
Utilisateur parle
  -> Mobile App
  -> Media Storage
  -> Speech Services
  -> Transcription
  -> Backend API
  -> AI Orchestrator
  -> LLM Provider
  -> Trust Score Engine
  -> Réponse texte ou voix
  -> Historique
```

---

# Mode découverte

Le mode découverte permet d’utiliser AgriAI sans compte.

### Capacités

* poser une question ;
* envoyer une photo ;
* recevoir une réponse limitée ;
* recevoir une invitation à créer un compte.

### Restrictions

* usage limité ;
* historique non durable ;
* données personnelles non conservées durablement ;
* pas de gestion complète de l’exploitation ;
* pas de suivi long terme.

---

# Mode compte

Le mode compte permet une expérience complète.

### Capacités

* profil utilisateur ;
* préférences linguistiques ;
* exploitation ;
* parcelles ;
* cultures ;
* historique ;
* diagnostics sauvegardés ;
* recommandations sauvegardées.

---

# Sécurité

L’architecture doit garantir :

* authentification des utilisateurs ;
* contrôle d’accès strict ;
* séparation des données utilisateur ;
* protection des médias ;
* limitation du mode découverte ;
* journalisation des actions importantes ;
* protection des clés API IA ;
* aucune exposition directe des services IA au mobile.

---

# Observabilité

Même dans le MVP, il faut prévoir un minimum d’observabilité.

### À suivre

* erreurs backend ;
* erreurs IA ;
* temps de réponse ;
* volume de questions ;
* volume de photos ;
* taux de Trust Score faible ;
* langues utilisées ;
* usage du mode découverte ;
* conversion vers compte.

---

# Scalabilité MVP

Le MVP ne doit pas être surdimensionné.

Mais il doit pouvoir évoluer simplement.

### Priorités

* démarrer simple ;
* éviter les microservices inutiles ;
* garder une séparation logique claire ;
* pouvoir extraire certains modules plus tard si nécessaire.

---

# Architecture recommandée pour le MVP

Pour le MVP, l’architecture recommandée est une architecture modulaire simple :

```text
1 application mobile
1 backend API modulaire
1 base de données métier
1 stockage média
1 module d’orchestration IA
1 couche de connaissance simple
1 intégration LLM
1 intégration Vision
1 intégration Speech
```

---

# Ce qu’on évite dans le MVP

L’architecture MVP ne doit pas démarrer avec :

* trop de microservices ;
* Kubernetes obligatoire ;
* architecture événementielle complexe ;
* plusieurs bases de données inutiles ;
* pipelines ML complexes ;
* infrastructure IoT ;
* traitement satellite ;
* marketplace ;
* système de paiement ;
* portail coopérative ;
* moteur d’automatisation d’équipements.

---

# Évolutions futures

L’architecture doit permettre plus tard :

* application web ;
* portail pro ;
* RAG avancé ;
* base vectorielle ;
* marketplace ;
* notifications proactives ;
* alertes météo ;
* intégrations IoT ;
* données satellite ;
* tableaux de bord ;
* multi-exploitations avancé ;
* coopératives ;
* API partenaires.

---

# Décision CTO

Le MVP AgriAI doit être construit avec une architecture simple et modulaire.

La priorité n’est pas de créer une architecture impressionnante.

La priorité est de livrer vite une première version fiable qui permet à l’agriculteur de :

* poser une question ;
* envoyer une photo ;
* parler en Darija ;
* recevoir un diagnostic prudent ;
* obtenir une recommandation utile ;
* comprendre le niveau de confiance ;
* sauvegarder son historique avec un compte.

---

**Statut :APPROVED**
