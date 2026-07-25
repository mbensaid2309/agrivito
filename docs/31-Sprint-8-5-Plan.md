---
title: Sprint 8.5 Plan
version: 1.0
status: Approved
owner: CTO
approved_by: CEO
last_updated: 2026-07-25
---

# Agrivito - Sprint 8.5 Plan

## 1. Nom du Sprint

**Sprint 8.5 - MVP Demo and Product Review**

## 2. Objectif

Permettre au CEO de voir, lancer et tester Agrivito sans devoir comprendre l’ensemble du code ni configurer plusieurs services complexes.

Le sprint ne doit pas ajouter de nouvelle fonctionnalité métier importante. Il doit rendre le produit visible, stable et simple à évaluer.

## 3. Résultat attendu

À la fin du sprint, le CEO doit pouvoir :

- lancer Agrivito avec une procédure simple ;
- ouvrir l’application dans un navigateur ;
- tester le mode découverte ;
- tester le diagnostic texte en mode mock ;
- tester l’upload et le diagnostic photo en mode mock ;
- créer un compte ou utiliser une authentification de démonstration ;
- créer un profil agricole, une exploitation, une parcelle et une culture ;
- identifier les écrans fonctionnels, incomplets ou à modifier ;
- donner un avis produit avant le Sprint 9.

## 4. Décision CTO

Aucun nouveau sprint fonctionnel ne doit commencer avant cette validation produit.

## 5. Parcours obligatoire

```text
Accueil
→ Mode découverte
→ Poser une question
→ Voir la réponse et le Trust Score
→ Envoyer une photo
→ Analyser la photo
→ Créer un compte
→ Se connecter
→ Créer un profil agricole
→ Créer une exploitation
→ Ajouter une parcelle
→ Ajouter une culture
→ Se déconnecter
```

## 6. Périmètre

Le Sprint 8.5 couvre uniquement :

1. vérification complète de l’application actuelle ;
2. correction des bugs bloquants ;
3. correction des navigations cassées ;
4. correction des écrans non accessibles ;
5. création d’un mode démonstration ;
6. ajout de données fictives de démonstration ;
7. lancement backend en mode mock ;
8. lancement Flutter Web simplifié ;
9. authentification réelle Supabase si configurée, sinon auth mock ;
10. script de démarrage local ;
11. script d’arrêt si utile ;
12. guide de démonstration ;
13. checklist de validation produit ;
14. harmonisation visuelle minimale ;
15. tests de fumée ;
16. maintien des Sprints 1 à 8.

## 7. Hors périmètre strict

Ne pas développer :

- historique complet ;
- voix ;
- Darija vocale ;
- paiement ;
- abonnement ;
- marketplace ;
- RAG ;
- Cognito ;
- migration Supabase vers Cognito ;
- nouveau moteur IA ;
- comparaison multi-photo ;
- vidéo ;
- notifications ;
- observabilité avancée ;
- déploiement AWS complet ;
- Sprint 9.

## 8. Mode démonstration

Créer un mode explicite :

```env
DEMO_MODE=true
AI_MODE=mock
VISION_MODE=mock
AUTH_MODE=mock_or_live
MEDIA_STORAGE_PROVIDER=local
```

Règles :

- aucun appel OpenAI réel obligatoire ;
- aucun appel AWS réel ;
- aucun coût externe obligatoire ;
- réponses réalistes mais clairement identifiées comme démonstration ;
- aucune donnée personnelle réelle.

## 9. Authentification de démonstration

Deux modes doivent être supportés :

### Mode Supabase réel

Utilisé si les variables suivantes sont fournies :

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

### Mode Auth mock

Utilisé pour lancer immédiatement l’application sans configuration externe.

L’interface doit indiquer clairement le mode utilisé.

## 10. Données de démonstration

Créer des données fictives cohérentes :

```text
Utilisateur : agriculteur.demo@agrivito.local
Profil : Agriculteur de démonstration
Exploitation : Ferme Atlas
Région : Meknès
Parcelle : Parcelle Nord
Culture : Tomate
Variété : Roma
Stade : Floraison
```

Ajouter :

