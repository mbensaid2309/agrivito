---

title: AI Architecture
version: 1.0
status: Draft
owner: CTO
approved_by: CEO
last_updated: 2026-06-28
------------------------

# AgriAI - AI Architecture

## Objectif

Ce document définit l’architecture IA du MVP AgriAI.

Il décrit comment l’intelligence artificielle doit fonctionner pour produire des réponses fiables, utiles et compréhensibles.

Ce document ne valide pas encore les technologies IA définitives.

---

# Principe IA

AgriAI ne doit pas être un simple chatbot.

AgriAI doit être un moteur d’assistance à la décision agricole.

Son rôle est de :

* comprendre la demande ;
* analyser le contexte ;
* analyser les images ;
* rechercher les connaissances utiles ;
* évaluer la fiabilité ;
* poser des questions si nécessaire ;
* produire une réponse claire ;
* proposer une recommandation prudente.

---

# Vue globale

```text
Question / Photo / Voix
        ↓
Compréhension de la demande
        ↓
Analyse du contexte agricole
        ↓
Analyse image si photo
        ↓
Recherche connaissances agricoles
        ↓
Génération du diagnostic
        ↓
Calcul du Trust Score
        ↓
Réponse / Questions complémentaires
        ↓
Historique
```

---

# Modules IA du MVP

## 1. Input Understanding

Responsabilité :

* comprendre la question de l’agriculteur ;
* détecter la langue utilisée ;
* détecter si la demande est en texte ou en voix ;
* identifier l’intention principale.

Exemples d’intention :

* diagnostic ;
* irrigation ;
* traitement ;
* fertilisation ;
* prévention ;
* question générale ;
* demande d’explication.

---

## 2. Language Module

Responsabilité :

* gérer les langues du MVP ;
* adapter la réponse à la langue préférée de l’utilisateur ;
* permettre une communication simple en Darija.

Langues MVP :

* Darija ;
* français ;
* arabe standard ;
* anglais.

Amazigh est prévu plus tard.

---

## 3. Voice Module

Responsabilité :

* transformer la voix en texte ;
* comprendre les demandes vocales ;
* permettre des réponses vocales simples.

Règle :

Si la transcription vocale est ambiguë, AgriAI doit demander confirmation.

---

## 4. Vision Module

Responsabilité :

* analyser les photos ;
* détecter les symptômes visibles ;
* identifier les éléments agricoles importants ;
* évaluer la qualité de l’image.

Exemples :

* feuille jaune ;
* tache noire ;
* insecte visible ;
* fruit abîmé ;
* plante sèche ;
* anomalie du sol.

Règle :

Si la photo est insuffisante, AgriAI doit demander une meilleure photo.

---

## 5. Agricultural Context Module

Responsabilité :

* récupérer le contexte disponible ;
* culture ;
* parcelle ;
* région ;
* historique ;
* langue ;
* informations déjà fournies.

Le diagnostic doit toujours utiliser le contexte disponible.

---

## 6. Knowledge Module

Responsabilité :

* fournir les connaissances agricoles fiables ;
* rechercher les informations utiles ;
* éviter les réponses générales non vérifiées.

Sources futures possibles :

* documents agronomiques ;
* guides officiels ;
* bases de maladies ;
* fiches cultures ;
* documents internes validés.

---

## 7. Diagnosis Engine

Responsabilité :

* proposer un diagnostic probable ;
* identifier plusieurs hypothèses si nécessaire ;
* expliquer les causes possibles ;
* refuser de conclure si le niveau de certitude est insuffisant.

Règle :

Un diagnostic faible ne doit jamais être présenté comme une certitude.

---

## 8. Recommendation Engine

Responsabilité :

* proposer une action utile ;
* expliquer la recommandation ;
* préciser les précautions ;
* adapter la recommandation au contexte.

Types de recommandations MVP :

* inspection ;
* prévention ;
* traitement ;
* irrigation ;
* fertilisation ;
* bonnes pratiques.

---

## 9. Trust Score Engine

Responsabilité :

* évaluer la fiabilité de la réponse ;
* calculer le niveau de confiance ;
* décider si AgriAI peut répondre ;
* décider si AgriAI doit poser des questions.

Niveaux :

| Score  | Niveau      | Comportement           |
| ------ | ----------- | ---------------------- |
| 80-100 | Élevé       | Réponse claire         |
| 60-79  | Moyen       | Réponse prudente       |
| 40-59  | Faible      | Hypothèses + questions |
| 0-39   | Insuffisant | Pas de conclusion      |

---

## 10. Follow-up Question Engine

Responsabilité :

* poser les bonnes questions complémentaires ;
* améliorer la fiabilité du diagnostic ;
* guider l’agriculteur sans le perdre.

Exemples :

* Depuis combien de jours ?
* Quelle culture ?
* Quelle fréquence d’irrigation ?
* Toute la parcelle est touchée ?
* Avez-vous utilisé un traitement ?
* Pouvez-vous envoyer une photo plus proche ?

---

# Format de réponse IA

Une réponse AgriAI doit suivre cette structure :

```text
1. Résumé simple
2. Diagnostic ou hypothèses
3. Trust Score
4. Explication
5. Recommandation
6. Questions complémentaires si nécessaire
7. Précautions
```

---

# Règles anti-hallucination

AgriAI ne doit jamais :

* inventer un diagnostic ;
* inventer une source ;
* recommander un traitement précis sans contexte suffisant ;
* présenter une hypothèse faible comme une certitude ;
* ignorer une mauvaise qualité d’image ;
* ignorer une question vocale ambiguë ;
* donner une instruction critique si le contexte est incomplet.

---

# Règles de prudence

AgriAI doit :

* demander plus d’informations si nécessaire ;
* proposer plusieurs hypothèses en cas de doute ;
* expliquer les limites de sa réponse ;
* recommander une vérification terrain si besoin ;
* rappeler que l’agriculteur garde la décision finale.

---

# Interaction texte

L’utilisateur peut poser une question écrite.

AgriAI doit répondre dans une langue simple et compréhensible.

---

# Interaction voix

L’utilisateur peut poser une question vocale.

AgriAI doit :

* transcrire ;
* comprendre ;
* confirmer si ambigu ;
* répondre simplement ;
* éviter les longues réponses vocales.

---

# Interaction photo

L’utilisateur peut envoyer une photo.

AgriAI doit :

* analyser la photo ;
* évaluer sa qualité ;
* identifier les symptômes visibles ;
* demander une autre photo si nécessaire ;
* combiner la photo avec le contexte agricole.

---

# Hors périmètre MVP

L’architecture IA du MVP ne couvre pas encore :

* agents autonomes avancés ;
* pilotage d’équipements ;
* automatisation d’irrigation ;
* drone ;
* satellite ;
* marketplace ;
* prédiction de rendement ;
* apprentissage automatique avancé par exploitation ;
* recommandations commerciales de produits.

---

# Décision CTO

Le cœur IA d’AgriAI n’est pas le modèle de langage.

Le cœur IA d’AgriAI est la combinaison de :

* contexte agricole ;
* connaissance fiable ;
* analyse photo ;
* questions complémentaires ;
* Trust Score ;
* réponse prudente.

AgriAI doit être fiable avant d’être impressionnant.

---

**Statut : APPROVED**

