Tu es Lead Developer sur le projet Agrivito.

Agrivito est une plateforme intelligente d’assistance à la décision agricole.

Ton rôle est de réaliser le Sprint 8.5 afin de rendre le produit visible, testable et simple à lancer pour une première validation produit complète.

Tu ne dois prendre aucune décision d’architecture.

Tu ne dois pas ajouter de nouvelle fonctionnalité métier importante.

---

# Étape obligatoire avant de coder

Avant toute modification, lis intégralement :

```text
docs/08-Product-Roadmap.md
docs/09-MVP-Scope.md
docs/12-MVP-User-Stories.md
docs/13-Domain-Model.md
docs/14-Quality-Reliability-Standards.md
docs/15-AI-Architecture.md
docs/16-Data-Architecture.md
docs/17-API-Design.md
docs/18-MVP-Technical-Architecture.md
docs/19-Technology-ADRs.md
docs/20-MVP-Backlog.md
docs/21-Codex-Handbook.md
docs/23-Brand-Name-Decision.md
docs/29-Sprint-7-Plan.md
docs/30-Sprint-8-Plan.md
docs/31-Sprint-8-5-Plan.md
```

Ces documents sont la source de vérité.

Important :

```text
AgriAI = ancien nom de travail
Agrivito = nom officiel du produit
```

Toutes les nouvelles implémentations doivent utiliser `Agrivito` ou `agrivito`.

---

# Règle bloquante sur la branche

Tu dois créer et utiliser exactement :

```text
codex/sprint-8-5-mvp-demo-product-review
```

Aucun autre nom de branche n’est autorisé.

Avant toute modification :

```bash
git checkout main
git pull origin main
git checkout -b codex/sprint-8-5-mvp-demo-product-review
```

Tu ne dois jamais travailler directement sur `main`.

Tu ne dois jamais merger toi-même la Pull Request.

---

# Nom du Sprint

```text
Sprint 8.5 - MVP Demo and Product Review
```

---

# Objectif

Rendre Agrivito visible, testable et simple à lancer.

À la fin du sprint, le CEO doit pouvoir :

- ouvrir Agrivito dans un navigateur ;
- comprendre immédiatement l’objectif du produit ;
- tester le mode découverte ;
- poser une question agricole ;
- voir une réponse structurée ;
- voir le Trust Score ;
- uploader une photo ;
- lancer un diagnostic photo mocké ;
- créer un compte ou utiliser un mode auth de démonstration ;
- créer un profil agricole ;
- créer une exploitation ;
- ajouter une parcelle ;
- ajouter une culture ;
- se déconnecter ;
- identifier ce qui lui plaît ou non dans le produit.

Le sprint doit privilégier la démonstration, la stabilité et la compréhension.

---

# Décision produit bloquante

Aucun nouveau sprint fonctionnel ne doit commencer avant la validation de cette démonstration.

Ne développe pas le Sprint 9.

---

# Parcours obligatoire

Le parcours suivant doit être fonctionnel :

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

---

# Architecture du mode démonstration

```text
Flutter Web
    |
    v
FastAPI local
    |
    +--> PostgreSQL local ou base de test existante
    +--> MockAuthProvider ou Supabase Auth réel
    +--> MockAIProvider
    +--> MockVisionProvider
    +--> LocalMediaStorage
```

Règles :

- aucun appel OpenAI réel obligatoire ;
- aucun appel AWS réel ;
- aucun coût externe obligatoire ;
- aucun accès direct Flutter aux tables métier ;
- le backend reste l’unique accès aux données ;
- les modes mock doivent être clairement visibles ;
- la démonstration doit être utilisable sans comprendre l’architecture.

---

# Périmètre autorisé

Tu peux développer uniquement :

1. vérification complète de l’application actuelle ;
2. correction des bugs bloquants ;
3. correction des navigations cassées ;
4. correction des écrans non accessibles ;
5. mode démonstration explicite ;
6. données de démonstration fictives ;
7. réponses IA mockées réalistes ;
8. diagnostic photo mocké ;
9. authentification mock ou Supabase réelle selon configuration ;
10. lancement Flutter Web ;
11. script `start-demo.sh` ;
12. script `stop-demo.sh` si utile ;
13. guide de démonstration ;
14. checklist de validation produit ;
15. harmonisation visuelle minimale ;
16. ajout d’indicateurs `Mode démonstration` ;
17. tests de fumée ;
18. correction de petits problèmes UX ;
19. mise à jour des README ;
20. maintien des Sprints 1 à 8.

---

