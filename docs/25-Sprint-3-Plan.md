---

title: Sprint 3 Plan
version: 1.0
status: Approved
owner: CTO
approved_by: CEO
last_updated: 2026-07-11
------------------------

# Agrivito - Sprint 3 Plan

## Objectif

Ce document définit le troisième sprint de développement du MVP Agrivito.

Le Sprint 1 a livré le socle technique initial :

* repository structuré ;
* backend FastAPI ;
* endpoint `/health` ;
* application Flutter initiale ;
* CI GitHub Actions ;
* structure IA ;
* Trust Score mocké.

Le Sprint 2 a livré le socle d’accès et de découverte :

* mode découverte sans compte ;
* session découverte locale ;
* limite de 3 questions ;
* endpoint `POST /discovery/question` ;
* réponse agricole mockée avec Trust Score ;
* Login / Register préparés ;
* préparation Cognito / Amplify sans intégration réelle.

Le Sprint 3 doit maintenant poser les bases métier agricoles.

---

# Nom du Sprint

```text
Sprint 3 - Farm, Field and Crop Foundation
```

---

# Objectif du Sprint 3

À la fin du Sprint 3, Agrivito doit permettre de modéliser le contexte agricole de base d’un utilisateur :

* profil agricole utilisateur ;
* exploitation agricole ;
* parcelles ;
* cultures ;
* association culture / parcelle ;
* données nécessaires pour contextualiser les futurs diagnostics IA.

Le Sprint 3 prépare Agrivito à répondre de manière plus pertinente aux questions agricoles en utilisant le contexte réel de l’utilisateur.

---

# Pourquoi ce sprint est important

Agrivito ne doit pas être un simple chatbot agricole générique.

Pour produire des recommandations fiables, Agrivito doit connaître le contexte agricole :

* type d’utilisateur ;
* pays / région ;
* exploitation ;
* parcelles ;
* cultures cultivées ;
* surface ;
* localisation approximative ;
* stade de culture ;
* mode de production.

Sans ce contexte, les diagnostics restent trop généraux.

Le Sprint 3 ne cherche pas encore à produire une IA réelle, mais il prépare les données métier indispensables pour les futurs diagnostics.

---

# Périmètre Sprint 3

Le Sprint 3 couvre uniquement les fondations métier suivantes :

## 1. Profil agricole utilisateur

Créer une structure permettant de représenter le profil agricole de l’utilisateur.

Informations attendues :

* identifiant utilisateur ;
* nom ou pseudo ;
* type d’utilisateur ;
* pays ;
* région ;
* langue préférée ;
* mode découverte ou compte préparé ;
* date de création.

Types d’utilisateur possibles pour le MVP :

```text
farmer
advisor
cooperative_member
unknown
```

Pour le Sprint 3, l’authentification réelle n’est pas obligatoire. Le profil peut rester local côté mobile et mocké côté backend.

---

## 2. Exploitation agricole

Créer une structure permettant de représenter une exploitation agricole.

Informations attendues :

* identifiant exploitation ;
* identifiant utilisateur ;
* nom de l’exploitation ;
* pays ;
* région ;
* commune ou localité ;
* surface totale optionnelle ;
* unité de surface ;
* date de création.

Un utilisateur peut avoir une ou plusieurs exploitations, mais pour le MVP il faut garder une approche simple.

---

## 3. Parcelles

Créer une structure permettant de représenter une parcelle agricole.

Informations attendues :

* identifiant parcelle ;
* identifiant exploitation ;
* nom de la parcelle ;
* surface ;
* unité de surface ;
* type de sol optionnel ;
* accès à l’eau optionnel ;
* irrigation optionnelle ;
* notes optionnelles ;
* date de création.

Types d’irrigation possibles :

```text
none
drip
sprinkler
flood
manual
unknown
```

Types d’accès à l’eau possibles :

```text
yes
no
seasonal
unknown
```

---

## 4. Cultures

Créer une structure permettant de représenter une culture.

Informations attendues :

* identifiant culture ;
* nom de culture ;
* catégorie ;
* variété optionnelle ;
* saison optionnelle ;
* date de plantation optionnelle ;
* stade de culture optionnel ;
* notes optionnelles.

Exemples de cultures MVP :

```text
tomate
pomme de terre
olivier
blé
maïs
oignon
fraise
agrumes
```

Catégories possibles :

```text
vegetable
fruit_tree
cereal
legume
industrial_crop
other
unknown
```

Stades de culture possibles :

```text
seedling
vegetative
flowering
fruiting
harvest
post_harvest
unknown
```

---

## 5. Association parcelle / culture

Une parcelle peut avoir une culture principale active.

