# PROMPT CODEX - SPRINT 6

Tu es Lead Developer sur le projet Agrivito.

Agrivito est une plateforme intelligente d’assistance à la décision agricole.

Ton rôle est de développer le Sprint 6 du MVP en respectant strictement les documents validés dans le dossier `docs/`.

Tu ne dois prendre aucune décision d’architecture.

---

# Étape obligatoire avant de coder

Avant toute modification de code, lis intégralement :

```text
docs/08-Product-Roadmap.md
docs/09-MVP-Scope.md
docs/12-MVP-User-Stories.md
docs/13-Domain-Model.md
docs/14-Quality-Reliability-Framework.md
docs/15-AI-Architecture.md
docs/16-Data-Architecture.md
docs/17-API-Design.md
docs/18-Technical-Architecture.md
docs/19-Technology-ADRs.md
docs/20-MVP-Backlog.md
docs/21-Codex-Handbook.md
docs/23-Brand-Name-Decision.md
docs/26-Sprint-4-Plan.md
docs/27-Sprint-5-Plan.md
docs/28-Sprint-6-Plan.md
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

Tu dois créer et utiliser exactement la branche suivante :

```text
codex/sprint-6-photo-upload-foundation
```

Aucun autre nom de branche n’est autorisé.

Avant toute modification :

```bash
git checkout main
git pull origin main
git checkout -b codex/sprint-6-photo-upload-foundation
```

Si une branche différente existe déjà, ne l’utilise pas.

Tu ne dois jamais travailler directement sur `main`.

Tu ne dois jamais merger toi-même la Pull Request.

---

# Nom du Sprint

```text
Sprint 6 - Photo Upload Foundation
```

---

# Objectif

Permettre à l’utilisateur de sélectionner ou prendre une photo depuis Flutter, de la prévisualiser, de l’envoyer au backend FastAPI, de la valider, de la stocker via une abstraction de stockage et d’enregistrer ses métadonnées dans PostgreSQL.

Le Sprint 6 prépare le diagnostic photo du Sprint 7.

Aucune analyse OpenAI Vision ne doit être développée dans ce sprint.

---

# Architecture obligatoire

```text
Application Flutter
        |
        | multipart/form-data
        v
Backend FastAPI
        |
        +--> Validation du fichier
        |
        +--> MediaStorageProvider
        |        |
        |        +--> LocalMediaStorage
        |        |
        |        +--> S3MediaStorage
        |
        v
PostgreSQL
Table media
```

Règles :

- Flutter ne communique jamais directement avec S3 ;
- seul FastAPI gère le stockage ;
- PostgreSQL stocke uniquement les métadonnées ;
- le fichier binaire ne doit jamais être stocké dans PostgreSQL ;
- le stockage local est utilisé pour le développement et la CI ;
- le provider S3 est préparé pour la cible AWS ;
- aucun appel AWS réel ne doit être effectué dans la CI ;
- aucun secret AWS ne doit être présent dans Flutter ou Git.

---

# Périmètre autorisé

Tu peux développer uniquement :

1. table PostgreSQL `media` ;
2. migration Alembic ;
3. modèle SQLAlchemy `Media` ;
4. schémas Pydantic médias ;
5. abstraction `MediaStorageProvider` ;
6. `LocalMediaStorage` ;
7. `S3MediaStorage` ;
8. configuration du stockage ;
9. endpoint `POST /media/upload` ;
10. endpoint `GET /media/{media_id}` ;
11. validation MIME ;
12. validation de taille ;
13. génération d’identifiant unique ;
14. génération d’une clé de stockage sécurisée ;
15. persistance des métadonnées ;
16. rollback stockage / base ;
17. association optionnelle à un utilisateur ;
18. association optionnelle à une ferme ;
19. association optionnelle à une parcelle ;
20. association optionnelle à une culture ;
21. association optionnelle à une session découverte ;
22. sélection d’image Flutter ;
23. capture caméra Flutter ;
24. prévisualisation ;
25. upload multipart ;
26. gestion des permissions ;
27. gestion des erreurs ;
28. tests backend ;
29. tests Flutter ;
30. CI sans AWS réel ;
31. mise à jour des README ;
32. maintien des Sprints 1 à 5.

---

# Hors périmètre strict

Ne pas développer :

- OpenAI Vision ;
- diagnostic photo ;
- analyse d’image ;
- reconnaissance de maladie ;
- comparaison de photos ;
- OCR ;
- détection d’objet ;
- URL pré-signée ;
- upload direct Flutter vers S3 ;
- Cognito réel ;
- Supabase Storage ;
- traitement asynchrone ;
- file d’attente ;
- Lambda ;
- Step Functions ;
- historique avancé ;
- RAG ;
- pgvector ;
- météo ;
- marketplace ;
- IoT ;
- drone ;
- satellite ;
- déploiement AWS ;
- Sprint 7.

Ne pas introduire :

- microservice média ;
- Kubernetes ;
- EKS ;
- Firebase ;
- MongoDB ;
- DynamoDB ;
- SDK Supabase Storage ;
- framework non validé.

---

# Travail demandé

## 1. Vérifier le socle existant

Vérifier que ces éléments existent :

```text
services/backend/
apps/mobile/
.github/workflows/
README.md
```

Vérifier que les endpoints existants restent fonctionnels :

```http
GET /health
POST /discovery/question
POST /ai/diagnosis

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

