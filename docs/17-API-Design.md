---

title: API Design
version: 1.0
status: Draft
owner: CTO
approved_by: CEO
last_updated: 2026-06-28
------------------------

# AgriAI - API Design

## Objectif

Ce document définit les API logiques du MVP AgriAI.

Il ne valide pas encore le framework backend ni la technologie utilisée.

---

# Principes API

Les API doivent être :

* simples ;
* sécurisées ;
* adaptées au mobile ;
* faciles à maintenir ;
* compatibles avec les futures interfaces web ;
* conçues pour supporter le mode découverte et le mode compte.

---

# 1. Accès utilisateur

## POST /auth/register

Créer un compte utilisateur.

## POST /auth/login

Connecter un utilisateur.

## POST /auth/logout

Déconnecter un utilisateur.

## GET /me

Récupérer le profil de l'utilisateur connecté.

## PATCH /me

Modifier le profil utilisateur.

---

# 2. Mode découverte

## POST /discovery/question

Permettre à un utilisateur sans compte de poser une question limitée.

## POST /discovery/photo-diagnosis

Permettre à un utilisateur sans compte d'envoyer une photo pour un diagnostic limité.

## POST /discovery/convert-to-account

Permettre à un utilisateur de créer un compte après une session découverte.

---

# 3. Exploitations

## POST /farms

Créer une exploitation.

## GET /farms

Lister les exploitations de l'utilisateur.

## GET /farms/{farm_id}

Consulter une exploitation.

## PATCH /farms/{farm_id}

Modifier une exploitation.

## DELETE /farms/{farm_id}

Supprimer une exploitation.

---

# 4. Parcelles

## POST /farms/{farm_id}/fields

Créer une parcelle.

## GET /farms/{farm_id}/fields

Lister les parcelles d'une exploitation.

## GET /fields/{field_id}

Consulter une parcelle.

## PATCH /fields/{field_id}

Modifier une parcelle.

## DELETE /fields/{field_id}

Supprimer une parcelle.

---

# 5. Cultures

## POST /fields/{field_id}/crops

Ajouter une culture à une parcelle.

## GET /farms/{farm_id}/crops

Lister les cultures d'une exploitation.

## GET /crops/{crop_id}

Consulter une culture.

## PATCH /crops/{crop_id}

Modifier une culture.

## DELETE /crops/{crop_id}

Supprimer une culture.

---

# 6. Conversations

## POST /conversations

Créer une conversation.

## GET /conversations

Lister les conversations de l'utilisateur.

## GET /conversations/{conversation_id}

Consulter une conversation.

## POST /conversations/{conversation_id}/messages

Ajouter un message dans une conversation.

---

# 7. Photos et médias

## POST /media/upload

Envoyer une photo ou un fichier audio.

## GET /media/{media_id}

Consulter un média autorisé.

## DELETE /media/{media_id}

Supprimer un média.

---

# 8. Diagnostic IA

## POST /ai/diagnosis

Demander un diagnostic agricole.

Entrées possibles :

* question texte ;
* photo ;
* culture ;
* parcelle ;
* contexte libre ;
* langue ;
* mode texte ou voix.

Sortie attendue :

* diagnostic probable ;
* hypothèses ;
* explication ;
* recommandation ;
* Trust Score ;
* questions complémentaires si nécessaire.

---

# 9. Recommandations

## GET /diagnoses/{diagnosis_id}/recommendations

Récupérer les recommandations liées à un diagnostic.

## POST /ai/recommendation

Demander une recommandation agricole sans diagnostic photo obligatoire.

---

# 10. Trust Score

## GET /diagnoses/{diagnosis_id}/trust-score

Consulter le Trust Score d'un diagnostic.

---

# 11. Historique

## GET /history/conversations

Consulter l'historique des conversations.

## GET /history/diagnoses

Consulter l'historique des diagnostics.

## GET /history/crops/{crop_id}

Consulter l'historique lié à une culture.

## GET /history/fields/{field_id}

Consulter l'historique lié à une parcelle.

---

# 12. Langue et voix

## POST /voice/transcribe

Transcrire une question vocale.

## POST /voice/respond

Générer une réponse vocale courte.

## PATCH /me/language-preferences

Modifier la langue et le mode de communication préféré.

---

# Règles de sécurité

* Les données d'un utilisateur ne doivent jamais être accessibles par un autre utilisateur.
* Le mode découverte doit être limité.
* Les médias doivent être protégés.
* Les API d'historique nécessitent un compte.
* Les diagnostics sauvegardés nécessitent un compte.
* Les données personnelles ne doivent pas être conservées sans consentement.

---

# Règles de fiabilité

Les API IA doivent toujours retourner :

* une réponse ;
* un niveau de confiance ;
* une justification ;
* des limites connues ;
* des questions complémentaires si nécessaire.

---

# Hors périmètre MVP

Les API suivantes ne font pas partie du MVP :

* paiement ;
* abonnement ;
* marketplace ;
* fournisseurs ;
* produits agricoles ;
* IoT ;
* drone ;
* satellite ;
* coopératives ;
* pilotage d'équipements.

---

# Décision CTO

Les API du MVP doivent rester simples.

L'objectif n'est pas de créer beaucoup d'endpoints, mais de permettre une expérience mobile fiable :

* poser une question ;
* envoyer une photo ;
* obtenir un diagnostic ;
* recevoir une recommandation ;
* sauvegarder l'historique si l'utilisateur possède un compte.

---

**Statut :APPROVED**
