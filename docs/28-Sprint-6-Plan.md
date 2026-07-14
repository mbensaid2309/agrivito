---
title: Sprint 6 Plan
version: 1.0
status: Approved
owner: CTO
approved_by: CEO
last_updated: 2026-07-14
---

# Agrivito - Sprint 6 Plan

## 1. Nom du Sprint

**Sprint 6 - Photo Upload Foundation**

---

## 2. Objectif

Le Sprint 6 doit permettre à l’utilisateur de capturer ou sélectionner une photo depuis l’application Flutter, de la prévisualiser, de l’envoyer au backend FastAPI, de valider le fichier, de stocker le média via une abstraction de stockage et d’enregistrer ses métadonnées dans PostgreSQL.

Le Sprint 6 prépare le futur diagnostic photo sans encore implémenter l’analyse par OpenAI Vision.

---

## 3. Valeur produit

À la fin du Sprint 6, un agriculteur doit pouvoir :

- prendre une photo depuis son téléphone ;
- choisir une photo dans sa galerie ;
- prévisualiser la photo avant envoi ;
- associer la photo à une culture, une parcelle ou une session découverte ;
- envoyer la photo à Agrivito ;
- recevoir une confirmation claire ;
- retrouver les métadonnées du média côté backend ;
- être informé si le fichier est invalide, trop volumineux ou non supporté.

Le Sprint 6 constitue la fondation technique nécessaire au diagnostic photo du Sprint 7.

---

## 4. Architecture cible Sprint 6

```text
Application Flutter
        |
        | multipart/form-data
        v
Backend FastAPI
        |
        +--> Validation fichier
        |
        +--> Media Storage Provider
        |        |
        |        +--> LocalMediaStorage
        |        |
        |        +--> S3MediaStorage
        |
        v
PostgreSQL
Table media
```

Règles obligatoires :

- Flutter ne communique jamais directement avec AWS S3 ;
- seul le backend FastAPI décide où stocker le média ;
- le stockage doit être abstrait par une interface ;
- le développement local et la CI utilisent un stockage local ou mocké ;
- le provider S3 doit être préparé sans être obligatoire pour la CI ;
- les métadonnées sont enregistrées dans PostgreSQL ;
- aucun secret AWS ne doit être présent dans Flutter ;
- aucun appel AWS réel ne doit être effectué dans la CI.

---

## 5. Contexte actuel

Les Sprints précédents ont livré :

- backend FastAPI, Flutter, healthcheck et CI ;
- mode découverte avec limite de trois questions ;
- profil agricole, exploitations, parcelles et cultures ;
- PostgreSQL, SQLAlchemy, Alembic et persistance ;
- diagnostic texte IA, AI Orchestrator, OpenAIProvider, MockAIProvider et Trust Score.

Limites actuelles :

- aucune photo réelle n’est envoyée ;
- aucun média n’est stocké ;
- aucune table `media` n’existe ;
- aucun provider de stockage n’existe ;
- aucune capture photo réelle n’est intégrée dans Flutter ;
- aucun diagnostic photo n’existe.

---

## 6. Périmètre Sprint 6

Le Sprint 6 couvre :

1. table PostgreSQL `media` ;
2. migration Alembic ;
3. modèle SQLAlchemy `Media` ;
4. schémas Pydantic médias ;
5. `MediaStorageProvider` ;
6. `LocalMediaStorage` ;
7. préparation de `S3MediaStorage` ;
8. configuration du provider ;
9. endpoint d’upload photo ;
10. validation MIME et taille ;
11. génération d’identifiant et de clé sécurisée ;
12. persistance des métadonnées ;
13. associations optionnelles au contexte agricole ;
14. lecture des métadonnées ;
15. capture et sélection d’image Flutter ;
16. prévisualisation ;
17. upload multipart ;
18. gestion des permissions et erreurs ;
19. tests backend et Flutter ;
20. CI sans AWS réel ;
21. mise à jour des README ;
22. maintien des Sprints 1 à 5.