Ne casse pas les Sprints 1 à 5.

---

## 2. Ajouter la configuration média

Ajouter dans la configuration backend :

```env
MEDIA_STORAGE_PROVIDER=local
MEDIA_LOCAL_PATH=./data/media
MEDIA_MAX_SIZE_MB=10
MEDIA_ALLOWED_MIME_TYPES=image/jpeg,image/png,image/webp

AWS_REGION=
AWS_S3_BUCKET=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```

Mettre à jour :

```text
services/backend/.env.example
```

Règles :

- `MEDIA_STORAGE_PROVIDER=local` par défaut ;
- le mode local ne doit exiger aucun secret AWS ;
- le mode S3 doit échouer clairement si la configuration est incomplète ;
- aucune vraie valeur sensible ne doit être ajoutée ;
- le dossier local doit être configurable ;
- le dossier média local doit rester ignoré par Git.

---

## 3. Ajouter les dépendances nécessaires

Mettre à jour :

```text
services/backend/requirements.txt
```

Ajouter uniquement si nécessaire :

```text
python-multipart
boto3
```

Ne pas ajouter de dépendance inutile.

---

## 4. Créer le modèle Media

Créer un modèle SQLAlchemy pour la table :

```text
media
```

Champs minimum :

```text
id
user_id
discovery_session_id
farm_id
field_id
crop_id
storage_provider
storage_key
original_filename
content_type
size_bytes
status
created_at
updated_at
```

Champs optionnels acceptés :

```text
width
height
checksum
```

Contraintes :

- `id` clé primaire ;
- `storage_key` obligatoire et unique ;
- `content_type` obligatoire ;
- `size_bytes` obligatoire ;
- `storage_provider` obligatoire ;
- aucune donnée binaire en base ;
- relations optionnelles ;
- clés étrangères cohérentes ;
- pas de cascade destructive automatique.

---

## 5. Créer la migration Alembic

Créer une nouvelle migration après la dernière migration existante.

Elle doit :

- créer la table `media` ;
- créer les clés étrangères utiles ;
- créer les index utiles ;
- ajouter l’unicité sur `storage_key` ;
- supporter un downgrade propre ;
- ne modifier aucune table existante de manière destructive.

Valider :

```bash
cd services/backend
alembic upgrade head
alembic downgrade -1
alembic upgrade head
```

---

## 6. Créer les schémas Pydantic

Créer les schémas médias dans un fichier dédié.

Schémas recommandés :

```text
MediaResponse
MediaMetadata
MediaUploadResponse
MediaStatus
```

Le statut doit supporter au minimum :

```text
uploaded
failed
deleted
```

---

## 7. Créer MediaStorageProvider

Créer une abstraction simple.

Interface conceptuelle :

```python
class MediaStorageProvider:
    def save(self, file, object_key, content_type):
        ...

    def delete(self, object_key):
        ...

    def exists(self, object_key):
        ...
```

L’implémentation métier ne doit pas dépendre directement de `boto3` ou du système de fichiers.

---

## 8. Créer LocalMediaStorage

Le provider local doit :

