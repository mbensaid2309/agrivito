# PROMPT CODEX - SPRINT 3

Tu es Lead Developer sur le projet Agrivito.

Agrivito est une plateforme intelligente d’assistance à la décision agricole.

Ton rôle est de développer le Sprint 3 du MVP en respectant strictement les documents validés dans le dossier `docs/`.

---

# Étape obligatoire avant de coder

Avant de modifier ou créer du code, lis les documents suivants :

```text
docs/13-Domain-Model.md
docs/16-Data-Architecture.md
docs/17-API-Design.md
docs/19-Technology-ADRs.md
docs/20-MVP-Backlog.md
docs/21-Codex-Handbook.md
docs/23-Brand-Name-Decision.md
docs/24-Sprint-2-Plan.md
docs/25-Sprint-3-Plan.md
```

Ces documents sont la source de vérité.

Important :

```text
AgriAI = ancien nom de travail
Agrivito = nom produit officiel
```

Toutes les nouvelles implémentations doivent utiliser **Agrivito**.

---

# Branche cible

Travaille sur la branche :

```text
codex/sprint-3-farm-field-crop
```

Si la branche n’existe pas, crée-la depuis `main`.

Ne travaille jamais directement sur `main`.

---

# Objectif du Sprint 3

Développer les fondations métier agricoles du MVP Agrivito :

```text
Sprint 3 - Farm, Field and Crop Foundation
```

À la fin du Sprint 3, Agrivito doit permettre de gérer simplement :

* un profil agricole utilisateur ;
* une exploitation agricole ;
* des parcelles ;
* des cultures ;
* l’association culture / parcelle ;
* un contexte agricole de base pour les futurs diagnostics IA.

Le Sprint 3 prépare Agrivito à devenir une plateforme intelligente contextualisée, et pas un simple chatbot agricole générique.

---

# Périmètre autorisé Sprint 3

Tu peux développer uniquement :

1. profil agricole utilisateur ;
2. exploitation agricole ;
3. parcelles ;
4. cultures ;
5. association culture / parcelle ;
6. endpoints backend correspondants ;
7. schémas backend Pydantic ;
8. services backend in-memory ou mockés ;
9. écrans mobile simples ;
10. navigation mobile vers les sections agricoles ;
11. tests backend ;
12. tests mobile ;
13. mise à jour README ;
14. maintien du mode découverte Sprint 2.

---

# Hors périmètre strict

Ne pas développer :

* appel OpenAI réel ;
* diagnostic photo réel ;
* upload S3 réel ;
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

Ne pas introduire :

* Kubernetes ;
* EKS ;
* microservices multiples ;
* DynamoDB ;
* MongoDB ;
* Firebase ;
* Supabase ;
* nouvelle technologie non validée.

---

# Travail demandé

## 1. Vérifier la base existante

Avant de coder, vérifier que les éléments Sprint 1 et Sprint 2 existent toujours :

```text
services/backend/
apps/mobile/
.github/workflows/
README.md
```

Vérifier que les endpoints existants fonctionnent toujours :

```http
GET /health
POST /discovery/question
```

Ne pas casser le Sprint 1 ni le Sprint 2.

---

## 2. Backend - Créer les schémas métier agricoles

Créer les schémas Pydantic nécessaires dans :

```text
services/backend/app/schemas/
```

Fichier recommandé :

```text
services/backend/app/schemas/agriculture.py
```

Schémas attendus :

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

Les schémas doivent être simples, typés et prêts pour une future persistance PostgreSQL.

---

## 3. Backend - Profil agricole utilisateur

Créer les endpoints :

```http
GET /farmer/profile
POST /farmer/profile
```

Emplacement recommandé :

```text
services/backend/app/api/farmer.py
```

Le profil agricole doit contenir au minimum :

```text
user_id
display_name
user_type
country
region
preferred_language
is_discovery_mode
created_at
```

Types d’utilisateur autorisés :

```text
farmer
advisor
cooperative_member
unknown
```

Pour le Sprint 3, le profil peut être mocké ou stocké en mémoire.

---

## 4. Backend - Exploitations agricoles

Créer les endpoints :

```http
GET /farms
POST /farms
GET /farms/{farm_id}
```

Emplacement recommandé :

```text
services/backend/app/api/farms.py
```

Une exploitation doit contenir au minimum :

```text
farm_id
user_id
name
country
region
locality
total_area
area_unit
created_at
```

Règles :

* un utilisateur peut avoir plusieurs exploitations ;
* pour le Sprint 3, rester simple ;
* stockage in-memory autorisé ;
* pas de PostgreSQL réel.

---

## 5. Backend - Parcelles

Créer les endpoints :

