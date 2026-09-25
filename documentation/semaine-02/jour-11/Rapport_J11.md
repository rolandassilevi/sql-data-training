# Rapport J11 - ORDER BY, LIMIT, OFFSET et Top-N

## 1. Informations générales

- Programme : Plan d'exécution SQL/Data - 16 semaines
- Semaine : 02
- Jour : J11
- Date : 25 septembre 2026
- Base de données : `sql_training`
- Table : `raw.training_events`
- PostgreSQL : 17.5
- Durée prévue : 90 minutes
- Temps écoulé au dernier point communiqué : 41 minutes
- Temps restant au dernier point communiqué : 49 minutes
- Durée réelle finale : à compléter à la fin de J11
- Écart prévu/réel final : à compléter à la fin de J11

## 2. Objectifs

L'objectif de J11 est de maîtriser le contrôle de l'ordre et du volume des résultats SQL, puis de produire des résultats Top-N et paginés de manière reproductible et déterministe.

Compétences travaillées :

- `ORDER BY ASC` et `ORDER BY DESC`
- tri multi-colonnes
- ordre déterministe et tie-breaker
- `LIMIT`
- Top-N
- `OFFSET`
- pagination
- combinaison `WHERE + ORDER BY + LIMIT`
- validation reproductible avec `psql -f`

## 3. Validation de l'environnement et du dataset

Connexion validée à la base `sql_training` avec l'utilisateur `postgres` sur `localhost`, port `5432`.

État initial validé :

| Indicateur | Résultat |
|---|---:|
| Nombre de lignes | 15 |
| Systèmes sources distincts | 4 |
| Types d'événements distincts | 6 |
| `MIN(event_id)` | 1 |
| `MAX(event_id)` | 18 |

Les identifiants ne sont pas continus. Cette caractéristique permet de distinguer clairement la position d'une ligne dans un résultat de la valeur de son `event_id`.

Capture : `J11-01_environment-dataset-validation.png`

## 4. ORDER BY ASC et DESC

Sans `ORDER BY`, l'ordre des lignes retournées ne doit pas être considéré comme garanti.

Les requêtes suivantes ont permis de comparer les deux sens de tri :

```sql
SELECT
    event_id,
    source_system,
    event_type,
    event_value
FROM raw.training_events
ORDER BY event_value DESC;
```

```sql
SELECT
    event_id,
    source_system,
    event_type,
    event_value
FROM raw.training_events
ORDER BY event_value ASC;
```

Le classement décroissant place la valeur maximale `315.90` en première position. Le classement croissant place `1.00` en première position.

Capture : `J11-02_order-by-asc-desc.png`

## 5. Tri multi-colonnes et ordre déterministe

Le tri multi-colonnes validé est :

```sql
SELECT
    source_system,
    event_type,
    event_value,
    event_id
FROM raw.training_events
ORDER BY
    source_system ASC,
    event_value DESC,
    event_id ASC;
```

Le classement est appliqué successivement par `source_system`, puis par `event_value`, puis par `event_id`.

`event_id ASC` constitue un tie-breaker : il définit une règle explicite de départage si plusieurs lignes possèdent les mêmes valeurs sur les critères précédents.

Dans le dataset actuel, l'ajout du tie-breaker ne modifie pas visuellement les lignes de `microgrid_poc`, car leurs valeurs sont distinctes. Il rend néanmoins la règle de tri explicite.

Capture : `J11-03_multi-column-deterministic-order.png`

## 6. Top-N

Le Top 5 des événements selon `event_value` a été construit avec :

```sql
SELECT
    event_id,
    source_system,
    event_type,
    event_value
FROM raw.training_events
WHERE event_value IS NOT NULL
ORDER BY
    event_value DESC,
    event_id ASC
LIMIT 5;
```

Résultat :

| event_id | source_system | event_type | event_value |
|---:|---|---|---:|
| 15 | microgrid_poc | sensor_reading | 315.90 |
| 3 | microgrid_poc | sensor_reading | 303.25 |
| 14 | microgrid_poc | voltage | 231.80 |
| 5 | microgrid_poc | voltage | 230.40 |
| 13 | microgrid_poc | voltage | 228.60 |

Capture : `J11-04_top-5-events.png`

