# Rapport J08 - SQL métier : projection, filtres, alias et expressions calculées

**Parcours :** SQL/Data - 16 semaines  
**Semaine :** S02  
**Jour :** J08  
**Date du parcours :** 21 septembre 2026  
**Base :** `sql_training`  
**Schéma / table :** `raw.training_events`  
**Durée prévue :** 90 min  
**Temps restant communiqué au moment de la rédaction :** 25 min  
**Durée déjà effectuée :** 65 min  
**Statut :** travail SQL principal et validation du script terminés ; documentation/Git à finaliser dans le temps restant.

## 1. Objectifs

- Entrer dans la semaine 02 avec des requêtes SQL orientées analyse métier.
- Consolider `SELECT`, projection, alias, expressions calculées et tri.
- Utiliser `BETWEEN`, `IN`, `OR`, `AND`, `IS NOT NULL` et des filtres combinés.
- Prévoir le résultat d'une requête avant son exécution.
- Construire et valider un script SQL reproductible.
- Continuer la documentation systématique du parcours.

## 2. État initial et environnement

La connexion a été effectuée à PostgreSQL 17.5 sur la base `sql_training`. Le schéma courant reste `public`, tandis que les objets de travail sont référencés explicitement par leur nom qualifié, notamment `raw.training_events`.

Avant extension du jeu de données :

- `COUNT(*) = 7`
- `MIN(event_id) = 1`
- `MAX(event_id) = 8`

L'écart entre le nombre de lignes et `MAX(event_id)` reste cohérent avec les exercices antérieurs sur les séquences PostgreSQL et les transactions.

## 3. Extension du dataset métier

Huit événements supplémentaires ont été insérés afin d'obtenir un jeu de données plus pertinent pour les exercices de filtrage et d'analyse.

Après insertion :

- `COUNT(*) = 15`
- `MIN(event_id) = 1`
- `MAX(event_id) = 18`

Les horodatages ont volontairement été différenciés avec `CURRENT_TIMESTAMP - INTERVAL ...` plutôt que d'attribuer exactement la même heure aux huit événements. Cela conserve une logique métier plus réaliste : des événements provenant de sources différentes peuvent être produits à des moments différents.

## 4. Projection, alias et colonnes calculées

Une première expression calculée a doublé `event_value` sans modifier les données sources :

```sql
SELECT
    event_id,
    event_type,
    event_value AS raw_value,
    event_value * 2 AS doubled_value
FROM raw.training_events
WHERE event_value IS NOT NULL
ORDER BY event_id;
```

Résultat : 15 lignes, aucune modification persistante de la table.

Une seconde expression a simulé une augmentation de 10 % :

```sql
SELECT
    event_id,
    event_type,
    event_value,
    ROUND(event_value * 1.10, 2) AS value_plus_10_percent
FROM raw.training_events
WHERE event_value IS NOT NULL
ORDER BY event_value DESC;
```

Validation observée : pour `230.40`, la valeur calculée est `253.44`.

## 5. BETWEEN et bornes inclusives

Requête :

```sql
SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE event_value BETWEEN 25 AND 100
ORDER BY event_value DESC;
```

Résultat : **3 lignes**.

L'écriture équivalente avec :

```sql
event_value >= 25 AND event_value <= 100
```

retourne également 3 lignes. Cela valide que `BETWEEN` inclut les deux bornes.

## 6. IN versus OR

Filtrage avec :

```sql
WHERE source_system IN ('sensor_gateway', 'microgrid_poc')
```

Résultat : **11 lignes**.

La formulation équivalente :

```sql
WHERE source_system = 'sensor_gateway'
   OR source_system = 'microgrid_poc'
```

retourne également **11 lignes**.

Conclusion : `IN` est ici plus compact et lisible pour tester plusieurs valeurs d'une même colonne.

## 7. Challenge autonome multi-critères

Besoin :

- `event_value IS NOT NULL`
- source dans `sensor_gateway` ou `microgrid_poc`
- valeur comprise entre 25 et 320 inclus
- tri par source puis valeur décroissante.

Requête réussie :

```sql
SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE event_value IS NOT NULL
  AND source_system IN ('sensor_gateway', 'microgrid_poc')
  AND event_value BETWEEN 25 AND 320
ORDER BY source_system, event_value DESC;
```

**Prévision avant exécution : 8 lignes.**  
**Résultat PostgreSQL : 8 lignes.**  
**Écart : 0.**

Cette concordance valide non seulement la syntaxe, mais aussi la capacité à raisonner sur le dataset avant exécution.

## 8. Script reproductible

Artefact :

`documentation/semaine-02/jour-08/code/J08_business_filtering.sql`

Le script regroupe :

1. validation du dataset ;
2. projection ;
3. tri ;
4. alias et expression calculée ;
5. augmentation de 10 % ;
6. `BETWEEN` et son équivalent ;
7. `IN` et son équivalent avec `OR` ;
8. challenge autonome ;
9. validation finale.

Commande de validation :