---

## 7. Hors périmètre strict

Ne pas développer :

- OpenAI Vision ;
- diagnostic photo ;
- reconnaissance de maladie ;
- analyse d’image ;
- comparaison de plusieurs photos ;
- traitement d’image complexe ;
- OCR ;
- Cognito réel ;
- Supabase Storage ;
- upload direct Flutter vers S3 ;
- URL pré-signée ;
- déploiement AWS ;
- Lambda, Step Functions ou files d’attente ;
- RAG ou pgvector ;
- Sprint 7.

---

## 8. Architecture de stockage

Créer une abstraction :

```python
class MediaStorageProvider:
    def save(self, file, object_key, content_type):
        ...

    def delete(self, object_key):
        ...

    def exists(self, object_key):
        ...
```

Implémentations :

```text
LocalMediaStorage
S3MediaStorage
```

`LocalMediaStorage` est utilisé en développement, en tests et en CI.

`S3MediaStorage` prépare la cible AWS sans rendre AWS obligatoire dans ce sprint.

---

## 9. Configuration

Ajouter :

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

Mettre à jour `services/backend/.env.example` uniquement avec des valeurs fictives.

Règles :

- `local` par défaut ;
- `s3` uniquement si la configuration AWS est complète ;
- aucune variable AWS obligatoire en mode local ;
- le dossier local doit être configurable et ignoré par Git ;
- aucun secret dans Flutter ou Git.

---

## 10. Dépendances backend

Ajouter uniquement si nécessaire :

```text
python-multipart
boto3
```

Ne pas ajouter de SDK Supabase ni de framework de stockage supplémentaire.

---

## 11. Structure backend recommandée

```text
services/backend/app/
├── api/media.py
├── models/media.py
├── schemas/media.py
├── services/media_service.py
└── storage/
    ├── provider.py
    ├── local_storage.py
    ├── s3_storage.py
    └── exceptions.py
```

Une structure équivalente simple est acceptable.

---

## 12. Modèle PostgreSQL Media

Créer la table :

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

Champs optionnels :

```text
width
height
checksum
```

Règles :

- clé primaire sur `id` ;
- `storage_key` obligatoire et unique ;
- aucune donnée binaire dans PostgreSQL ;
- relations optionnelles ;
- clés étrangères cohérentes ;
- métadonnées uniquement en base.

---

## 13. Statuts média

```text
uploaded
failed
deleted
```

Le statut normal après succès est `uploaded`.

---

## 14. Migration Alembic

Créer une migration qui :

- crée la table `media` ;
- ajoute la clé primaire ;
- ajoute les clés étrangères utiles ;
- rend `storage_key` unique ;
- ajoute les index utiles ;
- supporte un downgrade propre ;
- ne modifie pas les tables agricoles existantes.

Commandes à valider :

```bash
alembic upgrade head
alembic downgrade -1
alembic upgrade head
```

---

## 15. Endpoint d’upload

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

Réponse minimale :

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
- validation MIME et taille ;
- identifiant et clé générés côté backend ;
- nom fourni non fiable ;
- stockage puis persistance des métadonnées ;
- suppression du fichier si la DB échoue ;
- aucune métadonnée valide si le stockage échoue.

---

## 16. Endpoint de lecture

Créer :

```http
GET /media/{media_id}
```

Il retourne uniquement les métadonnées.

Un endpoint local de contenu peut être ajouté uniquement pour le développement :

```http
GET /media/{media_id}/content
```

Il ne doit jamais exposer un chemin système et ne doit pas créer d’accès public S3.

---

## 17. Validation des fichiers

Formats autorisés par défaut :

```text
image/jpeg
image/png
image/webp
```

Taille maximale par défaut :

```text
10 MB
```

Règles :