## 7. LIMIT et OFFSET

Les 15 lignes ont été découpées en trois pages de cinq lignes avec un tri par `event_id ASC`.

| Page | LIMIT | OFFSET | event_id obtenus |
|---|---:|---:|---|
| 1 | 5 | 0 | 1, 3, 4, 5, 6 |
| 2 | 5 | 5 | 7, 8, 11, 12, 13 |
| 3 | 5 | 10 | 14, 15, 16, 17, 18 |

Point conceptuel important :

`OFFSET 5` ne signifie pas commencer à `event_id = 6`. Il signifie ignorer les cinq premières lignes du résultat ordonné.

Capture : `J11-05_limit-offset-pagination.png`

## 8. Pagination métier déterministe

La pagination métier a utilisé :

```sql
SELECT
    event_id,
    source_system,
    event_type,
    event_value
FROM raw.training_events
WHERE event_value IS NOT NULL
ORDER BY
    event_value DESC,
    event_id ASC
LIMIT 5 OFFSET 0;
```

La deuxième page utilise la même requête avec `OFFSET 5`.

Page 1 :

| event_id | source_system | event_type | event_value |
|---:|---|---|---:|
| 15 | microgrid_poc | sensor_reading | 315.90 |
| 3 | microgrid_poc | sensor_reading | 303.25 |
| 14 | microgrid_poc | voltage | 231.80 |
| 5 | microgrid_poc | voltage | 230.40 |
| 13 | microgrid_poc | voltage | 228.60 |

Page 2 :

| event_id | source_system | event_type | event_value |
|---:|---|---|---:|
| 1 | manual_psql | training_test | 125.50 |
| 11 | sensor_gateway | temperature | 31.40 |
| 12 | sensor_gateway | temperature | 29.70 |
| 8 | sensor_gateway | temperature | 26.10 |
| 4 | sensor_gateway | temperature | 24.80 |

Aucun doublon n'a été observé entre les deux pages testées.

Note pour une étude ultérieure : sur de grands volumes, les offsets élevés peuvent devenir coûteux. La keyset pagination sera étudiée ultérieurement dans le volet performance PostgreSQL.

Capture : `J11-06_deterministic-pagination.png`

## 9. Challenge autonome

### Besoin métier

Retourner les trois événements `microgrid_poc` possédant les plus grandes valeurs, exclure les valeurs NULL et assurer un classement déterministe.

### Requête construite

```sql
SELECT
    event_id,
    event_type,
    event_value
FROM raw.training_events
WHERE source_system = 'microgrid_poc'
  AND event_value IS NOT NULL
ORDER BY
    event_value DESC,
    event_id ASC
LIMIT 3;
```

### Résultat

| event_id | event_type | event_value |
|---:|---|---:|
| 15 | sensor_reading | 315.90 |
| 3 | sensor_reading | 303.25 |
| 14 | voltage | 231.80 |

Challenge réussi.

Capture : `J11-07_autonomous-top-n-challenge.png`

## 10. Script reproductible et validation avec psql -f

Script créé :

`documentation/semaine-02/jour-11/code/J11_order_limit_offset_topn.sql`

Le script contient :

1. validation du dataset ;
2. `ORDER BY ASC / DESC` ;
3. tri multi-colonnes déterministe ;
4. Top-N ;
5. pagination `LIMIT / OFFSET` ;
6. pagination métier déterministe ;
7. challenge autonome ;
8. contrôle final d'intégrité.

Commande de validation :

```powershell
psql -U postgres -d sql_training -f ".\documentation\semaine-02\jour-11\code\J11_order_limit_offset_topn.sql"
```

L'exécution complète n'a produit aucune erreur SQL.

Le challenge a retourné les trois lignes attendues : événements 15, 3 et 14.

Le contrôle final a retourné :

| total_rows | min_event_id | max_event_id |
|---:|---:|---:|
| 15 | 1 | 18 |

J11 n'a donc modifié aucune ligne du dataset.

Captures :

- `J11-08_ordering-pagination-script-validation-1.png`
- `J11-08_ordering-pagination-script-validation-2.png`

## 11. Git - état avant documentation finale

`git status` a retourné le répertoire suivant comme non suivi :