- une question agricole de démonstration ;
- une réponse texte mockée ;
- une photo de test non sensible ;
- un diagnostic photo mocké ;
- un Trust Score moyen ;
- un Trust Score élevé ;
- un cas de photo insuffisante.

## 11. Écran d’accueil

L’écran d’accueil doit afficher :

- Agrivito ;
- une description courte ;
- bouton `Essayer sans compte` ;
- bouton `Se connecter` ;
- bouton `Créer un compte` ;
- accès au chat ;
- accès à l’analyse photo ;
- indication visible du mode démonstration.

Texte recommandé :

```text
Agrivito vous aide à mieux comprendre les problèmes agricoles grâce à vos questions, vos photos et votre contexte de culture.
```

## 12. Navigation

Vérifier les écrans minimum :

```text
Home
Chat
Upload Photo
Photo Diagnosis
Login
Register
Forgot Password
Profile
Farmer Profile
Farms
Fields
Crops
Diagnostic Result
```

Règles :

- aucun écran blanc ;
- aucun bouton sans effet ;
- aucun retour arrière cassé ;
- aucune route inexistante ;
- navigation cohérente entre mode découverte et mode connecté.

## 13. Cohérence visuelle minimale

Harmoniser uniquement :

- titres ;
- boutons ;
- espacements ;
- messages d’erreur ;
- messages de succès ;
- chargements ;
- cartes diagnostic ;
- Trust Score ;
- libellés français.

Pas de refonte complète.

## 14. Indication du mode mock

Quand une réponse est simulée, afficher :

```text
Mode démonstration
```

Ne jamais présenter un résultat mocké comme un diagnostic confirmé.

## 15. Lancement local simplifié

Créer :

```text
scripts/start-demo.sh
```

Le script doit :

- vérifier les prérequis ;
- appliquer les migrations ;
- démarrer FastAPI ;
- démarrer Flutter Web ;
- afficher les URLs utiles ;
- afficher clairement les erreurs de configuration.

Commande cible :

```bash
./scripts/start-demo.sh
```

Si une commande unique n’est pas raisonnablement possible, fournir au maximum deux commandes.

## 16. Arrêt

Créer si utile :

```text
scripts/stop-demo.sh
```

## 17. Guide de démonstration

Créer :

```text
docs/32-MVP-Demo-Guide.md
```

Le guide doit expliquer simplement :

1. prérequis ;
2. mise à jour du repository ;
3. variables nécessaires ;
4. lancement ;
5. URL à ouvrir ;
6. compte de démonstration ;
7. parcours à tester ;
8. arrêt ;
9. signalement d’un problème.

Le guide doit être compréhensible par une personne non développeuse.

## 18. Checklist produit

Créer :

```text
docs/33-Product-Review-Checklist.md
```

Critères :

```text
Accueil compréhensible
Navigation simple
Mode découverte clair
Chat compréhensible
Résultat diagnostic lisible
Trust Score compréhensible
Upload photo simple
Diagnostic photo clair
Inscription simple
Connexion simple
Profil agricole compréhensible
Création exploitation simple
Création parcelle simple
Création culture simple
Design acceptable
Messages d’erreur compréhensibles
Fonctions manquantes identifiées
```

Statuts :

```text
Validé
À modifier
Bloquant
Commentaire
```

## 19. Backend

Vérifier :

- `GET /health` ;
- OpenAPI ;
- migrations ;
- auth mock ;
- diagnostic texte mock ;
- upload média local ;
- diagnostic photo mock ;
- endpoints agricoles ;
- erreurs contrôlées ;
- absence de stack trace exposée.

## 20. Flutter Web

Flutter Web devient le support principal de démonstration.

Raisons :

- ouverture dans un navigateur ;
- pas d’émulateur requis ;
- retours et captures facilités.

Android et iOS restent la cible finale, mais ne sont pas obligatoires pour cette revue.

## 21. Compatibilité photo web

- l’upload depuis un fichier doit fonctionner ;
- la caméra web est optionnelle ;
- le parcours ne doit pas dépendre de la caméra.

## 22. Déploiement temporaire optionnel