- créer le dossier si nécessaire ;
- utiliser le chemin configuré ;
- empêcher toute traversée de répertoire ;
- enregistrer uniquement sous la clé générée ;
- supporter `save` ;
- supporter `delete` ;
- supporter `exists` ;
- ne jamais retourner le chemin système complet ;
- être utilisable dans les tests et la CI.

Dossier recommandé :

```text
services/backend/data/media/
```

Ce dossier doit être ignoré par Git.

---

## 9. Créer S3MediaStorage

Le provider S3 doit :

- utiliser `boto3` ;
- lire la région et le bucket depuis l’environnement ;
- utiliser la chaîne standard de credentials AWS ;
- envoyer le bon `Content-Type` ;
- stocker les objets en privé ;
- ne générer aucune URL publique ;
- gérer les erreurs AWS ;
- convertir les erreurs en exceptions internes ;
- ne jamais logger les credentials ;
- être testable avec des mocks.

Aucun appel AWS réel dans la CI.

---

## 10. Générer une clé de stockage sécurisée

Format recommandé :

```text
media/YYYY/MM/<uuid>.<extension>
```

Exemple :

```text
media/2026/07/550e8400-e29b-41d4-a716-446655440000.jpg
```

Règles :

- clé unique ;
- extension dérivée du MIME validé ;
- aucune donnée personnelle ;
- aucun chemin fourni par l’utilisateur ;
- aucun nom d’utilisateur ;
- aucune traversée de répertoire ;
- structure compatible S3.

---

## 11. Valider les fichiers

Formats autorisés :

```text
image/jpeg
image/png
image/webp
```

Taille maximale :

```text
10 MB
```

Le backend doit :

- refuser un fichier vide ;
- vérifier la taille réelle ;
- vérifier le `Content-Type` ;
- refuser un type non autorisé ;
- neutraliser un nom dangereux ;
- ne jamais exécuter le fichier ;
- ne jamais utiliser le chemin fourni par l’utilisateur ;
- ne jamais accepter de traversée de répertoire.

---

## 12. Créer le service Media

Créer un service responsable de :

1. vérifier les relations optionnelles ;
2. valider le fichier ;
3. générer l’identifiant ;
4. générer la clé de stockage ;
5. enregistrer le fichier ;
6. persister les métadonnées ;
7. gérer les erreurs ;
8. supprimer le fichier si la transaction DB échoue ;
9. éviter une métadonnée valide si le stockage échoue ;
10. retourner une réponse typée.

La route doit rester légère.

---

## 13. Créer l’endpoint d’upload

Créer :

```http
POST /media/upload
```

Type :

```text
multipart/form-data
```

Champs :

```text
file
user_id optional
discovery_session_id optional
farm_id optional
field_id optional
crop_id optional
```

Réponse attendue :

```json
{
  "media": {
    "id": "uuid",
    "original_filename": "tomate.jpg",
    "content_type": "image/jpeg",
    "size_bytes": 245678,
    "storage_provider": "local",
    "status": "uploaded",
    "farm_id": null,
    "field_id": null,
    "crop_id": null,
    "created_at": "2026-07-14T12:00:00Z"
  }
}
```

Règles :

- fichier obligatoire ;
- validation avant persistance ;
- stockage avant validation finale DB ;
- rollback cohérent ;
- aucun contenu binaire dans la réponse ;
- aucune URL publique.

---

## 14. Créer l’endpoint de métadonnées

Créer :

```http
GET /media/{media_id}
```

Il doit :

- retourner uniquement les métadonnées ;
- retourner 404 si le média n’existe pas ;
- ne pas retourner le chemin local ;
- ne pas retourner de credentials ;
- ne pas générer d’URL publique.

---

## 15. Endpoint de contenu local optionnel

Un endpoint local peut être créé :

```http
GET /media/{media_id}/content
```

Uniquement si cela est utile au développement local.

Règles :

- disponible uniquement avec `MEDIA_STORAGE_PROVIDER=local` ;
- utiliser `media_id` ;
- ne jamais accepter un chemin libre ;
- retourner le bon `Content-Type` ;
- ne pas exposer le chemin système ;
- ne pas implémenter d’accès public S3.

---

## 16. Vérifier les relations agricoles

Si un identifiant est fourni :

- vérifier que la ferme existe ;
- vérifier que la parcelle existe ;
- vérifier que la culture existe ;
- vérifier la cohérence entre ferme et parcelle ;
- refuser les relations incohérentes ;
- ne pas rendre les relations obligatoires.

