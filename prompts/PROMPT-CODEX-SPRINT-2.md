# PROMPT CODEX - SPRINT 2

Tu es Lead Developer sur le projet Agrivito.

Agrivito est une plateforme intelligente d’assistance à la décision agricole.

Ton rôle est de développer le Sprint 2 du MVP en respectant strictement les documents validés dans le dossier `docs/`.

---

# Étape obligatoire avant de coder

Avant de modifier ou créer du code, lis les documents suivants :

```text
docs/19-Technology-ADRs.md
docs/20-MVP-Backlog.md
docs/21-Codex-Handbook.md
docs/22-Sprint-1-Plan.md
docs/23-Brand-Name-Decision.md
docs/24-Sprint-2-Plan.md
```

Ces documents sont la source de vérité.

Important :

```text
AgriAI = ancien nom de travail
Agrivito = nom produit officiel
```

Toutes les nouvelles implémentations doivent utiliser **Agrivito**.

---

# Objectif du Sprint 2

Développer le socle d’accès utilisateur et de mode découverte.

Nom du sprint :

```text
Sprint 2 - Access and Discovery Foundation
```

À la fin du Sprint 2, Agrivito doit permettre :

* d’utiliser l’application sans compte ;
* de créer une session découverte locale ;
* de poser une question agricole en mode découverte ;
* de recevoir une réponse mockée structurée ;
* d’afficher un Trust Score ;
* d’afficher des questions complémentaires ;
* d’afficher les questions restantes ;
* de préparer Login / Register ;
* de préparer Cognito / Amplify sans vraie intégration fragile ;
* de garder la CI verte.

---

# Branche cible

Travaille sur la branche :

```text
codex/sprint-2-access-discovery
```

Si la branche n’existe pas, crée-la depuis `main`.

Ne travaille pas directement sur `main`.

---

# Périmètre autorisé Sprint 2

Tu peux développer uniquement :

1. mode découverte sans compte ;
2. session découverte locale côté mobile ;
3. écrans Login / Register améliorés ;
4. préparation auth Cognito / Amplify ;
5. endpoint backend `POST /discovery/question` ;
6. schémas backend discovery ;
7. service backend discovery mocké ;
8. connexion du Chat mobile au backend discovery ;
9. limite simple de 3 questions en mode découverte ;
10. tests backend ;
11. tests mobile ;
12. README ;
13. CI si nécessaire.

---

# Hors périmètre strict

Ne pas développer :

* appel OpenAI réel ;
* diagnostic photo réel ;
* upload S3 réel ;
* stockage PostgreSQL complet ;
* historique complet ;
* paiement ;
* abonnement ;
* marketplace ;
* fournisseurs ;
* IoT ;
* drone ;
* satellite ;
* irrigation automatique ;
* pilotage équipement ;
* portail coopérative ;
* dashboard avancé ;
* Sprint 3.

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

## 1. Vérifier la base Sprint 1

Avant de coder, vérifier que le socle Sprint 1 existe :

```text
services/backend/
apps/mobile/
.github/workflows/
README.md
```

Vérifier aussi que :

```http
GET /health
```

fonctionne toujours.

Ne pas casser le Sprint 1.

---

## 2. Backend - Ajouter endpoint discovery

Créer l’endpoint :

```http
POST /discovery/question
```

Emplacement recommandé :

```text
services/backend/app/api/discovery.py
```

L’endpoint doit accepter une requête de ce type :

```json
{
  "session_id": "temporary-session-id",
  "question": "Pourquoi les feuilles de mes tomates jaunissent ?",
  "language": "fr"
}
```

Il doit retourner une réponse de ce type :

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

Aucun appel OpenAI réel dans ce sprint.

---

## 3. Backend - Créer schémas discovery

Créer les schémas nécessaires dans :

```text
services/backend/app/schemas/
```

Schémas attendus :

```text
DiscoveryQuestionRequest
DiscoveryQuestionResponse
DiscoveryAnswer
DiscoveryUsage
```

Réutiliser ou rester cohérent avec :

```text
TrustScoreResponse
```

Contraintes :

* `session_id` obligatoire ;
* `question` obligatoire ;
* `language` optionnelle avec défaut `fr` ;
* question non vide ;
* réponse typée ;
* format stable pour les futurs appels IA.

---

## 4. Backend - Créer service discovery

Créer un service dédié.

Emplacement recommandé :

```text
services/backend/app/services/discovery/
```

ou :

```text
services/backend/app/services/discovery_service.py
```

Le service doit :

* recevoir une question ;
* produire une réponse mockée structurée ;
* intégrer un Trust Score ;
* retourner des questions complémentaires ;
* retourner des précautions ;
* retourner une limite d’usage simple.

Règle Sprint 2 :

```text
questions_limit = 3
```

Pour le Sprint 2, pas de base de données obligatoire.

---

## 5. Backend - Tests

Ajouter ou compléter les tests :

```text
services/backend/tests/
```

Tests minimum attendus :

* `/health` toujours OK ;
* `POST /discovery/question` OK ;
* réponse contient `answer` ;
* réponse contient `trust_score` ;
* réponse contient `follow_up_questions` ;
* réponse contient `usage` ;
* limite = 3 ;
* requête invalide refusée ;
* question vide refusée.

Tous les tests doivent passer avec :

```bash
pytest
```

---

## 6. Mobile - Préparer structure Auth

Préparer une structure claire pour l’authentification.

Emplacement recommandé :

```text
apps/mobile/lib/auth/
```

ou :

```text
apps/mobile/lib/services/auth_service.dart
```

Objectif :

* préparer Cognito / Amplify ;
* ne pas connecter réellement AWS si ce n’est pas nécessaire ;
* ne jamais commiter de secret ;
* séparer clairement utilisateur connecté et mode découverte.