Pour le Sprint 3, garder une approche simple :

* une parcelle peut être associée à une culture principale ;
* l’historique complet des rotations n’est pas encore obligatoire ;
* les rotations culturales avancées sont hors périmètre.

Informations attendues :

* identifiant association ;
* identifiant parcelle ;
* identifiant culture ;
* statut ;
* date de début optionnelle ;
* date de fin optionnelle.

Statuts possibles :

```text
active
planned
completed
unknown
```

---

# Backend attendu

Le backend doit exposer des endpoints simples pour gérer les données métier agricoles.

Endpoints recommandés :

```http
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

Pour le Sprint 3 :

* les données peuvent être mockées ou stockées en mémoire ;
* PostgreSQL réel n’est pas obligatoire ;
* aucune migration de base de données n’est obligatoire ;
* les schémas doivent être propres et prêts pour PostgreSQL plus tard ;
* les endpoints doivent être testables ;
* les réponses doivent être stables et typées.

---

# Schémas backend attendus

Créer les schémas Pydantic nécessaires.

Emplacement recommandé :

```text
services/backend/app/schemas/
```

Schémas recommandés :

```text
FarmerProfile
FarmerProfileCreate
Farm
FarmCreate
Field
FieldCreate
Crop
CropCreate
FieldCrop
FieldCropCreate
```

Les schémas doivent être simples, typés, lisibles et cohérents avec le domaine validé dans :

```text
docs/13-Domain-Model.md
docs/16-Data-Architecture.md
docs/17-API-Design.md
```

---

# Services backend attendus

Créer des services dédiés pour séparer la logique métier de l’API.

Emplacements recommandés :

```text
services/backend/app/services/farmer/
services/backend/app/services/farm/
services/backend/app/services/field/
services/backend/app/services/crop/
```

Ou une structure équivalente simple.

Le service doit :

* créer un profil agricole mocké ;
* créer une exploitation ;
* créer une parcelle ;
* créer une culture ;
* associer une culture à une parcelle ;
* retourner les données créées ;
* éviter toute complexité inutile.

---

# Stockage Sprint 3

Pour le Sprint 3, le stockage peut être :

```text
in-memory
```

ou mocké.

La persistance PostgreSQL réelle est hors périmètre.

Mais le code doit être préparé proprement pour une future persistance.

Règle :

```text
Pas de dépendance forte à une base réelle dans Sprint 3.
```

---

# Mobile attendu

Le mobile doit permettre de saisir ou visualiser les informations agricoles de base.

Écrans ou sections recommandés :

```text
Profile agricole
Mes exploitations
Créer une exploitation
Détail exploitation
Mes parcelles
Créer une parcelle
Mes cultures
Associer culture à parcelle
```

Pour le Sprint 3, l’UX peut rester simple.

L’objectif est d’avoir un parcours fonctionnel, pas un design final.

---

# Parcours utilisateur attendu

Un utilisateur doit pouvoir :

1. ouvrir l’application ;
2. accéder à une section profil agricole ;
3. créer ou visualiser son profil agricole ;
4. créer une exploitation ;
5. créer une parcelle ;
6. créer une culture ;
7. associer une culture à une parcelle ;
8. voir le contexte agricole saisi.

---

# Intégration avec le mode découverte

Le mode découverte du Sprint 2 doit continuer à fonctionner.

Le Sprint 3 ne doit pas casser :

```text
POST /discovery/question
```

Le Sprint 3 peut préparer l’enrichissement futur des questions IA avec le contexte agricole, mais ne doit pas encore modifier fortement la logique IA.

---

# Tests attendus

## Backend

Ajouter ou compléter les tests backend pour vérifier :

* `/health` toujours OK ;
* `/discovery/question` toujours OK ;
* création profil agricole ;
* récupération profil agricole ;
* création exploitation ;
* récupération liste exploitations ;
* création parcelle ;
* récupération liste parcelles ;
* création culture ;
* récupération liste cultures ;
* association culture à parcelle ;
* validation des champs obligatoires ;
* erreurs simples sur identifiants inexistants.

Commande attendue :

```bash
cd services/backend
pytest
```

---

## Mobile

Ajouter ou compléter les tests mobile pour vérifier :

* application démarre ;
* navigation principale toujours OK ;
* accès au mode découverte toujours OK ;
* accès aux écrans profil / exploitation / parcelle / culture ;
* formulaire simple présent ;
* aucune erreur `flutter analyze`.

Commandes attendues :

```bash
cd apps/mobile
flutter analyze
flutter test
```

---

# README attendu

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

Documenter :

* Sprint 3 ;
* endpoints profil / exploitation / parcelle / culture ;
* stockage in-memory ou mocké ;
* limites connues ;
* commandes de lancement ;
* commandes de tests ;
* rappel que PostgreSQL réel n’est pas encore branché.

---

# CI attendue

La CI doit rester verte :

```text
Backend tests
Mobile checks
```

Aucun merge ne sera accepté si la CI est rouge.

---

# Hors périmètre strict

Ne pas développer dans Sprint 3 :

* appel OpenAI réel ;
* diagnostic photo réel ;
* stockage S3 réel ;
* authentification Cognito réelle complète ;
* PostgreSQL réel ;
* migrations Alembic ;
* historique complet des conversations ;
* historique complet des rotations culturales ;
* paiement ;
* abonnement ;
* marketplace ;
* fournisseurs ;
* IoT ;
* drone ;
* satellite ;
* météo réelle ;
* recommandation produit réelle ;
* dashboard avancé ;
* portail coopérative ;
* backoffice ;
* Sprint 4.

---

# Règles d’architecture

Le Sprint 3 doit respecter les décisions déjà validées :

```text
Mobile : Flutter
Backend : Python FastAPI
Cloud cible : AWS
Auth cible : Cognito via Amplify
Storage cible : S3
DB cible : RDS PostgreSQL
IA : OpenAI via backend uniquement
```

Ne pas changer la stack.

Ne pas introduire de nouvelles technologies non validées.

Ne pas complexifier l’architecture.

Ne pas créer de microservices.

Ne pas utiliser Kubernetes.

Ne pas utiliser Firebase, Supabase, MongoDB ou DynamoDB.

---

# Règles produit

Agrivito doit rester :

* simple ;
* fiable ;
* orienté agriculteur ;
* mobile-first ;
* compréhensible ;
* prudent dans les réponses ;
* préparé pour une IA contextualisée.

Le Sprint 3 ne doit pas transformer Agrivito en outil administratif complexe.

Les formulaires doivent rester courts.

L’utilisateur ne doit pas avoir l’impression de remplir un dossier lourd.

---

# Règles de sécurité

Ne jamais commiter :

* secrets AWS ;
* clé OpenAI ;
* fichier `.env` réel ;
* token ;
* credentials ;
* données personnelles réelles ;
* configuration sensible.

Les fichiers `.env.example` peuvent être complétés uniquement avec des valeurs fictives.

---

# Définition de Done

Le Sprint 3 est terminé uniquement si :

* le document Sprint 3 est présent ;
* le prompt Codex Sprint 3 est présent ;
* le profil agricole existe côté backend ou mock ;
* les exploitations existent côté backend ou mock ;
* les parcelles existent côté backend ou mock ;
* les cultures existent côté backend ou mock ;
* l’association parcelle / culture fonctionne ;
* le mobile expose un parcours simple pour ces données ;
* le mode découverte Sprint 2 fonctionne toujours ;
* les README sont à jour ;
* les tests backend passent ;
* les tests mobile passent ;
* GitHub Actions est vert ;
* aucune fonctionnalité hors périmètre n’a été ajoutée.

---

# Branche de développement

```text
codex/sprint-3-farm-field-crop
```

---

# Pull Request attendue

Titre :

```text
Sprint 3 - Farm, field and crop foundation
```

Description attendue :

```markdown
## Objectif

