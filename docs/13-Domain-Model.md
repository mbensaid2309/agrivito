---

title: Domain Model
version: 1.0
status: Approved
owner: CTO
approved_by: CEO
last_updated: 2026-06-28
------------------------

# AgriAI - Domain Model

## Objectif

Ce document définit les principaux objets métier du MVP AgriAI.

Il ne définit pas encore le modèle technique de base de données.

Le choix de la base de données sera fait plus tard.

---

# Principes

Le modèle métier doit être :

* simple ;
* clair ;
* compatible avec une approche Mobile First ;
* adapté au MVP ;
* évolutif pour les futures versions ;
* compatible avec une utilisation en texte et en voix ;
* compatible avec plusieurs langues, notamment Darija, français, arabe standard et anglais.

---

# Objets métier principaux

## 1. User

Représente un utilisateur de la plateforme.

Dans le MVP, le type principal est l'agriculteur.

### Données principales

* identifiant ;
* nom ;
* email ou téléphone ;
* langue préférée ;
* mode de communication préféré ;
* région ;
* statut du compte ;
* date de création.

---

## 2. Farmer Profile

Représente le profil agricole de l'utilisateur.

### Données principales

* type d'agriculteur ;
* niveau d'expérience ;
* région agricole ;
* langues utilisées ;
* mode préféré : texte, voix ou les deux ;
* dialecte ou langue locale optionnelle ;
* préférences de communication.

---

## 3. Language Preference

Représente les préférences linguistiques de l'utilisateur.

### Données principales

* langue principale ;
* langue secondaire optionnelle ;
* dialecte optionnel ;
* mode préféré : texte, voix ou les deux ;
* niveau de lecture/écriture optionnel.

### Langues MVP

* Darija ;
* français ;
* arabe standard ;
* anglais.

### Langues futures

* Amazigh ;
* autres langues selon les marchés ciblés.

---

## 4. Farm

Représente une exploitation agricole.

Un utilisateur peut gérer une ou plusieurs exploitations dans les futures versions.

Dans le MVP, on garde une exploitation principale.

### Données principales

* nom de l'exploitation ;
* localisation ;
* région ;
* type d'activité ;
* surface approximative ;
* cultures principales.

---

## 5. Field

Représente une parcelle agricole.

Une exploitation peut avoir plusieurs parcelles.

### Données principales

* nom de la parcelle ;
* surface approximative ;
* localisation optionnelle ;
* type de sol optionnel ;
* culture associée.

---

## 6. Crop

Représente une culture déclarée par l'agriculteur.

AgriAI doit permettre plusieurs cultures dès le MVP.

### Données principales

* nom de la culture ;
* variété optionnelle ;
* stade de croissance optionnel ;
* date de plantation optionnelle ;
* parcelle associée optionnelle.

---

## 7. Conversation

Représente un échange entre l'agriculteur et AgriAI.

### Données principales

* utilisateur ;
* date ;
* messages ;
* langue utilisée ;
* canal utilisé : texte ou voix ;
* culture associée optionnelle ;
* parcelle associée optionnelle ;
* diagnostic associé optionnel.

---

## 8. Message

Représente un message dans une conversation.

### Données principales

* auteur : utilisateur ou AgriAI ;
* contenu texte ;
* contenu audio optionnel ;
* langue ;
* date ;
* média associé optionnel ;
* type de message.

---

## 9. Media

Représente un fichier envoyé par l'utilisateur.

Dans le MVP, les médias principaux sont :

* photo ;
* audio.

### Données principales

* type de média ;
* fichier ;
* date d'envoi ;
* utilisateur ;
* conversation associée ;
* diagnostic associé optionnel.

---

## 10. Diagnosis

Représente un diagnostic agricole proposé par AgriAI.

### Données principales

* culture concernée ;
* parcelle concernée optionnelle ;
* problème identifié ;
* hypothèses possibles ;
* symptômes observés ;
* niveau de confiance ;
* explication ;
* langue de réponse ;
* date ;
* statut.

---

## 11. Recommendation

Représente une recommandation donnée par AgriAI.

### Données principales

* diagnostic associé ;
* type de recommandation ;
* action proposée ;
* justification ;
* précautions ;
* niveau de confiance ;
* langue de réponse ;
* date.

Types possibles :

* traitement ;
* irrigation ;
* fertilisation ;
* inspection ;
* prévention ;
* bonnes pratiques.

---

## 12. Trust Score

Représente le niveau de confiance associé à une réponse, un diagnostic ou une recommandation.

### Données principales

* score ;
* niveau ;
* justification ;
* facteurs utilisés ;
* limites connues ;
* besoin d'information complémentaire.

Niveaux possibles :

* élevé ;
* moyen ;
* faible ;
* insuffisant.

---

## 13. Follow-up Question

Représente une question complémentaire posée par AgriAI.

### Données principales

* question ;
* raison de la question ;
* langue ;
* diagnostic concerné ;
* réponse de l'utilisateur ;
* statut.

---

# Relations principales

```text
User
 └── Farmer Profile
 └── Language Preference
 └── Farm
      └── Field
           └── Crop

User
 └── Conversation
      └── Message
      └── Media
      └── Diagnosis
           └── Recommendation
           └── Trust Score
           └── Follow-up Question
```

---

# Règles métier

## Règle 1

Un utilisateur peut utiliser AgriAI en mode découverte sans compte.

---

## Règle 2

L'historique complet nécessite un compte utilisateur.

---

## Règle 3

Une exploitation peut contenir plusieurs cultures.

---

## Règle 4

Un diagnostic doit toujours être lié à un contexte agricole lorsque ce contexte est disponible.

---

## Règle 5

Une recommandation importante doit toujours être accompagnée d'un Trust Score.

---

## Règle 6

Si le Trust Score est insuffisant, AgriAI doit demander des informations complémentaires.

---

## Règle 7

AgriAI ne doit jamais présenter une hypothèse faible comme une certitude.

---

## Règle 8

AgriAI doit permettre à l'agriculteur de communiquer simplement en Darija, en texte et en voix.

---

## Règle 9

La langue de réponse doit respecter la préférence de l'utilisateur lorsque c'est possible.

---

# Hors périmètre MVP

Les objets suivants ne sont pas modélisés dans le MVP :

* paiement ;
* abonnement ;
* marketplace ;
* fournisseur ;
* produit agricole ;
* équipement connecté ;
* capteur IoT ;
* drone ;
* coopérative ;
* organisation professionnelle.

Ils seront ajoutés dans les versions futures.

---

# Décision CTO

Le modèle métier du MVP doit rester simple.

Nous modélisons uniquement ce qui est nécessaire pour :

* comprendre l'utilisateur ;
* comprendre sa langue ;
* comprendre son exploitation ;
* analyser ses problèmes ;
* produire des diagnostics fiables ;
* produire des recommandations utiles ;
* permettre l'usage texte et voix ;
* conserver l'historique.

La Darija et la voix sont des éléments importants du MVP, car AgriAI doit être utilisable directement par les agriculteurs marocains sur le terrain.

---

**Statut : APPROVED**