Créer une interface ou service mocké propre.

---

## 7. Mobile - Améliorer Login

Améliorer l’écran Login.

Il doit contenir :

* champ email ;
* champ mot de passe ;
* bouton connexion ;
* lien vers Register ;
* lien vers mode découverte ;
* message clair indiquant que l’auth réelle sera connectée plus tard.

Ne pas faire de vraie authentification Cognito si la configuration réelle n’est pas disponible.

---

## 8. Mobile - Améliorer Register

Améliorer l’écran Register.

Il doit contenir :

* champ nom ou pseudo ;
* champ email ;
* champ mot de passe ;
* champ confirmation mot de passe ;
* bouton création compte ;
* lien vers Login ;
* lien vers mode découverte ;
* validation simple des champs ;
* message clair indiquant que la création réelle du compte sera connectée plus tard.

---

## 9. Mobile - Créer session découverte locale

Créer un modèle ou service de session découverte.

Structure attendue :

```text
discoverySessionId
questionsUsed
questionsLimit
createdAt
```

Règles :

```text
questionsLimit = 3
```

La session doit :

* être créée automatiquement ;
* fonctionner sans compte ;
* compter les questions posées ;
* afficher le nombre restant ;
* pouvoir être réinitialisée simplement.

Ne pas stocker de données personnelles sensibles.

---

## 10. Mobile - Connecter Chat au backend discovery

Modifier l’écran Chat pour permettre :

* saisie d’une question ;
* appel HTTP vers :

```http
POST /discovery/question
```

* affichage du loading ;
* affichage de la réponse ;
* affichage du Trust Score ;
* affichage des questions complémentaires ;
* affichage des précautions ;
* affichage des questions restantes ;
* message clair si backend indisponible ;
* blocage après 3 questions.

Le mobile ne doit jamais appeler OpenAI directement.

Le mobile doit appeler uniquement le backend FastAPI.

---

## 11. Mobile - UX mode découverte

L’utilisateur doit comprendre qu’il est en mode découverte.

Ajouter des textes simples :

```text
Mode découverte
3 questions gratuites pour tester Agrivito
Créez un compte pour sauvegarder votre historique plus tard
```

Après 3 questions, afficher un message :

```text
Vous avez atteint la limite du mode découverte. Créez un compte pour continuer plus tard.
```

Pas de paiement dans Sprint 2.

---

## 12. README

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

Documenter :

* endpoint `POST /discovery/question` ;
* mode découverte ;
* limite de 3 questions ;
* auth Cognito / Amplify préparée mais non finalisée ;
* commandes backend ;
* commandes mobile ;
* tests ;
* limites connues.

---

## 13. CI

La CI doit rester verte.

Vérifier :

```bash
pytest
flutter analyze
flutter test
```

Si la CI échoue, corriger jusqu’à ce que les deux jobs soient verts :

```text
CI / Backend tests
CI / Mobile checks
```

---

# Contraintes de qualité

Le code doit être :

* simple ;
* lisible ;
* maintenable ;
* testable ;
* cohérent avec Sprint 1 ;
* cohérent avec les documents dans `docs/`.

Ne pas complexifier.

Ne pas anticiper excessivement les futurs sprints.

Ne pas créer une architecture trop lourde.

---

# Règles de sécurité

Ne jamais commiter :

* secrets AWS ;
* clé OpenAI ;
* fichier `.env` réel ;
* token ;
* credentials ;
* configuration sensible.

Le fichier `.env.example` peut être mis à jour si nécessaire, mais sans valeur réelle.

---

# Règles produit

Agrivito n’est pas un simple chatbot.

Même en mode mocké, la réponse doit respecter l’esprit produit :

* prudence ;
* Trust Score ;
* questions complémentaires ;
* précautions ;
* pas de fausse certitude ;
* l’agriculteur reste décideur final.

---

# Résultat attendu

Créer une Pull Request avec le titre :

```text
Sprint 2 - Access and discovery foundation
```

Description PR attendue :

```markdown
## Objectif

Développer le socle d’accès utilisateur et le mode découverte du MVP Agrivito.

## Changements

- Ajout du mode découverte sans compte
- Ajout de la session découverte locale
- Amélioration Login / Register
- Préparation Auth Cognito / Amplify
- Ajout endpoint POST /discovery/question
- Ajout schémas backend discovery
- Ajout service backend discovery mocké
- Connexion du Chat mobile au backend discovery
- Ajout limite de 3 questions découverte
- Mise à jour README
- Ajout / mise à jour tests backend
- Ajout / mise à jour tests mobile

## Tests réalisés

- pytest
- flutter analyze
- flutter test

## Limites connues

- Pas d’appel OpenAI réel
- Pas d’auth Cognito réelle finalisée
- Pas de stockage PostgreSQL complet
- Pas d’historique persistant complet
- Pas de paiement ni abonnement

## Documents respectés

- docs/19-Technology-ADRs.md
- docs/20-MVP-Backlog.md
- docs/21-Codex-Handbook.md
- docs/22-Sprint-1-Plan.md
- docs/23-Brand-Name-Decision.md
- docs/24-Sprint-2-Plan.md
```

---

# Définition de Done

Le Sprint 2 est terminé uniquement si :

* la PR est ouverte ;
* le mode découverte fonctionne sans compte ;
* l’utilisateur peut poser une question ;
* le backend répond via `POST /discovery/question` ;
* la réponse contient un Trust Score ;
* la réponse contient des questions complémentaires ;
* la limite de 3 questions est visible ;
* Login et Register sont propres ;
* l’auth est préparée sans secret ;
* les README sont à jour ;
* les tests backend passent ;
* les tests mobile passent ;
* GitHub Actions est vert ;
* aucune fonctionnalité hors périmètre n’a été ajoutée.