---

## 17. Gérer le mode découverte

Le mode découverte doit permettre :

```text
photos_limit = 1
```

Règles :

- upload possible sans compte ;
- compteur simple ;
- pas d’historique avancé ;
- invitation à créer un compte après la limite ;
- pas d’accès aux médias d’un autre utilisateur ;
- compteur centralisé dans le service ou la configuration.

Le compteur peut rester en mémoire pour le Sprint 6.

---

## 18. Intégrer Flutter

L’application doit permettre :

- choisir une photo dans la galerie ;
- prendre une photo avec la caméra ;
- annuler ;
- prévisualiser ;
- remplacer la photo ;
- supprimer la sélection ;
- envoyer le fichier ;
- associer le contexte disponible ;
- afficher l’état d’upload ;
- afficher une confirmation ;
- afficher les erreurs.

Utiliser un package Flutter mature et maintenu.

Ne pas ajouter plusieurs packages pour la même fonction.

---

## 19. Gérer les permissions Flutter

Gérer :

- permission caméra ;
- permission galerie/photos ;
- refus simple ;
- refus permanent ;
- caméra indisponible.

Messages simples :

```text
Autorisez l’accès à la caméra pour prendre une photo.
Autorisez l’accès aux photos pour choisir une image.
```

Ne pas demander de permission inutile.

---

## 20. Créer le service Flutter média

Créer ou compléter :

```text
apps/mobile/lib/services/media_api_service.dart
```

Le service doit :

- utiliser `AGRIVITO_API_BASE_URL` ;
- envoyer le fichier en multipart ;
- envoyer les identifiants disponibles ;
- gérer le timeout ;
- gérer les erreurs réseau ;
- gérer les erreurs backend ;
- ne contenir aucun secret ;
- ne contenir aucune configuration AWS.

---

## 21. États UI Flutter

Gérer exactement les états nécessaires :

```text
idle
selecting
preview
uploading
success
validation_error
permission_error
network_error
backend_error
discovery_limit_reached
```

Messages recommandés :

```text
Choisissez ou prenez une photo.
Envoi en cours...
Photo envoyée avec succès.
Ce format n’est pas supporté.
La photo est trop volumineuse.
Impossible d’envoyer la photo.
Vous avez atteint la limite du mode découverte.
```

---

## 22. UX

L’écran doit inclure :

- bouton caméra ;
- bouton galerie ;
- zone de prévisualisation ;
- bouton envoyer ;
- bouton remplacer ;
- bouton annuler ;
- message d’état ;
- contexte agricole optionnel.

Afficher clairement :

```text
La photo sera enregistrée. L’analyse visuelle sera disponible dans une prochaine version.
```

Aucun diagnostic ne doit être affiché.

---

## 23. Gestion des erreurs backend

Gérer :

- fichier absent ;
- fichier vide ;
- type MIME invalide ;
- taille dépassée ;
- ressource inexistante ;
- incohérence farm / field ;
- erreur disque ;
- erreur S3 ;
- erreur PostgreSQL ;
- configuration invalide ;
- média inexistant.

Codes recommandés :

```text
400 Bad Request
404 Not Found
409 Conflict
413 Payload Too Large
415 Unsupported Media Type
422 Unprocessable Entity
500 Internal Server Error
503 Service Unavailable
```

Ne jamais exposer :

- chemin local complet ;
- credentials AWS ;
- stack trace ;
- configuration interne ;
- bucket sensible.

---

## 24. Logs

Autorisé :

```text
request_id
media_id
storage_provider
content_type
size_bytes
duration
success
failure
error_type
```

Interdit :

```text
contenu du fichier
credentials AWS
chemin système complet
DATABASE_URL
OPENAI_API_KEY
données personnelles complètes
```

---

## 25. Tests backend

Ajouter ou mettre à jour les tests.

Tests minimum :

