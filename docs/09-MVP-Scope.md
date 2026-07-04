---

title: MVP Scope
version: 1.0
status: Draft
owner: CTO
approved_by: CEO
last_updated: 2026-06-28
------------------------

# AgriAI - MVP Scope

## Objectif du MVP

Le MVP d'AgriAI doit prouver une chose :

> Un agriculteur peut utiliser AgriAI pour comprendre un problème agricole, obtenir une analyse fiable et recevoir une recommandation utile.

Le MVP doit rester simple, fiable et centré sur la valeur immédiate pour l'agriculteur.

---

# Positionnement du MVP

Le MVP correspond au niveau :

## Assistant

Dans cette première version, AgriAI :

* répond aux questions ;
* analyse les photos ;
* explique les problèmes ;
* propose des recommandations ;
* affiche un niveau de confiance ;
* garde l'historique.

AgriAI ne prend pas d'initiative automatique et ne pilote aucun équipement.

---

# Cible du MVP

Le MVP cible principalement :

1. L'agriculteur autonome.
2. L'agriculteur accompagné.

Ces deux profils couvrent les principaux usages initiaux :

* obtenir un deuxième avis fiable ;
* comprendre un problème ;
* être guidé étape par étape.

---

# Périmètre culturel

AgriAI ne sera pas limité à une seule culture.

Le MVP doit permettre à un agriculteur de déclarer plusieurs cultures dans son exploitation.

Exemples :

* tomates ;
* oliviers ;
* agrumes ;
* céréales ;
* maraîchage ;
* arbres fruitiers ;
* autres cultures.

## Règle importante

AgriAI supporte plusieurs cultures dès le MVP, mais ne doit jamais prétendre avoir le même niveau de certitude sur tous les cas.

La fiabilité reste prioritaire.

Si AgriAI manque d'informations, il doit :

* poser des questions complémentaires ;
* demander une nouvelle photo ;
* proposer plusieurs hypothèses ;
* expliquer son niveau d'incertitude ;
* recommander une vérification terrain si nécessaire.

---

# Fonctionnalités incluses dans le MVP

## 1. Compte utilisateur

L'agriculteur peut créer un compte et se connecter.

---

## 2. Profil agriculteur

L'agriculteur peut renseigner les informations de base :

* nom ;
* région ;
* langue préférée ;
* type d'exploitation.

---

## 3. Exploitation agricole

L'agriculteur peut créer une exploitation simple.

Informations possibles :

* nom de l'exploitation ;
* localisation ;
* type d'activité ;
* cultures principales.

---

## 4. Parcelles simples

L'agriculteur peut ajouter une ou plusieurs parcelles.

Informations possibles :

* nom de la parcelle ;
* surface approximative ;
* culture associée ;
* localisation optionnelle.

---

## 5. Cultures

L'agriculteur peut déclarer plusieurs cultures.

Chaque culture peut être liée à une parcelle.

---

## 6. Chat IA agricole

L'agriculteur peut poser des questions à AgriAI.

Exemples :

* Pourquoi mes feuilles jaunissent ?
* Est-ce que je dois irriguer aujourd'hui ?
* Quel traitement appliquer ?
* Pourquoi mes fruits tombent ?
* Comment améliorer ma culture ?

---

## 7. Upload de photo

L'agriculteur peut envoyer une photo liée à un problème agricole.

Exemples :

* feuille malade ;
* fruit abîmé ;
* tige ;
* sol ;
* insecte ;
* plante entière.

---

## 8. Analyse de photo

AgriAI analyse la photo et identifie les éléments visibles.

Il peut détecter :

* symptômes visibles ;
* maladies possibles ;
* carences possibles ;
* ravageurs possibles ;
* stress hydrique possible ;
* anomalies visibles.

---

## 9. Questions complémentaires

Si les informations sont insuffisantes, AgriAI doit poser des questions avant de donner une recommandation forte.

Exemples :

* Depuis combien de jours le problème existe ?
* Quelle est la fréquence d'irrigation ?
* La maladie touche-t-elle toute la parcelle ?
* Avez-vous utilisé un traitement récemment ?
* Pouvez-vous envoyer une photo plus proche ?

---

## 10. Diagnostic de base

AgriAI peut proposer un diagnostic lorsque le niveau de confiance est suffisant.

Le diagnostic doit rester clair et compréhensible.

---

## 11. Explication

AgriAI explique :

* le problème probable ;
* les causes possibles ;
* les risques ;
* les conséquences ;
* les actions recommandées.

---

## 12. Recommandation

AgriAI propose une recommandation simple et utile.

La recommandation peut concerner :

* traitement ;
* irrigation ;
* fertilisation ;
* inspection ;
* prévention ;
* bonnes pratiques.

---

## 13. Trust Score

Chaque diagnostic ou recommandation importante doit afficher un niveau de confiance.

Exemple :

```text
Diagnostic probable : carence en azote
Trust Score : 82 %
```

Si le Trust Score est faible, AgriAI ne doit pas donner une réponse affirmative.

---

## 14. Historique des conversations

L'agriculteur peut retrouver ses échanges précédents avec AgriAI.

---

## 15. Historique des diagnostics

L'agriculteur peut retrouver les diagnostics précédents par :

* culture ;
* parcelle ;
* date ;
* type de problème.

---

# Règles de fiabilité

La fiabilité est la priorité absolue du MVP.

AgriAI doit toujours choisir l'une des quatre réponses suivantes :

## 1. Réponse fiable

AgriAI répond clairement si les informations sont suffisantes.

## 2. Réponse avec hypothèses

AgriAI propose plusieurs causes possibles si le cas n'est pas certain.

## 3. Questions complémentaires

AgriAI demande plus d'informations avant de recommander une action.

## 4. Refus de certitude

AgriAI indique qu'il ne peut pas conclure avec suffisamment de fiabilité.

---

# Ce que le MVP ne fait pas

Le MVP exclut volontairement :

* pilotage d'équipements ;
* automatisation d'irrigation ;
* IoT ;
* drones ;
* données satellites ;
* marketplace ;
* comparaison de prix ;
* commande de produits ;
* gestion coopérative ;
* tableaux de bord avancés ;
* prédiction de rendement ;
* intégration avec systèmes externes.

---

# Critère de réussite du MVP

Le MVP est réussi si les premiers agriculteurs disent :

> "AgriAI m'aide à mieux comprendre mes problèmes et à prendre de meilleures décisions."

---

# KPI MVP

Les premiers indicateurs à suivre sont :

* nombre d'agriculteurs actifs ;
* nombre de questions posées ;
* nombre de photos analysées ;
* nombre de diagnostics générés ;
* nombre de recommandations utiles ;
* taux de retour utilisateur positif ;
* nombre de décisions agricoles améliorées.

---

# Décision CTO

Le MVP doit rester large sur les cultures, mais strict sur la fiabilité.

AgriAI doit être utile dès le début pour plusieurs types d'agriculteurs, sans jamais sacrifier la confiance.

---

**Statut : APPROVED**