Un déploiement web gratuit peut être ajouté si simple et sans coût obligatoire.

Le livrable obligatoire reste une démonstration locale simple.

## 23. Tests backend minimum

```text
healthcheck
auth mock
mode découverte
diagnostic texte mock
upload photo local
diagnostic photo mock
création profil
création exploitation
création parcelle
création culture
isolation utilisateur
aucun appel OpenAI réel
aucun appel AWS réel
```

## 24. Tests Flutter minimum

```text
home accessible
navigation principale
mode découverte
chat mock
résultat diagnostic
upload fichier
diagnostic photo mock
login mock
register mock
profil
farms
fields
crops
messages erreur
mode démonstration visible
```

## 25. Smoke test manuel

Codex doit exécuter et documenter :

```text
Ouvrir Home
Entrer en mode découverte
Poser une question
Voir la réponse
Uploader une photo
Lancer le diagnostic photo
Créer un compte ou utiliser le mock
Se connecter
Créer une exploitation
Créer une parcelle
Créer une culture
Se déconnecter
```

## 26. Documentation

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

Documenter :

- mode démonstration ;
- commande de lancement ;
- variables ;
- URLs ;
- différence mock/live ;
- limites connues.

## 27. Sécurité

Ne jamais commiter :

- vraie clé Supabase ;
- service role key ;
- JWT ;
- mot de passe réel ;
- vraie clé OpenAI ;
- credentials AWS ;
- données personnelles ;
- photos privées ;
- `.env`.

## 28. Definition of Done

Le Sprint 8.5 est terminé uniquement si :

- Agrivito se lance simplement ;
- une URL locale est fournie ;
- Flutter Web s’ouvre ;
- le backend répond ;
- le mode découverte fonctionne ;
- le diagnostic texte mock fonctionne ;
- l’upload photo fonctionne ;
- le diagnostic photo mock fonctionne ;
- l’auth réelle ou mock fonctionne ;
- les écrans agricoles sont accessibles ;
- les principales navigations fonctionnent ;
- aucun écran blanc bloquant ;
- les erreurs sont compréhensibles ;
- le mode démonstration est visible ;
- le guide existe ;
- la checklist produit existe ;
- les tests backend passent ;
- les tests Flutter passent ;
- la CI est verte ;
- aucun appel payant réel n’est obligatoire ;
- aucun secret n’est présent dans Git ;
- les Sprints 1 à 8 restent fonctionnels ;
- aucune fonctionnalité hors périmètre n’est ajoutée.

## 29. Branche

Codex doit créer et utiliser exactement :

```text
codex/sprint-8-5-mvp-demo-product-review
```

Aucun autre nom de branche n’est autorisé.

Codex doit partir du dernier `main`, ne jamais coder sur `main` et ne jamais merger lui-même la PR.

## 30. Pull Request attendue

Titre :

```text
Sprint 8.5 - MVP demo and product review
```

Description minimale :

```markdown
## Objectif

Rendre Agrivito visible, testable et simple à lancer afin de permettre la première validation produit complète.

## Changements

- Ajout mode démonstration
- Ajout données de démonstration
- Ajout script start-demo
- Correction navigations bloquantes
- Correction écrans cassés
- Harmonisation visuelle minimale
- Ajout guide de démonstration
- Ajout checklist de validation produit
- Vérification parcours découverte
- Vérification parcours authentifié
- Mise à jour tests et README
- Maintien des Sprints 1 à 8

## Tests réalisés

- pytest
- flutter analyze
- flutter test
- flutter build web
- smoke test manuel
- git diff --check

## Limites connues

- Réponses IA en mode mock
- Analyse photo en mode mock
- Pas d’historique complet
- Pas de voix
- Pas de déploiement AWS
```

## 31. Rapport final attendu

```text
branche utilisée
commandes de lancement
URL locale Flutter
URL backend
compte de démonstration
parcours testé
écrans fonctionnels
écrans incomplets
bugs corrigés
tests backend
tests Flutter
résultat build web
résultat CI
limites connues
URL de la Pull Request
```

Ne pas merger la Pull Request.

Attendre la validation CTO.

## 32. Statut

**APPROVED**