# Hors périmètre strict

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
- refonte graphique complète ;
- design system avancé ;
- Sprint 9.

Ne pas introduire :

- nouvelle architecture ;
- nouveau microservice ;
- nouvel orchestrateur complexe ;
- LangChain ;
- LlamaIndex ;
- Firebase ;
- Auth0 ;
- Keycloak ;
- nouvelle base de données ;
- nouvelle technologie non validée.

---

# Travail demandé

## 1. Vérifier le repository

Vérifier que ces éléments existent :

```text
services/backend/
apps/mobile/
scripts/
docs/
.github/workflows/
README.md
```

Vérifier également les fichiers récents :

```text
docs/29-Sprint-7-Plan.md
docs/30-Sprint-8-Plan.md
docs/31-Sprint-8-5-Plan.md
```

Ne casse pas les Sprints 1 à 8.

---

## 2. Vérifier les écrans Flutter

Vérifier au minimum :

```text
Home
Chat
Upload Photo
Photo Diagnosis
Diagnostic Result
Login
Register
Forgot Password
Profile
Farmer Profile
Farms
Fields
Crops
```

Pour chaque écran :

- vérifier qu’il compile ;
- vérifier qu’il est accessible ;
- vérifier qu’il n’affiche pas d’écran blanc ;
- vérifier les boutons ;
- vérifier la navigation retour ;
- vérifier les erreurs ;
- vérifier les chargements ;
- vérifier les textes français ;
- corriger uniquement les problèmes bloquants ou visuellement gênants.

---

## 3. Vérifier les endpoints backend

Vérifier :

```http
GET /health
POST /discovery/question
POST /discovery/media/upload
POST /discovery/photo-diagnosis
POST /ai/diagnosis
POST /ai/photo-diagnosis
POST /media/upload
GET /media/{media_id}
GET /farmer/profile
POST /farmer/profile
GET /farms
POST /farms
GET /farms/{farm_id}
GET /farms/{farm_id}/fields
POST /farms/{farm_id}/fields
GET /crops
POST /crops
```

Adapter à l’état réel du repository.

Ne crée pas un endpoint artificiel uniquement pour satisfaire cette liste.

---

## 4. Créer le mode démonstration

Ajouter une configuration centralisée :

```env
DEMO_MODE=true
AI_MODE=mock
VISION_MODE=mock
AUTH_MODE=mock
MEDIA_STORAGE_PROVIDER=local
```

Règles :

- `DEMO_MODE=true` active les éléments visuels de démonstration ;
- `AI_MODE=mock` empêche tout appel texte réel ;
- `VISION_MODE=mock` empêche tout appel Vision réel ;
- `AUTH_MODE=mock` permet une démonstration sans Supabase ;
- `MEDIA_STORAGE_PROVIDER=local` évite S3 ;
- aucun coût externe ;
- aucune donnée réelle.

Mettre à jour :

```text
services/backend/.env.example
```

---

## 5. Créer ou finaliser MockAuthProvider

Le mode auth mock doit permettre :

- connexion avec un compte fictif ;
- restauration de session locale de démonstration ;
- déconnexion ;
- accès aux routes privées ;
- isolation logique d’un utilisateur de démonstration ;
- aucun appel Supabase réel.

Compte de démonstration recommandé :

```text
email: agriculteur.demo@agrivito.local
password: DemoAgrivito123!
```

Ce compte est fictif.

Ne jamais utiliser ce mot de passe dans un environnement réel.

---

## 6. Supporter Supabase réel si configuré

Si les variables suivantes existent :

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

le mobile peut utiliser Supabase Auth réel.

Sinon :

```text
AUTH_MODE=mock
```

Le mode utilisé doit être visible.

Ne bloque pas la démonstration si Supabase n’est pas configuré.

---

## 7. Créer les données de démonstration

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

Ajouter aussi :

- une question agricole de démonstration ;
- une réponse texte mockée ;
- une photo de test non privée ;
- un diagnostic photo mocké ;
- un Trust Score moyen ;
- un Trust Score élevé ;
- un cas de photo insuffisante.

Les données peuvent être chargées via :

```text
seed script
fixtures
service de démonstration
```

Choisir la solution la plus simple.

---

## 8. Écran d’accueil

L’écran d’accueil doit clairement contenir :

```text
Agrivito
description courte
Essayer sans compte
Se connecter
Créer un compte
Poser une question
Analyser une photo
Mode démonstration
```

Texte recommandé :

```text
Agrivito vous aide à mieux comprendre les problèmes agricoles grâce à vos questions, vos photos et votre contexte de culture.
```

Ne pas surcharger l’écran.