```http
GET /farms/{farm_id}/fields
POST /farms/{farm_id}/fields
GET /fields/{field_id}
```

Emplacement recommandé :

```text
services/backend/app/api/fields.py
```

Une parcelle doit contenir au minimum :

```text
field_id
farm_id
name
area
area_unit
soil_type
water_access
irrigation_type
notes
created_at
```

Types d’irrigation autorisés :

```text
none
drip
sprinkler
flood
manual
unknown
```

Types d’accès à l’eau autorisés :

```text
yes
no
seasonal
unknown
```

---

## 6. Backend - Cultures

Créer les endpoints :

```http
GET /crops
POST /crops
GET /crops/{crop_id}
```

Emplacement recommandé :

```text
services/backend/app/api/crops.py
```

Une culture doit contenir au minimum :

```text
crop_id
name
category
variety
season
planting_date
growth_stage
notes
created_at
```

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

Catégories autorisées :

```text
vegetable
fruit_tree
cereal
legume
industrial_crop
other
unknown
```

Stades de culture autorisés :

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

## 7. Backend - Association culture / parcelle

Créer les endpoints :

```http
POST /fields/{field_id}/crop
GET /fields/{field_id}/crop
```

Emplacement recommandé :

```text
services/backend/app/api/field_crops.py
```

Une association culture / parcelle doit contenir au minimum :

```text
field_crop_id
field_id
crop_id
status
start_date
end_date
created_at
```

Statuts autorisés :

```text
active
planned
completed
unknown
```

Règles Sprint 3 :

* une parcelle peut avoir une culture principale active ;
* l’historique complet des rotations n’est pas nécessaire ;
* garder l’implémentation simple.

---

## 8. Backend - Services métier

Créer des services dédiés pour séparer l’API de la logique métier.

Emplacement recommandé :

```text
services/backend/app/services/agriculture/
```

Services recommandés :

```text
farmer_service.py
farm_service.py
field_service.py
crop_service.py
field_crop_service.py
```

Ou une structure équivalente simple.

Les services doivent :

* créer un profil agricole ;
* retourner le profil agricole ;
* créer une exploitation ;
* lister les exploitations ;
* récupérer une exploitation ;
* créer une parcelle ;
* lister les parcelles ;
* récupérer une parcelle ;
* créer une culture ;
* lister les cultures ;
* récupérer une culture ;
* associer une culture à une parcelle ;
* récupérer la culture associée à une parcelle.

---

## 9. Backend - Stockage Sprint 3

Pour le Sprint 3, utiliser un stockage simple :

```text
in-memory
```

ou mocké.

Règles :

* pas de PostgreSQL réel ;
* pas d’Alembic ;
* pas de migration ;
* pas de dépendance forte à une base réelle ;
* garder le code prêt pour une future persistance.

Le stockage in-memory doit être suffisant pour les tests backend.

---

## 10. Backend - Brancher les routers dans FastAPI

Mettre à jour :

```text
services/backend/app/main.py
```

Inclure les nouveaux routers :

```text
farmer
farms
fields
crops
field_crops
```

Conserver les routers existants :

```text
health
discovery
```

---

## 11. Backend - Tests

Ajouter les tests dans :

```text
services/backend/tests/
```

Tests minimum attendus :

```text
/health toujours OK
/discovery/question toujours OK
POST /farmer/profile OK
GET /farmer/profile OK
POST /farms OK
GET /farms OK
GET /farms/{farm_id} OK
POST /farms/{farm_id}/fields OK
GET /farms/{farm_id}/fields OK
GET /fields/{field_id} OK
POST /crops OK
GET /crops OK
GET /crops/{crop_id} OK
POST /fields/{field_id}/crop OK
GET /fields/{field_id}/crop OK
erreur simple si farm_id inexistant
erreur simple si field_id inexistant
erreur simple si crop_id inexistant
validation des champs obligatoires
```

Les tests doivent passer avec :

```bash
cd services/backend
pytest
```

---

# 12. Mobile - Parcours agricole simple

Créer ou améliorer les écrans mobile nécessaires pour gérer le contexte agricole.

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

L’UX peut rester simple.

Objectif Sprint 3 :

```text
fonctionnel > beau
```

Ne pas faire un design final.

---

## 13. Mobile - Profil agricole

Créer un écran permettant de visualiser ou saisir les informations de base :

```text
nom ou pseudo
type d’utilisateur
pays
région
langue préférée
```

Le stockage peut être local, mocké ou connecté au backend selon simplicité.

Ne pas introduire de complexité inutile.

---

## 14. Mobile - Exploitations

Créer un écran simple :

```text
Mes exploitations
```

Avec possibilité de créer une exploitation :

