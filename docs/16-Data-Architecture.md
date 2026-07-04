---

title: Data Architecture
version: 1.0
status: Draft
owner: CTO
approved_by: CEO
last_updated: 2026-06-28
------------------------

# AgriAI - Data Architecture

## Objectif

Ce document définit l’architecture logique des données du MVP AgriAI.

Il ne valide pas encore le choix de la base de données.

Le choix technique sera fait plus tard via une ADR.

---

# Principe général

Les données d’AgriAI doivent être organisées pour garantir :

* fiabilité ;
* confidentialité ;
* traçabilité ;
* historique ;
* évolutivité ;
* simplicité d’exploitation.

---

# Catégories de données

## 1. Données utilisateur

Exemples :

* compte utilisateur ;
* profil agriculteur ;
* langue préférée ;
* mode de communication préféré ;
* région ;
* statut du compte.

Objectif :

Comprendre qui utilise AgriAI et personnaliser l’expérience.

---

## 2. Données d’exploitation

Exemples :

* exploitation ;
* localisation ;
* parcelles ;
* cultures ;
* surface ;
* type de sol optionnel ;
* stade de croissance optionnel.

Objectif :

Donner du contexte aux diagnostics et recommandations.

---

## 3. Données conversationnelles

Exemples :

* conversations ;
* messages ;
* langue utilisée ;
* canal : texte ou voix ;
* questions complémentaires ;
* réponses utilisateur.

Objectif :

Conserver le contexte des échanges et améliorer le suivi.

---

## 4. Données médias

Exemples :

* photos ;
* fichiers audio ;
* métadonnées ;
* qualité de l’image ;
* lien avec une conversation ;
* lien avec un diagnostic.

Objectif :

Permettre l’analyse photo, la voix et l’historique.

---

## 5. Données IA

Exemples :

* diagnostic ;
* hypothèses ;
* recommandation ;
* Trust Score ;
* justification ;
* limites connues ;
* facteurs utilisés.

Objectif :

Tracer ce qu’AgriAI a analysé, recommandé et avec quel niveau de confiance.

---

## 6. Données de connaissances agricoles

Exemples :

* fiches cultures ;
* maladies ;
* ravageurs ;
* carences ;
* bonnes pratiques ;
* règles agronomiques ;
* documents validés.

Objectif :

Fournir une base fiable pour les réponses AgriAI.

---

# Séparation des données

AgriAI doit séparer clairement :

## Données métier

* utilisateurs ;
* exploitations ;
* parcelles ;
* cultures ;
* conversations ;
* diagnostics ;
* recommandations.

## Données médias

* photos ;
* audios ;
* fichiers.

## Données de connaissance

* documents agricoles ;
* contenus validés ;
* bases de référence.

## Données techniques IA

* embeddings futurs ;
* traces d’analyse ;
* scores ;
* résultats intermédiaires.

---

# Règles de confidentialité

## Règle 1

Les données de l’exploitation appartiennent à l’agriculteur.

## Règle 2

Aucune donnée personnelle durable ne doit être conservée sans consentement.

## Règle 3

Le mode découverte ne doit conserver que le strict minimum.

## Règle 4

L’utilisateur connecté doit pouvoir retrouver son historique.

## Règle 5

Les photos et audios doivent être protégés.

---

# Règles de traçabilité

Chaque diagnostic doit pouvoir être relié à :

* une question ;
* une photo optionnelle ;
* une culture ;
* une parcelle optionnelle ;
* une recommandation ;
* un Trust Score ;
* une date.

---

# Historique

L’historique est important pour :

* consulter les anciens diagnostics ;
* suivre l’évolution d’une culture ;
* comprendre les décisions passées ;
* préparer les futures capacités d’apprentissage.

Dans le MVP, l’historique complet nécessite un compte utilisateur.

---

# Données en mode découverte

En mode découverte sans compte :

* l’utilisateur peut poser une question ;
* l’utilisateur peut envoyer une photo ;
* l’usage est limité ;
* les données ne doivent pas être conservées durablement sans consentement ;
* l’utilisateur est invité à créer un compte pour sauvegarder.

---

# Données multilingues

AgriAI doit stocker la langue utilisée dans :

* conversations ;
* messages ;
* diagnostics ;
* recommandations ;
* questions complémentaires.

Langues MVP :

* Darija ;
* français ;
* arabe standard ;
* anglais.

---

# Données vocales

Pour la voix, AgriAI doit gérer :

* fichier audio ;
* transcription ;
* langue détectée ;
* niveau de confiance de transcription ;
* confirmation si ambiguë.

---

# Données photo

Pour les photos, AgriAI doit gérer :

* fichier image ;
* qualité de l’image ;
* symptômes visibles ;
* culture associée ;
* diagnostic associé ;
* date d’envoi.

---

# Données de connaissance agricole

La base de connaissance doit être fiable.

Sources possibles :

* documents officiels ;
* guides agronomiques ;
* fiches maladies ;
* fiches cultures ;
* contenus validés par experts ;
* documents internes AgriAI.

Règle :

Une connaissance non vérifiée ne doit pas être utilisée comme source forte.

---

# Préparation du futur RAG

Même si le RAG complet n’est pas encore détaillé, l’architecture des données doit prévoir :

* documents source ;
* version du document ;
* langue du document ;
* date de validation ;
* niveau de confiance de la source ;
* propriétaire de la source ;
* statut de validation.

---

# Exclusions MVP

Les données suivantes ne sont pas prioritaires dans le MVP :

* paiement ;
* abonnement ;
* marketplace ;
* fournisseurs ;
* prix produits ;
* capteurs IoT ;
* données drone ;
* données satellite ;
* données coopératives ;
* données assurance ;
* données crédit agricole.

---

# Décision CTO

Les données sont un actif stratégique d’AgriAI.

Le MVP doit collecter uniquement les données nécessaires, mais les structurer proprement dès le départ.

La qualité des données conditionnera la qualité des recommandations.

---

**Statut : APPROVED**