---

## 9. Indicateur de démonstration

Afficher discrètement :

```text
Mode démonstration
```

Aux endroits utiles :

- accueil ;
- diagnostic texte ;
- diagnostic photo ;
- profil si auth mock.

Ne jamais présenter une réponse mockée comme réelle.

---

## 10. Harmonisation visuelle minimale

Corriger uniquement :

- tailles de titres incohérentes ;
- boutons non alignés ;
- espacements gênants ;
- messages techniques incompréhensibles ;
- erreurs non traduites ;
- chargements absents ;
- cartes de Trust Score difficiles à lire ;
- couleurs d’état incohérentes ;
- libellés AgriAI encore visibles.

Ne pas refaire toute l’interface.

---

## 11. Chat de démonstration

Le mode découverte doit permettre :

- ouvrir le chat ;
- poser une question ;
- recevoir une réponse mockée ;
- afficher résumé ;
- afficher observations ;
- afficher hypothèses ;
- afficher recommandations ;
- afficher précautions ;
- afficher Trust Score ;
- afficher l’indication de démonstration.

Question de démonstration recommandée :

```text
Les feuilles de mes tomates jaunissent, que dois-je vérifier ?
```

---

## 12. Upload photo de démonstration

Vérifier :

- sélection d’un fichier ;
- prévisualisation ;
- upload local ;
- confirmation ;
- navigation vers diagnostic photo ;
- erreur fichier invalide ;
- erreur taille ;
- message de démonstration.

Sur Flutter Web, la caméra n’est pas obligatoire.

---

## 13. Diagnostic photo de démonstration

Le diagnostic mock doit afficher :

- qualité de la photo ;
- observations ;
- hypothèses ;
- recommandations ;
- questions complémentaires ;
- précautions ;
- Trust Score ;
- reprise de photo si nécessaire ;
- mode démonstration.

Prévoir au minimum trois scénarios :

```text
photo_good
photo_poor
photo_unusable
```

---

## 14. Parcours agricole

Le parcours authentifié ou mock doit permettre :

```text
Créer ou afficher le profil agricole
Créer une exploitation
Créer une parcelle
Créer une culture
Associer la culture à la parcelle si disponible
```

Les formulaires doivent :

- être accessibles ;
- afficher validation ;
- afficher succès ;
- afficher erreurs compréhensibles ;
- éviter les champs techniques inutiles.

---

## 15. Navigation

Vérifier :

- accueil vers découverte ;
- accueil vers connexion ;
- accueil vers inscription ;
- chat vers résultat ;
- upload vers diagnostic photo ;
- profil vers exploitation ;
- exploitation vers parcelles ;
- parcelle vers cultures ;
- déconnexion vers accueil.

Corriger toute route cassée.

---

## 16. Créer scripts/start-demo.sh

Créer :

```text
scripts/start-demo.sh
```

Le script doit :

1. détecter le répertoire du projet ;
2. vérifier Python ;
3. vérifier Flutter ;
4. vérifier les fichiers nécessaires ;
5. créer ou réutiliser l’environnement virtuel ;
6. installer les dépendances si nécessaire ;
7. vérifier la configuration PostgreSQL ;
8. appliquer les migrations ;
9. activer les modes mock ;
10. démarrer FastAPI ;
11. démarrer Flutter Web ;
12. afficher les URLs ;
13. afficher le compte de démonstration ;
14. afficher comment arrêter.

Commande cible :

```bash
./scripts/start-demo.sh
```

Le script doit être :

- lisible ;
- commenté ;
- idempotent autant que possible ;
- compatible macOS/Linux ;
- sans secret ;
- sans appel payant.

---

## 17. Créer scripts/stop-demo.sh

Créer si nécessaire :

```text
scripts/stop-demo.sh
```

Il doit arrêter uniquement les processus démarrés par la démonstration.

Ne pas tuer arbitrairement tous les processus Python ou Flutter de la machine.

---

## 18. URLs attendues

Afficher clairement :

```text
Flutter Web : http://localhost:<port>
Backend : http://127.0.0.1:8000
Swagger : http://127.0.0.1:8000/docs
Health : http://127.0.0.1:8000/health
```

Le port Flutter peut être fixé si cela simplifie la démonstration.

---

## 19. Créer le guide

Créer :

```text
docs/32-MVP-Demo-Guide.md
```

Le guide doit être simple et court.

Contenu obligatoire :

```text
Prérequis
Mise à jour du repository
Commande de lancement
URL à ouvrir
Compte de démonstration
Parcours à tester
Mode mock
Mode Supabase réel optionnel
Arrêt
Problèmes fréquents
```