```powershell
psql -U postgres -d sql_training -f ".\documentation\semaine-02\jour-08\code\J08_business_filtering.sql"
```

Contrôles finaux :

| Contrôle | Attendu | Obtenu |
|---|---:|---:|
| Nombre de lignes | 15 | 15 |
| MIN(event_id) | 1 | 1 |
| MAX(event_id) | 18 | 18 |
| BETWEEN 25 et 100 | 3 | 3 |
| IN / OR | 11 | 11 |
| Challenge autonome | 8 | 8 |
| Modification lors de la validation | 0 | 0 |

Le script analytique de validation n'insère pas de nouvelles lignes lorsqu'il est réexécuté.

## 9. Notion Data Engineering introduite : idempotence

L'`INSERT` initial des huit événements n'a pas été conservé dans le script analytique réexécutable. Sinon, chaque exécution aurait ajouté huit nouvelles lignes.

Cela introduit la notion d'**idempotence** : lorsqu'un traitement doit être reproductible, sa réexécution ne doit pas produire involontairement des doublons ou un nouvel état incorrect.

Cette notion sera approfondie avec les clés métier, `UPSERT`, `ON CONFLICT` et les chargements incrémentaux.

## 10. Captures documentaires

- `J08-02_initial-business-dataset.png`
- `J08-03_business-dataset-extension.png`
- `J08-04_projection-aliases-calculated-columns-1.png`
- `J08-04_projection-aliases-calculated-columns-2.png`
- `J08-05_between-range-filter.png`
- `J08-06_in-versus-or.png`
- `J08-07_autonomous-filtering-challenge.png`
- `J08-08_business-filtering-script-validation-1.png`
- `J08-08_business-filtering-script-validation-2.png`
- `J08-08_business-filtering-script-validation-3.png`

## 11. Erreurs, difficultés et résolutions

Aucune erreur SQL bloquante n'a été observée lors de la validation finale du script.

Point de vigilance identifié : séparer le chargement de données de démonstration du script analytique réexécutable afin d'éviter la duplication des lignes.

## 12. Validation des acquis

Acquis validés aujourd'hui :

- projection de colonnes ;
- alias ;
- expressions calculées ;
- `ROUND()` ;
- tri `ORDER BY`;
- filtrage par intervalle avec `BETWEEN`;
- filtrage par ensemble avec `IN`;
- équivalence fonctionnelle `IN` / `OR`;
- combinaison `AND` + `IN` + `BETWEEN` + `IS NOT NULL`;
- raisonnement préalable sur le nombre de lignes attendu ;
- exécution d'un script avec `psql -f`;
- contrôle avant/après d'un dataset.

## 13. KPI J08

| KPI | Résultat |
|---|---|
| Durée prévue | 90 min |
| Durée déjà effectuée au point de rapport | 65 min |
| Temps restant | 25 min |
| SQL principal | Terminé |
| Dataset final | 15 lignes |
| Requêtes de validation principales | Réussies |
| Challenge autonome | 8 prévues / 8 obtenues |
| Écart prévision/résultat | 0 |
| Script complet | Exécution réussie |
| Erreur SQL bloquante | 0 |
| Captures principales | 10 répertoriées |
| Git | À finaliser dans le temps restant |
| Rapport | Produit |

**Durée réelle finale :** à renseigner à la fin du timer.  
**Écart final prévu/réel :** à calculer après communication de la durée finale.

## 14. Git - clôture à effectuer

Après ajout du rapport et des captures finales :

```powershell
git status --short
git add .\documentation\semaine-02\jour-08\
git status --short
git diff --cached --stat
git diff --cached --name-status
git commit -m "docs: complete J08 SQL business filtering training"
git push
git status
```

Validation finale attendue :

```text
Your branch is up to date with 'origin/main'.
nothing to commit, working tree clean
```

## 15. Conclusion

J08 marque le passage d'exercices SQL élémentaires à des requêtes plus proches d'un besoin analytique. La progression importante n'est pas seulement syntaxique : le travail commence à associer besoin métier, prédiction du résultat, écriture de la requête, validation, reproductibilité et documentation.

Le challenge autonome est particulièrement significatif : 8 lignes ont été prévues avant exécution et 8 lignes ont effectivement été retournées.

## 16. Prochaine étape

J09 poursuivra la semaine 02 conformément au Plan d'exécution SQL/Data, en réutilisant le dataset enrichi et les acquis de J08.

## 17. Potentiel pédagogique et portfolio

Ce travail peut être réutilisé comme :

- tutoriel : **Filtrer des données métier avec BETWEEN, IN et plusieurs critères SQL** ;
- micro-vidéo : **IN ou OR en SQL : quand utiliser lequel ?** ;
- micro-vidéo : **Pourquoi prévoir le nombre de lignes avant d'exécuter une requête ?** ;
- module de formation : projection, alias, colonnes calculées et filtres SQL ;
- démonstration Data Engineering : différence entre un script de chargement et un script analytique réexécutable ;
- élément de portfolio montrant SQL + PostgreSQL + documentation + Git.
