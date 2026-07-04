---

title: Sprint 2 Plan
version: 1.0
status: Approved
owner: CTO
approved_by: CEO
last_updated: 2026-07-04
------------------------

# Agrivito - Sprint 2 Plan

## Objectif

Ce document définit le deuxième sprint de développement du MVP Agrivito.

Le Sprint 1 a livré le socle technique initial :

* repository structuré ;
* backend FastAPI ;
* endpoint `/health` ;
* application Flutter initiale ;
* CI GitHub Actions ;
* structure IA ;
* Trust Score mocké.

Le Sprint 2 doit maintenant poser les bases de l’accès utilisateur et du mode découverte.

---

# Objectif du Sprint 2

À la fin du Sprint 2, Agrivito doit permettre :

* d’utiliser l’application sans compte ;
* de créer une session découverte locale ;
* de poser une première question agricole en mode découverte ;
* de recevoir une réponse mockée structurée ;
* d’afficher une limite simple d’utilisation découverte ;
* de préparer la création de compte ;
* de préparer l’authentification Cognito / Amplify ;
* de garder une architecture propre pour les prochains sprints.

---

# Nom du Sprint

```text
Sprint 2 - Access and Discovery Foundation
```

---

# Priorité Sprint 2

Le Sprint 2 doit se concentrer uniquement sur :

1. accès utilisateur ;
2. mode découverte sans compte ;
3. préparation authentification ;
4. écrans login / register propres ;
5. endpoint backend discovery ;
6. modèle de réponse découverte ;
7. limites simples du mode découverte ;
8. tests backend ;
9. tests mobile ;
10. CI verte.

---

# Hors périmètre Sprint 2

Ne pas développer dans le Sprint 2 :

* appel OpenAI réel ;
* diagnostic photo réel ;
* upload S3 réel ;
* stockage PostgreSQL complet ;
* historique complet ;
* abonnement ;
* paiement ;
* marketplace ;
* fournisseur ;
* IoT ;
* drone ;
* satellite ;
* irrigation automatique ;
* pilotage équipement ;
* portail coopérative ;
* dashboard avancé.

---

# Principes produit Sprint 2

## 1. Réduire la friction

L’utilisateur doit pouvoir tester Agrivito sans créer un compte immédiatement.

Le mode découverte sert à montrer rapidement la valeur du produit.

## 2. Compte optionnel au début

Le compte devient utile quand l’utilisateur veut :

* sauvegarder son historique ;
* suivre son exploitation ;
* déclarer ses cultures ;
* retrouver ses diagnostics ;
* personnaliser ses recommandations.

## 3. Pas de fausse promesse IA

Le Sprint 2 ne doit pas prétendre faire un vrai diagnostic IA.

La réponse découverte peut être mockée, mais elle doit respecter le format futur :

* résumé ;
* réponse ;
* Trust Score ;
* questions complémentaires ;
* précautions.

## 4. Préparer sans complexifier

L’authentification Cognito / Amplify doit être préparée proprement, mais l’objectif n’est pas encore de finaliser toute la sécurité applicative.

---

# Tâches Sprint 2

## S2-T1 - Créer le document Sprint 2

### Objectif

Ajouter ce document dans :

```text
docs/24-Sprint-2-Plan.md
```

### Critères d’acceptation

* fichier présent ;
* statut Approved ;
* aligné avec Sprint 1 ;
* aligné avec la décision de nom Agrivito.

---

## S2-T2 - Créer le prompt Codex Sprint 2

### Objectif

Ajouter le prompt opérationnel dans :

```text
prompts/PROMPT-CODEX-SPRINT-2.md
```

### Critères d’acceptation

* prompt présent ;
* nom Agrivito utilisé ;
* branche cible indiquée ;
* périmètre Sprint 2 clair ;
* hors périmètre explicite.

---

## S2-T3 - Préparer Auth Amplify / Cognito côté mobile

### Objectif

Préparer l’intégration future de Cognito via Amplify.

### Travail attendu

Dans `apps/mobile/`, préparer :

* structure auth ;
* service auth mocké ou interface auth ;
* configuration prête pour Amplify ;
* séparation entre mode découverte et utilisateur connecté.

### Critères d’acceptation

* aucune vraie clé AWS dans Git ;
* pas de secret ;
* pas d’intégration AWS fragile ;
* structure claire pour connecter Cognito plus tard ;
* README mobile mis à jour.

---

## S2-T4 - Améliorer écran Login