Écrire pour une personne non développeuse.

---

## 20. Créer la checklist produit

Créer :

```text
docs/33-Product-Review-Checklist.md
```

Format recommandé :

```markdown
| Élément | Statut | Commentaire |
|---|---|---|
| Accueil compréhensible | À tester | |
| Navigation simple | À tester | |
```

Éléments minimum :

```text
Accueil
Navigation
Mode découverte
Chat
Réponse diagnostic
Trust Score
Upload photo
Diagnostic photo
Inscription
Connexion
Profil agricole
Exploitation
Parcelle
Culture
Design
Messages d’erreur
Fonctions manquantes
```

Statuts autorisés :

```text
Validé
À modifier
Bloquant
À tester
```

---

## 21. README

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

Ajouter :

- commande de démonstration ;
- URLs ;
- mode mock ;
- compte fictif ;
- configuration Supabase optionnelle ;
- limites connues ;
- absence d’appels OpenAI/AWS réels.

---

## 22. Tests backend

Ajouter ou mettre à jour les tests.

Minimum :

```text
GET /health
auth mock
mode découverte
diagnostic texte mock
upload local
diagnostic photo mock
profil agricole
création exploitation
création parcelle
création culture
isolation utilisateur
aucun appel OpenAI réel
aucun appel AWS réel
DEMO_MODE visible dans la configuration
```

---

## 23. Tests Flutter

Minimum :

```text
home accessible
mode démonstration visible
navigation accueil
mode découverte
chat mock
Trust Score affiché
upload fichier
diagnostic photo mock
login mock
register mock
profil accessible
farms accessibles
fields accessibles
crops accessibles
messages erreur lisibles
déconnexion
```

Exécuter :

```bash
flutter analyze
flutter test
flutter build web
```

---

## 24. Smoke test manuel obligatoire

Exécuter réellement le parcours :

```text
1. Ouvrir Home
2. Cliquer Essayer sans compte
3. Poser une question
4. Voir la réponse
5. Vérifier le Trust Score
6. Uploader une photo
7. Lancer le diagnostic photo
8. Vérifier les observations et recommandations
9. Se connecter en mode mock ou Supabase
10. Créer un profil agricole
11. Créer une exploitation
12. Créer une parcelle
13. Créer une culture
14. Se déconnecter
```

Documenter :

```text
étape
résultat
bug éventuel
correction
statut final
```

---

## 25. Déploiement web optionnel

Un déploiement temporaire Flutter Web est autorisé uniquement si :

- gratuit ;
- simple ;
- sans secret ;
- sans coût obligatoire ;
- sans modifier l’architecture cible.

Le déploiement public n’est pas requis pour terminer le sprint.

---

## 26. CI GitHub Actions

La CI doit exécuter :

Backend :

```text
installation dépendances
migrations
pytest
AUTH_MODE=mock
AI_MODE=mock
VISION_MODE=mock
MEDIA_STORAGE_PROVIDER=local
```

Flutter :

```text
flutter pub get
flutter analyze
flutter test
flutter build web
```

Règles :

- aucun appel Supabase réel ;
- aucun appel OpenAI réel ;
- aucun appel AWS réel ;
- aucune donnée réelle ;
- tests déterministes.

---

## 27. Gestion des erreurs

Les erreurs affichées à l’utilisateur doivent être simples.

Exemples :

```text
Le backend n’est pas disponible.
Impossible de charger la page.
La photo n’a pas pu être envoyée.
Votre session a expiré.
Le mode démonstration est temporairement indisponible.
```

Ne pas afficher :

```text
stack trace
exception brute
chemin système
secret
réponse technique complète
```

---

## 28. Contraintes de sécurité

Ne jamais commiter :

- `.env` ;
- vraie clé Supabase ;
- service role key ;
- JWT ;
- mot de passe réel ;
- vraie clé OpenAI ;
- credentials AWS ;
- vraie photo privée ;
- données personnelles réelles ;
- vraie `DATABASE_URL`.

Les identifiants de démonstration doivent être clairement fictifs.

---

## 29. Contraintes de qualité

Le code doit être :

- simple ;
- lisible ;
- stable ;
- testable ;
- compréhensible ;
- cohérent avec les Sprints précédents.

Priorité :

```text
voir le produit
tester le produit
comprendre le produit
corriger les blocages
```

Ne pas privilégier :

```text
nouvelle architecture
optimisation prématurée
abstractions inutiles
nouvelles fonctionnalités
```

---

# Definition of Done

Le Sprint 8.5 est terminé uniquement si :