`documentation/semaine-02/jour-11/`

Les commandes :

```powershell
git diff --stat
git diff --name-status
```

n'ont retourné aucun fichier.

Ce comportement est normal : le diff standard n'affiche pas les nouveaux fichiers encore non suivis. Ils apparaîtront dans le contenu staged après `git add`.

Capture : `J11-09_git-pre-documentation-status.png`

## 12. Erreurs, observations et résolutions

Aucune erreur SQL bloquante n'a été rencontrée.

Les principales observations pédagogiques sont :

- un ordre observé sans `ORDER BY` n'est pas un ordre garanti ;
- `OFFSET` travaille sur la position des lignes dans le résultat ordonné et non sur la valeur d'un identifiant ;
- un tie-breaker explicite améliore le caractère déterministe du tri ;
- `LIMIT` doit être appliqué à un résultat correctement filtré et ordonné pour construire un Top-N métier ;
- `git diff` standard ne montre pas les fichiers non suivis.

## 13. Captures d'écran réalisées

1. `J11-01_environment-dataset-validation.png`
2. `J11-02_order-by-asc-desc.png`
3. `J11-03_multi-column-deterministic-order.png`
4. `J11-04_top-5-events.png`
5. `J11-05_limit-offset-pagination.png`
6. `J11-06_deterministic-pagination.png`
7. `J11-07_autonomous-top-n-challenge.png`
8. `J11-08_ordering-pagination-script-validation-1.png`
9. `J11-08_ordering-pagination-script-validation-2.png`
10. `J11-09_git-pre-documentation-status.png`

Les captures de staging et de validation Git finale seront ajoutées après finalisation de J11.

## 14. KPI de progression

| KPI | Résultat |
|---|---|
| `ORDER BY ASC/DESC` | Acquis |
| Tri multi-colonnes | Acquis |
| Tie-breaker | Compris et appliqué |
| Top-N | Acquis |
| `LIMIT` | Acquis |
| `OFFSET` | Acquis |
| Pagination | Réussie |
| Pagination déterministe | Réussie |
| Challenge autonome | Réussi |
| Validation `psql -f` | Réussie |
| Intégrité dataset | 15 / 1 / 18 |
| Erreurs SQL bloquantes | 0 |
| Documentation MD/DOCX/PDF | Produite |
| Git final | À finaliser |

## 15. Durée et pilotage de la séance

- Durée prévue : 90 minutes
- Au dernier point communiqué : 41 minutes écoulées
- Temps restant à ce point : 49 minutes
- Durée réelle finale : à compléter lorsque la séance sera terminée
- Écart prévu/réel final : à calculer lorsque la durée réelle sera connue

La journée ne sera considérée comme terminée qu'après staging, commit, push, validation de `origin/main` et mise à jour de la durée réelle.

## 16. Potentiel de réutilisation

J11 peut être transformé en plusieurs actifs pédagogiques :

- tutoriel : « ORDER BY, LIMIT et OFFSET avec PostgreSQL » ;
- vidéo éducative : « Construire un Top-N SQL correctement » ;
- exercice pratique de pagination SQL ;
- démonstration de l'importance d'un ordre déterministe ;
- module de formation sur la différence entre `OFFSET` et un identifiant ;
- préparation à une comparaison future entre OFFSET pagination et keyset pagination.

## 17. Conclusion

J11 a permis de passer du filtrage des données au contrôle explicite de leur classement et de leur présentation.

La compétence centrale acquise est la capacité à transformer un besoin métier de classement, Top-N ou pagination en une requête SQL déterministe et reproductible.

Le script complet a été validé avec `psql -f` et le dataset est resté intact.

## 18. Prochaines étapes de clôture J11

1. ajouter le dossier J11 au staging Git ;
2. vérifier `git diff --cached --stat` et `git diff --cached --name-status` ;
3. ajouter les captures Git finales au rapport si nécessaire ;
4. renseigner la durée réelle et l'écart prévu/réel ;
5. commit prévu : `docs: complete J11 SQL ordering pagination and Top-N training` ;
6. pousser vers `origin/main` ;
7. confirmer un working tree propre et synchronisé.

J11 ne doit être déclaré terminé qu'après ces validations.