```text
GET /health reste fonctionnel
POST /ai/diagnosis reste fonctionnel
POST /media/upload avec JPEG
POST /media/upload avec PNG
POST /media/upload avec WebP
fichier vide refusé
type invalide refusé
fichier trop volumineux refusé
nom dangereux neutralisé
storage_key unique
métadonnées persistées
GET /media/{id} fonctionne
média inexistant retourne 404
farm valide acceptée
field valide acceptée
crop valide acceptée
ressource inexistante refusée
farm/field incohérents refusés
erreur stockage => pas de métadonnée valide
erreur DB => suppression du fichier si possible
LocalMediaStorage save/delete/exists
S3MediaStorage avec mocks
aucun appel AWS réel
mode découverte limité à une photo
migrations fonctionnelles
endpoints Sprints 1 à 5 toujours fonctionnels
```

---

## 26. Tests de sécurité backend

Tester :

```text
../../file.jpg neutralisé
traversée de répertoire impossible
fichier non-image refusé
aucun fichier hors dossier autorisé
aucune clé AWS dans les erreurs
aucun chemin système dans les réponses
aucune URL publique générée
```

---

## 27. Tests Flutter

Tests minimum :

```text
écran photo accessible
sélection galerie mockée
capture caméra mockée
prévisualisation affichée
annulation fonctionne
remplacement fonctionne
état uploading affiché
succès affiché
erreur permission affichée
erreur réseau affichée
type invalide affiché
fichier trop volumineux affiché
contexte agricole envoyé si disponible
multipart construit correctement
service HTTP mocké
flutter analyze sans erreur
```

---

## 28. CI GitHub Actions

Backend :

1. démarrer PostgreSQL ;
2. installer les dépendances ;
3. définir `DATABASE_URL` de test ;
4. définir `MEDIA_STORAGE_PROVIDER=local` ;
5. définir un dossier temporaire ;
6. exécuter `alembic upgrade head` ;
7. exécuter `pytest`.

Mobile :

1. installer Flutter ;
2. exécuter `flutter pub get` ;
3. exécuter `flutter analyze` ;
4. exécuter `flutter test`.

Règles :

- aucun appel AWS réel ;
- aucun bucket réel ;
- aucun secret AWS ;
- stockage local temporaire ;
- nettoyage après tests.

---

## 29. Documentation

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

Documenter :

- objectif Sprint 6 ;
- architecture média ;
- table `media` ;
- endpoint `POST /media/upload` ;
- endpoint `GET /media/{media_id}` ;
- LocalMediaStorage ;
- S3MediaStorage ;
- variables d’environnement ;
- formats supportés ;
- taille maximale ;
- lancement local ;
- tests ;
- sécurité ;
- limites connues ;
- absence de diagnostic photo.

---

## 30. Validation backend

Exécuter :

```bash
cd services/backend

python3 -m venv .venv
source .venv/bin/activate

pip install -r requirements.txt

alembic upgrade head
alembic downgrade -1
alembic upgrade head

export MEDIA_STORAGE_PROVIDER=local
export MEDIA_LOCAL_PATH=./data/media

pytest

uvicorn app.main:app --reload
```

Vérifier :

```text
http://127.0.0.1:8000/health
http://127.0.0.1:8000/docs
```

---

## 31. Validation Flutter

Exécuter :

```bash
cd apps/mobile

flutter pub get
flutter analyze
flutter test

flutter run \
  --dart-define=AGRIVITO_API_BASE_URL=http://127.0.0.1:8000
```

Android Emulator :

```bash
flutter run \
  --dart-define=AGRIVITO_API_BASE_URL=http://10.0.2.2:8000
```

---

# Contraintes de sécurité

Ne jamais commiter :

- `.env` ;
- vraie `DATABASE_URL` ;
- vraie `OPENAI_API_KEY` ;
- `AWS_ACCESS_KEY_ID` ;
- `AWS_SECRET_ACCESS_KEY` ;
- vrai bucket sensible ;
- token ;
- credentials ;
- fichiers médias utilisateurs ;
- dossier `data/media`.

Avant chaque commit :

```bash
git status
git diff --check
git check-ignore -v services/backend/.env
git check-ignore -v services/backend/data/media
```

---

# Contraintes de qualité

Le code doit être :

- simple ;
- lisible ;
- typé ;
- maintenable ;
- testable ;
- cohérent avec les documents approuvés ;
- cohérent avec les Sprints précédents.

Ne pas sur-concevoir.

Ne pas créer de microservice.

Ne pas ajouter de traitement asynchrone.

Ne pas développer le diagnostic photo.

---

# Definition of Done

Le Sprint 6 est terminé uniquement si :

