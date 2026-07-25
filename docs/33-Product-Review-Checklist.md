# Agrivito — Checklist de revue produit MVP

Date : __________  Évaluateur : __________  Version/commit : __________

Notation suggérée : `OK`, `À corriger`, `Non testé`.

## Compréhension et première impression

- [ ] Le rôle d’Agrivito est compris en moins de 30 secondes.
- [ ] Le mode démonstration et le caractère fictif des données sont visibles.
- [ ] Les actions principales sont faciles à trouver.
- [ ] Les libellés sont compréhensibles pour un utilisateur agricole.

## Mode découverte et diagnostic texte

- [ ] `Essayer sans compte` ouvre le chat.
- [ ] Une question vide produit une erreur utile.
- [ ] La question de démonstration retourne une réponse structurée.
- [ ] Les hypothèses ne sont pas présentées comme une certitude.
- [ ] Le Trust Score et son explication sont compréhensibles.
- [ ] La limite découverte et l’invitation à créer un compte fonctionnent.

## Photo

- [ ] La galerie permet de choisir une image.
- [ ] La prévisualisation, l’envoi et le chargement sont explicites.
- [ ] Le diagnostic photo standard s’affiche.
- [ ] Les cas `poor_photo` et `unusable_photo` demandent une meilleure image.
- [ ] L’application ne garantit jamais une maladie sur la seule photo.

## Authentification et propriété

- [ ] Le mode actif (`mock` ou Supabase) est identifiable.
- [ ] Le compte fictif prérempli permet de se connecter.
- [ ] La création de compte mock est clairement fictive.
- [ ] La session mock survit à un rechargement de page.
- [ ] La déconnexion bloque de nouveau les données privées.

## Contexte agricole

- [ ] Le profil de démonstration est lisible.
- [ ] `Ferme Atlas` et `Parcelle Nord` sont accessibles.
- [ ] `Tomate`, `Roma`, `Floraison` sont visibles.
- [ ] La création exploitation/parcelle/culture donne un retour clair.
- [ ] L’association culture/parcelle est compréhensible.

## Navigation, rendu et robustesse

- [ ] Aucun écran blanc, bouton sans effet ou route inexistante.
- [ ] Retour navigateur et retour application cohérents.
- [ ] Rendu acceptable sur ordinateur et largeur mobile.
- [ ] Chargements, succès et erreurs sont visibles sans dépendre de la couleur.
- [ ] Aucun secret, token ou chemin système n’est affiché.

## Décision avant Sprint 9

- [ ] MVP validé pour poursuivre.
- [ ] Validation conditionnelle aux corrections listées ci-dessous.
- [ ] MVP non validé ; nouvelle revue nécessaire.

Corrections bloquantes :

1.
2.
3.

Priorités produit proposées :

1.
2.
3.