- refuser les fichiers vides ;
- refuser les formats non autorisés ;
- refuser les fichiers trop volumineux ;
- vérifier la taille réelle ;
- sécuriser le nom ;
- empêcher la traversée de répertoire ;
- ne jamais exécuter le fichier.

---

## 18. Clé de stockage

Format recommandé :

```text
media/YYYY/MM/<uuid>.<extension>
```

Règles :

- unicité ;
- extension dérivée du MIME validé ;
- aucune donnée personnelle ;
- aucun chemin fourni par le client ;
- compatibilité S3.

---

## 19. LocalMediaStorage

Le provider local doit :

- créer le dossier si nécessaire ;
- stocker hors du code source ;
- empêcher les traversées de chemin ;
- supporter `save`, `delete` et `exists` ;
- être testable ;
- ne pas exposer le chemin réel.

Dossier recommandé :

```text
services/backend/data/media/
```

Il doit être ignoré par Git.

---

## 20. S3MediaStorage

Le provider S3 doit :

- utiliser `boto3` ;
- lire région et bucket depuis l’environnement ;
- utiliser la chaîne standard de credentials AWS ;
- envoyer le bon `Content-Type` ;
- ne jamais rendre l’objet public ;
- gérer les erreurs AWS ;
- ne jamais logger les credentials ;
- être testé uniquement avec des mocks dans la CI.

---

## 21. Service Media

Le service doit :

1. valider les métadonnées ;
2. vérifier les ressources liées ;
3. valider le fichier ;
4. générer l’identifiant ;
5. générer la clé ;
6. appeler le provider ;
7. persister les métadonnées ;
8. gérer le rollback ;
9. supprimer le fichier si la DB échoue ;
10. retourner une réponse typée.

La route FastAPI doit rester légère.

---

## 22. Gestion des erreurs

Gérer :

- fichier absent ou vide ;
- type MIME invalide ;
- taille dépassée ;
- ressource liée inexistante ;
- incohérence farm/field ;
- erreur de stockage ;
- erreur S3 ;
- erreur disque ;
- erreur PostgreSQL ;
- média inexistant ;
- configuration invalide.

Codes recommandés :

```text
400
404
409
413
415
422
500
503
```

Ne jamais exposer chemin local, credentials, bucket sensible ou stack trace.

---

## 23. Flutter - Capture et sélection

Flutter doit permettre :

- galerie ;
- caméra ;
- prévisualisation ;
- remplacement ;
- annulation ;
- suppression de la sélection avant envoi.

Utiliser un package Flutter mature et maintenu.

---

## 24. Flutter - Permissions

Gérer :

- permission caméra ;
- permission photos ;
- refus ;
- refus permanent ;
- caméra indisponible.

Ne demander aucune permission inutile.

---

## 25. Flutter - Upload multipart

Créer ou compléter :

```text
apps/mobile/lib/services/media_api_service.dart
```

Le service doit :

- utiliser `AGRIVITO_API_BASE_URL` ;
- envoyer le fichier en multipart ;
- envoyer le contexte disponible ;
- gérer timeout, réseau et erreurs backend ;
- ne contenir aucun secret ni configuration AWS.

---