- Codex a utilisé exactement `codex/sprint-6-photo-upload-foundation` ;
- aucun autre nom de branche n’a été utilisé ;
- la table `media` existe ;
- la migration Alembic fonctionne ;
- le modèle SQLAlchemy `Media` existe ;
- les schémas Pydantic existent ;
- `MediaStorageProvider` existe ;
- `LocalMediaStorage` existe ;
- `S3MediaStorage` existe ;
- `POST /media/upload` existe ;
- `GET /media/{media_id}` existe ;
- JPEG, PNG et WebP sont acceptés ;
- les fichiers invalides sont refusés ;
- la limite de taille est appliquée ;
- les noms sont sécurisés ;
- les clés sont uniques ;
- les métadonnées sont persistées ;
- le rollback fichier / DB est géré ;
- Flutter permet la galerie ;
- Flutter permet la caméra ;
- Flutter affiche la prévisualisation ;
- Flutter envoie en multipart ;
- les permissions sont gérées ;
- les erreurs sont gérées ;
- le mode découverte accepte une photo limitée ;
- les Sprints 1 à 5 fonctionnent toujours ;
- les tests backend passent ;
- les tests Flutter passent ;
- GitHub Actions est vert ;
- aucun appel AWS réel n’est effectué dans la CI ;
- aucun secret n’est présent dans Git ;
- aucun média utilisateur n’est commité ;
- aucun diagnostic photo n’est développé ;
- aucune technologie interdite n’est ajoutée.

---

# Pull Request attendue

Créer une Pull Request depuis :

```text
codex/sprint-6-photo-upload-foundation
```

vers :

```text
main
```

Titre :

```text
Sprint 6 - Photo upload foundation
```

Description attendue :

```markdown
## Objectif

Ajouter la capture, la sélection, l’upload et la persistance des métadonnées photo Agrivito, avec abstraction de stockage local/S3.

## Changements

- Ajout table media
- Ajout migration Alembic
- Ajout modèle SQLAlchemy Media
- Ajout schémas Pydantic médias
- Ajout MediaStorageProvider
- Ajout LocalMediaStorage
- Ajout S3MediaStorage
- Ajout endpoint POST /media/upload
- Ajout endpoint GET /media/{media_id}
- Ajout validation MIME et taille
- Ajout génération de clés sécurisées
- Ajout persistance des métadonnées
- Ajout rollback stockage / base
- Ajout sélection photo Flutter
- Ajout capture caméra Flutter
- Ajout prévisualisation
- Ajout upload multipart
- Ajout gestion des permissions et erreurs
- Ajout tests backend
- Ajout tests Flutter
- Mise à jour CI
- Mise à jour README
- Maintien des Sprints 1 à 5

## Tests réalisés

- pytest
- flutter analyze
- flutter test
- alembic upgrade head
- alembic downgrade -1
- git diff --check

## Limites connues

- Pas de diagnostic photo
- Pas d'OpenAI Vision
- Pas d'URL pré-signée
- Pas d'upload direct Flutter vers S3
- Pas de Cognito réel
- Pas de déploiement AWS
- Stockage local utilisé en développement et CI

## Documents respectés

- docs/08-Product-Roadmap.md
- docs/09-MVP-Scope.md
- docs/12-MVP-User-Stories.md
- docs/13-Domain-Model.md
- docs/14-Quality-Reliability-Framework.md
- docs/15-AI-Architecture.md
- docs/16-Data-Architecture.md
- docs/17-API-Design.md
- docs/18-Technical-Architecture.md
- docs/19-Technology-ADRs.md
- docs/20-MVP-Backlog.md
- docs/21-Codex-Handbook.md
- docs/23-Brand-Name-Decision.md
- docs/26-Sprint-4-Plan.md
- docs/27-Sprint-5-Plan.md
- docs/28-Sprint-6-Plan.md
- prompts/PROMPT-CODEX-SPRINT-6.md
```

---

# Rapport final attendu

À la fin, fournir :

```text
branche utilisée
fichiers créés
fichiers modifiés
migration créée
table créée
provider local créé
provider S3 créé
endpoints créés
tests backend exécutés
tests Flutter exécutés
résultat migrations
résultat CI
limites connues
URL de la Pull Request
```

Ne merge pas la Pull Request.

Attends la validation CTO.