- Codex a utilisé exactement `codex/sprint-8-5-mvp-demo-product-review` ;
- aucun autre nom de branche n’a été utilisé ;
- `DEMO_MODE` existe ;
- `AUTH_MODE=mock` fonctionne ;
- `AI_MODE=mock` fonctionne ;
- `VISION_MODE=mock` fonctionne ;
- `MEDIA_STORAGE_PROVIDER=local` fonctionne ;
- Agrivito se lance avec une procédure simple ;
- une URL Flutter Web est fournie ;
- une URL backend est fournie ;
- une URL Swagger est fournie ;
- le compte de démonstration est documenté ;
- Home est accessible ;
- mode découverte fonctionne ;
- chat mock fonctionne ;
- Trust Score est visible ;
- upload photo fonctionne ;
- diagnostic photo mock fonctionne ;
- auth mock ou Supabase réel fonctionne ;
- profil agricole est accessible ;
- création exploitation fonctionne ;
- création parcelle fonctionne ;
- création culture fonctionne ;
- déconnexion fonctionne ;
- aucun écran blanc bloquant ;
- aucune navigation principale cassée ;
- mode démonstration visible ;
- `scripts/start-demo.sh` existe ;
- `scripts/stop-demo.sh` existe si nécessaire ;
- `docs/32-MVP-Demo-Guide.md` existe ;
- `docs/33-Product-Review-Checklist.md` existe ;
- tests backend passent ;
- tests Flutter passent ;
- build Flutter Web passe ;
- smoke test manuel est documenté ;
- CI est verte ;
- aucun appel payant réel n’est obligatoire ;
- aucun secret n’est présent dans Git ;
- les Sprints 1 à 8 restent fonctionnels ;
- aucune fonctionnalité hors périmètre n’est ajoutée.

---

# Validation obligatoire

Exécuter au minimum :

```bash
git diff --check
```

Backend :

```bash
cd services/backend
source .venv/bin/activate
export DEMO_MODE=true
export AUTH_MODE=mock
export AI_MODE=mock
export VISION_MODE=mock
export MEDIA_STORAGE_PROVIDER=local
alembic upgrade head
pytest
```

Flutter :

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter test
flutter build web
```

Démonstration :

```bash
./scripts/start-demo.sh
```

Puis exécuter le smoke test manuel.

---

# Pull Request attendue

Créer une Pull Request depuis :

```text
codex/sprint-8-5-mvp-demo-product-review
```

vers :

```text
main
```

Titre :

```text
Sprint 8.5 - MVP demo and product review
```

Description attendue :

```markdown
## Objectif

Rendre Agrivito visible, testable et simple à lancer afin de permettre la première validation produit complète.

## Changements

- Ajout mode démonstration
- Ajout Auth mock de démonstration
- Ajout données fictives
- Ajout script start-demo
- Ajout script stop-demo si nécessaire
- Correction navigations bloquantes
- Correction écrans cassés
- Harmonisation visuelle minimale
- Ajout indicateur Mode démonstration
- Ajout guide MVP Demo
- Ajout checklist Product Review
- Vérification parcours découverte
- Vérification parcours authentifié
- Mise à jour tests
- Mise à jour README
- Maintien des Sprints 1 à 8

## Tests réalisés

- pytest
- flutter analyze
- flutter test
- flutter build web
- alembic upgrade head
- smoke test manuel
- git diff --check

## Démonstration

- URL Flutter Web :
- URL backend :
- URL Swagger :
- Compte de démonstration :
- Commande de lancement :

## Limites connues

- Réponses IA en mode mock
- Analyse photo en mode mock
- Auth mock possible sans Supabase
- Pas d’historique complet
- Pas de voix
- Pas de déploiement AWS
- Déploiement web public optionnel

## Documents respectés

- docs/29-Sprint-7-Plan.md
- docs/30-Sprint-8-Plan.md
- docs/31-Sprint-8-5-Plan.md
- docs/32-MVP-Demo-Guide.md
- docs/33-Product-Review-Checklist.md
- prompts/PROMPT-CODEX-SPRINT-8-5.md
```

---

# Rapport final attendu

À la fin, fournir exactement :

```text
branche utilisée
commandes de lancement
URL Flutter Web
URL backend
URL Swagger
compte de démonstration
mode auth utilisé
parcours testé
écrans fonctionnels
écrans incomplets
bugs corrigés
tests backend
tests Flutter
résultat build web
résultat smoke test
résultat CI
limites connues
URL de la Pull Request
```

Ne merge pas la Pull Request.

Attends la validation CTO.