```text
nom
pays
région
commune/localité
surface totale optionnelle
unité de surface
```

---

## 15. Mobile - Parcelles

Créer un écran simple :

```text
Mes parcelles
```

Avec possibilité de créer une parcelle :

```text
nom
surface
unité
type de sol optionnel
accès à l’eau optionnel
irrigation optionnelle
notes optionnelles
```

---

## 16. Mobile - Cultures

Créer un écran simple :

```text
Mes cultures
```

Avec possibilité de créer une culture :

```text
nom
catégorie
variété optionnelle
saison optionnelle
stade de culture optionnel
notes optionnelles
```

---

## 17. Mobile - Association culture / parcelle

Créer une interaction simple permettant d’associer une culture à une parcelle.

Exemple acceptable Sprint 3 :

```text
Choisir une parcelle
Choisir une culture
Cliquer sur Associer
Afficher l’association active
```

Ne pas gérer les rotations avancées.

---

## 18. Mobile - Navigation

Mettre à jour la navigation pour accéder aux nouvelles sections agricoles.

Le mode découverte Sprint 2 doit rester accessible.

Les écrans Login / Register doivent rester fonctionnels.

Ne pas supprimer les écrans existants.

---

## 19. Mobile - Connexion backend

Si simple et déjà cohérent avec l’architecture Sprint 2, connecter les écrans aux endpoints backend.

Sinon, utiliser une couche service mock/local propre.

Règle CTO :

```text
Ne pas complexifier pour forcer une intégration complète.
```

Priorité :

```text
architecture propre + CI verte
```

---

## 20. Mobile - Tests

Ajouter ou adapter les tests mobile pour vérifier :

```text
l’application démarre
la navigation principale fonctionne
le mode découverte reste accessible
les écrans agricoles existent
les formulaires de base sont présents
flutter analyze passe
```

Commandes :

```bash
cd apps/mobile
flutter analyze
flutter test
```

---

## 21. README

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

Documenter :

* Sprint 3 ;
* nouveaux endpoints ;
* profil agricole ;
* exploitations ;
* parcelles ;
* cultures ;
* association culture / parcelle ;
* stockage in-memory ou mock ;
* limites connues ;
* commandes de lancement ;
* commandes de tests ;
* rappel que PostgreSQL réel n’est pas encore branché.

---

## 22. CI

La CI doit rester verte.

Vérifier :

```bash
pytest
flutter analyze
flutter test
```

Si GitHub Actions échoue, corriger jusqu’à obtenir :

```text
Backend tests : OK
Mobile checks : OK
```

---

# Contraintes de qualité

Le code doit être :

* simple ;
* lisible ;
* maintenable ;
* testable ;
* cohérent avec Sprint 1 ;
* cohérent avec Sprint 2 ;
* cohérent avec les documents dans `docs/`.

Ne pas complexifier.

Ne pas anticiper excessivement les futurs sprints.

Ne pas créer une architecture trop lourde.

---

# Contraintes architecture

Respecter strictement la stack validée :

```text
Mobile : Flutter
Backend : Python FastAPI
Cloud cible : AWS
Auth cible : Cognito via Amplify
Storage cible : S3
DB cible : RDS PostgreSQL
IA : OpenAI via backend uniquement
```

Interdiction d’ajouter :

```text
Kubernetes
EKS
microservices
DynamoDB
MongoDB
Firebase
Supabase
nouvelle stack non validée
```

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

Les fichiers `.env.example` peuvent être mis à jour uniquement avec des valeurs fictives.

---

# Règles produit

Agrivito doit rester :

* simple ;
* fiable ;
* orienté agriculteur ;
* mobile-first ;
* compréhensible ;
* prudent ;
* préparé pour une IA contextualisée.

Le Sprint 3 ne doit pas transformer Agrivito en outil administratif complexe.

Les formulaires doivent rester courts.

L’utilisateur ne doit pas avoir l’impression de remplir un dossier lourd.

---

# Résultat attendu

Créer une Pull Request avec le titre :

```text
Sprint 3 - Farm, field and crop foundation
```

Description PR attendue :

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

# Définition de Done

Le Sprint 3 est terminé uniquement si :

* la branche `codex/sprint-3-farm-field-crop` existe ;
* la PR est ouverte vers `main` ;
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

# Commandes de validation attendues

Backend :

```bash
cd services/backend
pytest
```

Mobile :

```bash
cd apps/mobile
flutter analyze
flutter test
```

---

# Instruction finale

Quand le développement est terminé :

1. pousse les changements sur :

```text
codex/sprint-3-farm-field-crop
```

2. crée la PR vers `main` ;
3. vérifie que la CI est verte ;
4. ne merge pas la PR sans validation CTO.