Créer les bases métier agricoles du MVP Agrivito : profil agricole, exploitation, parcelles, cultures et association parcelle / culture.

## Changements

- Ajout du profil agricole utilisateur
- Ajout des exploitations
- Ajout des parcelles
- Ajout des cultures
- Ajout de l'association culture / parcelle
- Ajout des endpoints backend correspondants
- Ajout des schémas backend
- Ajout des services backend
- Ajout ou amélioration des écrans mobile
- Mise à jour README
- Ajout / mise à jour tests backend
- Ajout / mise à jour tests mobile

## Tests réalisés

- pytest
- flutter analyze
- flutter test

## Limites connues

- Pas de stockage PostgreSQL réel
- Pas de migration Alembic
- Pas d'appel OpenAI réel
- Pas de diagnostic photo réel
- Pas d'auth Cognito réelle complète
- Pas de météo réelle
- Pas de marketplace

## Documents respectés

- docs/13-Domain-Model.md
- docs/16-Data-Architecture.md
- docs/17-API-Design.md
- docs/19-Technology-ADRs.md
- docs/20-MVP-Backlog.md
- docs/21-Codex-Handbook.md
- docs/23-Brand-Name-Decision.md
- docs/24-Sprint-2-Plan.md
- docs/25-Sprint-3-Plan.md
```

---

# Statut

```text
APPROVED
```