## 26. États UI

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
```

Messages recommandés :

```text
Choisissez ou prenez une photo.
Envoi en cours...
Photo envoyée avec succès.
Ce format n’est pas supporté.
La photo est trop volumineuse.
Impossible d’envoyer la photo.
```

Afficher clairement :

```text
La photo sera enregistrée. L’analyse visuelle sera disponible dans une prochaine version.
```

---

## 27. Mode découverte

Le mode découverte peut accepter une photo avec la limite :

```text
photos_limit = 1
```

Le compteur peut rester en mémoire pour ce sprint.

Aucun historique durable avancé ne doit être créé.

---

## 28. Tests backend

Tests minimum :

- healthcheck et endpoints Sprint 5 toujours fonctionnels ;
- migration `media` ;
- JPEG, PNG et WebP acceptés ;
- fichier vide, type invalide et taille excessive refusés ;
- nom dangereux neutralisé ;
- clé unique ;
- métadonnées persistées ;
- média lisible par ID ;
- relations valides acceptées ;
- relations incohérentes refusées ;
- rollback stockage/DB ;
- providers local et S3 testés ;
- aucun appel AWS réel ;
- limite découverte appliquée.

---

## 29. Tests sécurité

Tester :

- traversée de répertoire impossible ;
- `../../file.jpg` neutralisé ;
- fichier non-image refusé ;
- aucun secret dans les erreurs ;
- aucun chemin système dans les réponses ;
- aucun fichier écrit hors du dossier autorisé ;
- aucune URL publique générée.

---

## 30. Tests Flutter

Tester :

- écran photo accessible ;
- galerie et caméra mockées ;
- prévisualisation ;
- annulation et remplacement ;
- upload ;
- succès ;
- erreurs de permission, réseau, taille et format ;
- contexte envoyé ;
- multipart correct ;
- service HTTP mocké ;
- `flutter analyze` sans erreur.

---

## 31. CI GitHub Actions

Backend :

1. PostgreSQL de test ;
2. dépendances ;
3. `DATABASE_URL` de test ;
4. `MEDIA_STORAGE_PROVIDER=local` ;
5. dossier temporaire ;
6. migrations ;
7. `pytest`.

Mobile :

1. `flutter pub get` ;
2. `flutter analyze` ;
3. `flutter test`.

Aucun appel AWS réel ni secret AWS dans la CI.

---

## 32. Documentation

Mettre à jour :

```text
README.md
services/backend/README.md
apps/mobile/README.md
```

Documenter architecture média, endpoints, table `media`, providers local/S3, variables, limites, sécurité et absence de diagnostic photo réel.

---

## 33. Sécurité

Ne jamais commiter :

- `.env` ;
- `DATABASE_URL` réelle ;
- `OPENAI_API_KEY` réelle ;
- credentials AWS ;
- bucket sensible ;
- médias utilisateurs ;
- dossier `data/media` ;
- données personnelles réelles.

Avant commit :

```bash
git status
git diff --check
git check-ignore -v services/backend/.env
git check-ignore -v services/backend/data/media
```

---

## 34. Definition of Done

Le Sprint 6 est terminé uniquement si :

- la table `media` et sa migration existent ;
- le modèle SQLAlchemy et les schémas Pydantic existent ;
- `MediaStorageProvider`, `LocalMediaStorage` et `S3MediaStorage` existent ;
- `POST /media/upload` et `GET /media/{media_id}` existent ;
- JPEG, PNG et WebP sont acceptés ;
- taille et MIME sont validés ;
- noms et clés sont sécurisés ;
- métadonnées persistées ;
- rollback fichier/DB géré ;
- Flutter permet galerie, caméra, prévisualisation et upload ;
- permissions et erreurs sont gérées ;
- mode découverte limité à une photo ;
- Sprints 1 à 5 toujours fonctionnels ;
- tests backend et Flutter passent ;
- CI verte ;
- aucun appel AWS réel en CI ;
- aucun secret ni média utilisateur dans Git ;
- aucun diagnostic photo développé.

---

## 35. Branche de développement

Codex doit créer et utiliser exactement :

```text
codex/sprint-6-photo-upload-foundation
```

Règle bloquante :

```text
Aucun autre nom de branche n’est autorisé.
```

La branche doit être créée depuis le dernier `main`.

Codex ne travaille jamais directement sur `main` et ne merge jamais lui-même la Pull Request.

---

## 36. Pull Request attendue

Titre :

```text
Sprint 6 - Photo upload foundation
```

La description doit récapituler : table et migration `media`, providers local/S3, endpoints, validations, Flutter, tests, CI, limites et documents respectés.

---

## 37. Statut

**APPROVED**