### Objectif

Créer un écran Login propre, même si l’auth réelle n’est pas encore complète.

### Travail attendu

L’écran Login doit contenir :

* champ email ;
* champ mot de passe ;
* bouton connexion ;
* lien vers inscription ;
* lien vers mode découverte ;
* message clair si auth non encore connectée.

### Critères d’acceptation

* écran utilisable ;
* pas de crash ;
* navigation fonctionnelle ;
* pas de fausse connexion réelle ;
* texte clair.

---

## S2-T5 - Améliorer écran Register

### Objectif

Créer un écran Register propre.

### Travail attendu

L’écran Register doit contenir :

* champ nom ou pseudo ;
* champ email ;
* champ mot de passe ;
* confirmation mot de passe ;
* bouton création de compte ;
* lien vers login ;
* lien vers mode découverte ;
* message clair si auth réelle non encore connectée.

### Critères d’acceptation

* écran utilisable ;
* validation simple des champs ;
* navigation fonctionnelle ;
* pas de création réelle si Cognito non activé ;
* pas de secret.

---

## S2-T6 - Créer mode découverte côté mobile

### Objectif

Permettre à l’utilisateur d’entrer dans Agrivito sans compte.

### Travail attendu

Ajouter un mode découverte qui permet :

* d’accéder au Home ;
* d’accéder au Chat découverte ;
* de poser une question ;
* d’afficher une réponse mockée ;
* d’afficher le nombre de questions restantes.

### Critères d’acceptation

* mode découverte accessible sans login ;
* état local simple ;
* limite visible ;
* UX claire ;
* pas de persistance sensible.

---

## S2-T7 - Créer session découverte locale

### Objectif

Créer une session temporaire locale côté mobile.

### Travail attendu

La session découverte peut contenir :

```text
discoverySessionId
questionsUsed
questionsLimit
createdAt
```

### Critères d’acceptation

* session créée automatiquement ;
* pas besoin de compte ;
* compteur de questions fonctionne ;
* réinitialisation simple possible ;
* pas de données personnelles sensibles stockées.

---

## S2-T8 - Créer endpoint backend discovery question

### Objectif

Créer un endpoint backend pour recevoir une question en mode découverte.

### Endpoint attendu

```http
POST /discovery/question
```

### Exemple de requête

```json
{
  "session_id": "temporary-session-id",
  "question": "Pourquoi les feuilles de mes tomates jaunissent ?",
  "language": "fr"
}
```

### Exemple de réponse

```json
{
  "answer": {
    "summary": "Les feuilles jaunes peuvent avoir plusieurs causes.",
    "response": "Cela peut venir d'un manque d'eau, d'un excès d'eau, d'une carence ou d'une maladie. Pour être plus fiable, Agrivito doit connaître le contexte.",
    "trust_score": {
      "score": 60,
      "level": "moyen",
      "explanation": "Réponse générale sans photo ni contexte de culture."
    },
    "follow_up_questions": [
      "Depuis combien de temps les feuilles jaunissent ?",
      "Les feuilles jaunes sont-elles en bas ou en haut de la plante ?",
      "À quelle fréquence arrosez-vous ?"
    ],
    "precautions": [
      "Ne pas appliquer de traitement sans diagnostic plus précis.",
      "Ajouter une photo dans un prochain sprint pour améliorer l'analyse."
    ]
  },
  "usage": {
    "questions_used": 1,
    "questions_limit": 3,
    "remaining": 2
  }
}
```

### Critères d’acceptation

* endpoint disponible ;
* validation de la requête ;
* réponse structurée ;
* Trust Score présent ;
* questions complémentaires présentes ;
* tests backend présents ;
* pas d’appel OpenAI réel.

---

## S2-T9 - Créer schémas backend discovery

### Objectif

Créer les schémas nécessaires côté backend.

### Schémas attendus

* `DiscoveryQuestionRequest`
* `DiscoveryQuestionResponse`
* `DiscoveryAnswer`
* `DiscoveryUsage`
* réutilisation ou cohérence avec `TrustScoreResponse`

### Critères d’acceptation

* schémas typés ;
* réponse claire ;
* tests de validation simples ;
* format compatible avec les futurs appels IA.

---

## S2-T10 - Créer service backend discovery

### Objectif

Créer un service dédié au mode découverte.

### Emplacement recommandé

```text
services/backend/app/services/discovery/
```

ou

```text
services/backend/app/services/discovery_service.py
```

