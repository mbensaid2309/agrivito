# Agrivito — Guide de démonstration MVP

## Objectif

Ce guide permet de présenter le MVP sans OpenAI, AWS ni compte Supabase. Les
analyses, l’utilisateur et les données sont fictifs. PostgreSQL reste la base
du produit et doit être disponible localement ou dans un environnement de test.

## Prérequis

- Python 3.9 ou supérieur ;
- Flutter stable avec le support Web ;
- PostgreSQL 16 installé localement, ou une base de test dédiée accessible ;
- `curl`.

Sans `DATABASE_URL`, le script initialise automatiquement un PostgreSQL local
isolé sous `.demo/postgres-data` sur le port 55432. Pour utiliser une autre base
de test, exposer sa connexion uniquement dans le terminal :

```bash
export DATABASE_URL='postgresql+psycopg://postgres:postgres@127.0.0.1:5432/agrivito_demo'
```

## Démarrage rapide

Depuis la racine du dépôt :

```bash
./scripts/start-demo.sh
```

Le script est relançable : il arrête d’abord uniquement ses anciens processus,
applique les migrations et complète les données fictives sans doublon. Il force
`DEMO_MODE=true`, `AUTH_MODE=mock`, `AI_MODE=mock`, `VISION_MODE=mock` et
`MEDIA_STORAGE_PROVIDER=local`.

Adresses par défaut :

- application : `http://127.0.0.1:8080` ;
- documentation API : `http://127.0.0.1:8000/docs` ;
- logs : `.demo/logs/`.

Arrêt : `./scripts/stop-demo.sh`.

## Compte fictif

```text
Email : agriculteur.demo@agrivito.local
Mot de passe : DemoAgrivito123!
```

Ces identifiants ne représentent aucune personne et ne doivent jamais être
réutilisés pour un service réel.

## Parcours conseillé (10 à 15 minutes)

1. Sur l’accueil, repérer le badge `Mode démonstration` et le backend `ok`.
2. Choisir `Essayer sans compte`.
3. Poser : `Pourquoi les feuilles de mes tomates jaunissent ?`.
4. Vérifier résumé, hypothèses, recommandations, précautions et Trust Score.
5. Revenir à l’accueil, choisir `Analyser une photo`, puis la galerie.
6. Utiliser `assets/demo/tomato-leaf-demo.png`, envoyer puis analyser la photo.
7. Vérifier la qualité photo, le diagnostic prudent et le Trust Score.
8. Créer un compte fictif ou se connecter avec le compte prérempli.
9. Ouvrir `Mon compte`, puis le profil agricole et les exploitations.
10. Vérifier `Agriculteur de démonstration`, `Ferme Atlas`, `Parcelle Nord`,
    `Tomate`, variété `Roma`, stade `Floraison`.
11. Ajouter au besoin une exploitation, une parcelle ou une culture pour tester
    les formulaires, puis se déconnecter.

## Scénarios photo mock

- photo standard : confiance élevée et hypothèses prudentes ;
- question contenant `poor_photo` : qualité pauvre et demande de reprise ;
- question contenant `unusable_photo` : photo inutilisable, sans conclusion.

Ces mots-clés sont réservés à la revue technique du provider mock.

## Auth Supabase réelle (optionnelle)

La démonstration immédiate utilise l’auth mock. Pour vérifier Supabase Auth,
lancer Flutter avec `AUTH_MODE=live`, `SUPABASE_URL` et la clé publique anon.
Le backend doit lui aussi être configuré en `AUTH_MODE=live`. Ne jamais placer
de clé `service_role`, secret JWT ou token utilisateur dans Flutter ou Git.

## Dépannage

- backend rouge : vérifier `DATABASE_URL` et `.demo/logs/backend.log` ;
- écran Flutter inaccessible : vérifier `.demo/logs/flutter.log` et le port 8080 ;
- données privées en `401` : se reconnecter avec le compte fictif ;
- média refusé : utiliser un JPEG, PNG ou WebP inférieur à 10 MB ;
- port occupé : définir `AGRIVITO_DEMO_WEB_PORT` pour Flutter.

Le script d’arrêt ne recherche pas de processus par nom : il termine seulement
les PID écrits par le script de démarrage, puis arrête proprement son cluster
PostgreSQL local s’il l’a lui-même créé.