### Travail attendu

Le service doit :

* recevoir une question ;
* retourner une réponse mockée structurée ;
* intégrer un Trust Score ;
* retourner des questions complémentaires ;
* retourner une limite d’usage simple.

### Critères d’acceptation

* service séparé de l’API ;
* logique testable ;
* pas de dépendance OpenAI ;
* pas de base de données obligatoire.

---

## S2-T11 - Connecter le Chat mobile au backend discovery

### Objectif

Le Chat mobile doit appeler le backend.

### Travail attendu

Depuis l’écran Chat :

* saisir une question ;
* appeler `POST /discovery/question` ;
* afficher la réponse ;
* afficher le Trust Score ;
* afficher les questions complémentaires ;
* afficher les questions restantes ;
* gérer erreur backend indisponible.

### Critères d’acceptation

* appel HTTP fonctionnel ;
* loading state ;
* erreur claire ;
* réponse visible ;
* Trust Score visible ;
* pas d’appel OpenAI depuis mobile.

---

## S2-T12 - Ajouter limites simples mode découverte

### Objectif

Limiter le mode découverte pour préparer le futur modèle freemium.

### Règle MVP Sprint 2

```text
3 questions maximum en mode découverte
```

### Critères d’acceptation

* compteur affiché ;
* blocage simple après 3 questions ;
* message invitant à créer un compte ;
* pas de paiement ;
* pas d’abonnement.

---

## S2-T13 - Mettre à jour README

### Objectif

Documenter le Sprint 2.

### Fichiers à mettre à jour

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

### Contenu attendu

* endpoint `/discovery/question` ;
* mode découverte ;
* limites ;
* commandes de test ;
* état auth Cognito préparée mais non finalisée.

---

## S2-T14 - Tests backend

### Objectif

Garantir que le backend reste stable.

### Tests attendus

* test `/health` toujours OK ;
* test `POST /discovery/question` ;
* test format de réponse ;
* test Trust Score ;
* test usage limit ;
* test requête invalide.

### Critères d’acceptation

* tous les tests backend passent ;
* pas de régression Sprint 1.

---

## S2-T15 - Tests mobile et CI

### Objectif

Garantir que le mobile reste stable.

### Tests attendus

* `flutter analyze` OK ;
* `flutter test` OK ;
* navigation minimale OK ;
* test écran Home ou Chat si existant.

### Critères d’acceptation

* CI GitHub Actions verte ;
* backend tests verts ;
* mobile checks verts.

---

# Livrable attendu Sprint 2

À la fin du Sprint 2, le repository doit contenir :

```text
agrivito/
 ├── docs/
 │    └── 24-Sprint-2-Plan.md
 ├── prompts/
 │    └── PROMPT-CODEX-SPRINT-2.md
 ├── apps/
 │    └── mobile/
 │         ├── lib/
 │         │    ├── auth/
 │         │    ├── discovery/
 │         │    ├── screens/
 │         │    └── services/
 ├── services/
 │    └── backend/
 │         ├── app/
 │         │    ├── api/
 │         │    ├── schemas/
 │         │    ├── services/
 │         │    └── main.py
 │         └── tests/
 ├── .github/
 │    └── workflows/
 └── README.md
```

---

# Définition de Done Sprint 2

Le Sprint 2 est terminé si :

* le mode découverte est accessible sans compte ;
* l’utilisateur peut poser une question mockée ;
* le backend répond via `POST /discovery/question` ;
* la réponse contient un Trust Score ;
* la réponse contient des questions complémentaires ;
* une limite simple de 3 questions est appliquée ;
* Login et Register sont propres ;
* Cognito / Amplify est préparé sans secret ;
* README mis à jour ;
* tests backend OK ;
* tests mobile OK ;
* CI GitHub Actions verte ;
* aucune fonctionnalité Sprint 3 ou hors périmètre n’est développée.

---

# Branche recommandée

```text
codex/sprint-2-access-discovery
```

---

# Titre PR recommandé

```text
Sprint 2 - Access and discovery foundation
```

---

# Décision CTO

Le Sprint 2 doit rendre Agrivito testable sans compte.

La priorité n’est pas encore l’IA réelle.

La priorité est de poser proprement :

* accès ;
* découverte ;
* premier flux question/réponse ;
* limite freemium simple ;
* base propre pour l’authentification future.

Ce sprint doit rester simple, testable et limité.

---

**Statut : APPROVED**
