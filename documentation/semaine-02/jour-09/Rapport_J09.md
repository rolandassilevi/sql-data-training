# Rapport J09 - Agrégations SQL et GROUP BY

**Parcours :** Plan d'exécution SQL/Data - 16 semaines  
**Semaine :** S02  
**Jour :** J09  
**Base :** `sql_training`  
**Table :** `raw.training_events`  
**Durée prévue :** 90 min  
**État du timer au lancement de la documentation :** 71 min consommées, 19 min restantes  
**Durée réelle définitive :** à compléter à la clôture de J09

## 1. Objectifs

- Comprendre et utiliser les fonctions d'agrégation SQL : `COUNT`, `MIN`, `MAX`, `AVG`, `SUM`.
- Distinguer `COUNT(*)`, `COUNT(colonne)` et le comportement de `COUNT(NULL)`.
- Produire des KPI globaux et des KPI regroupés.
- Maîtriser `GROUP BY` sur une colonne puis sur plusieurs colonnes.
- Comprendre la règle imposée aux colonnes présentes dans un `SELECT` avec `GROUP BY`.
- Diagnostiquer et corriger une erreur PostgreSQL liée à une colonne non agrégée.
- Construire et valider un script SQL reproductible avec `psql -f`.

## 2. État initial du dataset

Le dataset utilisé contient 15 lignes. Les identifiants ne sont pas continus, ce qui est cohérent avec les travaux précédents sur les transactions et les séquences PostgreSQL.

```sql
SELECT
    COUNT(*) AS total_rows,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id
FROM raw.training_events;
```

**Résultat :**

- `total_rows = 15`
- `min_event_id = 1`
- `max_event_id = 18`

## 3. COUNT(*) et COUNT(colonne)

```sql
SELECT COUNT(*) AS total_events
FROM raw.training_events;

SELECT COUNT(event_value) AS events_with_value
FROM raw.training_events;

SELECT
    COUNT(*) AS total_rows,
    COUNT(NULL) AS counted_nulls
FROM raw.training_events;
```

**Résultats :**

- `COUNT(*) = 15`
- `COUNT(event_value) = 15`
- `COUNT(NULL) = 0`

**Explication :** `COUNT(*)` compte toutes les lignes. `COUNT(event_value)` compte uniquement les lignes où `event_value` n'est pas `NULL`. `COUNT(NULL)` retourne 0 car `COUNT(expression)` ignore les valeurs `NULL`.

## 4. Fonctions d'agrégation globales

```sql
SELECT
    COUNT(*) AS total_events,
    MIN(event_value) AS min_value,
    MAX(event_value) AS max_value,
    ROUND(AVG(event_value), 2) AS avg_value,
    ROUND(SUM(event_value), 2) AS total_value
FROM raw.training_events;
```

**Résultats :**

| KPI | Valeur |
|---|---:|
| total_events | 15 |
| min_value | 1.00 |
| max_value | 315.90 |
| avg_value | 105.56 |
| total_value | 1583.40 |

La moyenne globale mélange plusieurs types de mesures. Elle est mathématiquement correcte, mais son interprétation métier est limitée. Le regroupement par dimension permet d'obtenir des KPI plus pertinents.

## 5. GROUP BY sur une dimension

### 5.1 Par source_system

```sql
SELECT
    source_system,
    COUNT(*) AS event_count
FROM raw.training_events
GROUP BY source_system
ORDER BY source_system;
```

**Nombre de groupes : 4**

- `manual_psql` : 1
- `microgrid_poc` : 7
- `sensor_gateway` : 4
- `tomra_training` : 3

### 5.2 Par event_type

```sql
SELECT
    event_type,
    COUNT(*) AS event_count
FROM raw.training_events
GROUP BY event_type
ORDER BY event_count DESC, event_type;
```

**Nombre de groupes : 6**

- `temperature` : 4
- `machine_alarm` : 3
- `voltage` : 3
- `current` : 2
- `sensor_reading` : 2
- `training_test` : 1

`COUNT(*)` sans `GROUP BY` agrège toutes les lignes dans un groupe implicite. Avec `GROUP BY`, PostgreSQL divise les lignes selon les valeurs distinctes des colonnes de regroupement, puis calcule les agrégats dans chaque groupe.

## 6. KPI regroupés

### 6.1 Par source_system

```sql
SELECT
    source_system,
    COUNT(*) AS event_count,
    MIN(event_value) AS min_value,
    MAX(event_value) AS max_value,
    ROUND(AVG(event_value), 2) AS avg_value
FROM raw.training_events
GROUP BY source_system
ORDER BY event_count DESC, source_system;
```

Résultat : 4 lignes.

### 6.2 Par event_type

```sql
SELECT
    event_type,
    COUNT(*) AS event_count,
    MIN(event_value) AS min_value,
    MAX(event_value) AS max_value,
    ROUND(AVG(event_value), 2) AS avg_value
FROM raw.training_events
GROUP BY event_type
ORDER BY event_count DESC, event_type;
```

Résultat : 6 lignes. La moyenne de `temperature` est `28.00`.

## 7. Challenge autonome : GROUP BY multi-colonnes

**Prévision avant exécution : 6 groupes.**  
**Résultat obtenu : 6 groupes.**

```sql
SELECT
    source_system,
    event_type,
    COUNT(*) AS event_count,
    ROUND(AVG(event_value), 2) AS avg_value,
    MAX(event_value) AS max_value
FROM raw.training_events
GROUP BY source_system, event_type
ORDER BY source_system, event_count DESC;
```

Le challenge a été réussi. Un groupe correspond à une combinaison distincte `(source_system, event_type)`, et non à l'addition du nombre de valeurs distinctes de chaque colonne.

## 8. Erreur volontaire, diagnostic et résolution

### Requête incorrecte

```sql
SELECT
    source_system,
    event_type,
    event_value,
    COUNT(*) AS event_count
FROM raw.training_events
GROUP BY source_system, event_type;
```

### Message PostgreSQL

```text
ERROR: column "training_events.event_value" must appear in the GROUP BY clause
or be used in an aggregate function
```

### Diagnostic

`source_system` et `event_type` appartiennent au `GROUP BY`. En revanche, `event_value` apparaît directement dans le `SELECT` sans appartenir au regroupement et sans être agrégée. Un groupe pouvant contenir plusieurs `event_value`, PostgreSQL ne peut pas choisir arbitrairement une valeur unique à afficher.

### Correction

```sql
SELECT
    source_system,
    event_type,
    ROUND(AVG(event_value), 2) AS avg_value,
    COUNT(*) AS event_count
FROM raw.training_events
GROUP BY source_system, event_type
ORDER BY source_system, event_count;
```

**Résultat : 6 lignes.**

**Règle à retenir :** dans une requête avec `GROUP BY`, toute colonne sélectionnée doit soit appartenir au `GROUP BY`, soit être utilisée dans une fonction d'agrégation.

## 9. Script reproductible

Fichier :

`documentation/semaine-02/jour-09/code/J09_aggregations_groupby.sql`

Commande de validation :

```powershell
psql -U postgres -d sql_training -f ".\documentation\semaine-02\jour-09\code\J09_aggregations_groupby.sql"
```

Le script s'est exécuté sans erreur visible et la validation finale a confirmé :

- `total_rows = 15`
- `min_event_id = 1`
- `max_event_id = 18`

Le script est non destructif : aucune donnée n'est modifiée.

## 10. Captures d'écran

- `J09-02_count-star-versus-column.png`
- `J09-03_aggregate-functions-global-summary.png`
- `J09-04_group-by-count.png`
- `J09-05_grouped-business-kpis.png`
- `J09-06_autonomous-groupby-challenge.png`
- `J09-07_group-by-nonaggregated-column-error.png`
- `J09-08_group-by-error-correction.png`
- `J09-09_aggregation-script-validation-1.png`
- `J09-09_aggregation-script-validation-2.png`

## 11. Validation et KPI de progression

| Indicateur | Résultat |
|---|---|
| Dataset de travail | 15 lignes |
| Agrégations globales | Validées |
| COUNT(*) / COUNT(colonne) / NULL | Compris et validé |
| GROUP BY source_system | 4 groupes, validé |
| GROUP BY event_type | 6 groupes, validé |
| GROUP BY multi-colonnes | 6 groupes, validé |
| Prévision du challenge | Exacte : 6 |
| Challenge autonome | Réussi |
| Erreur GROUP BY diagnostiquée | Oui |
| Correction validée | Oui |
| Script reproductible | Validé avec `psql -f` |
| Modification involontaire des données | 0 |
| Durée prévue | 90 min |
| Situation à T+71 min | 19 min restantes |
| Durée réelle finale | À compléter à la clôture |

## 12. Conclusion

J09 marque le passage des requêtes de lecture et de filtrage vers l'analyse agrégée. Les fonctions `COUNT`, `MIN`, `MAX`, `AVG` et `SUM` permettent de transformer les lignes détaillées en indicateurs synthétiques. `GROUP BY` permet ensuite de produire ces indicateurs selon des dimensions métier telles que `source_system` et `event_type`.

Le challenge multi-colonnes et l'erreur volontaire ont renforcé la compréhension du mécanisme de regroupement et de la règle SQL applicable aux colonnes non agrégées.

## 13. Prochaines étapes

- Poursuivre les agrégations et KPI de la semaine 02.
- Introduire progressivement les filtres appliqués aux agrégations, notamment `HAVING`.
- Continuer à transformer les requêtes SQL en actifs reproductibles et documentés.
- Effectuer le staging, la validation Git, le commit et le push de J09.

## 14. Potentiel de réutilisation pédagogique

**Tutoriel court :** « Comprendre COUNT et GROUP BY dans PostgreSQL » - environ 8 à 12 minutes.

**Vidéo éducative :**
1. différence entre lignes détaillées et agrégats ;
2. `COUNT(*)` vs `COUNT(colonne)` ;
3. KPI globaux ;
4. `GROUP BY` sur une dimension ;
5. `GROUP BY` multi-colonnes ;
6. erreur classique d'une colonne non agrégée.

**Module de formation :** 30 à 45 minutes avec démonstration, challenge autonome et correction d'erreur.

**Actif portfolio :** script SQL reproductible + captures + rapport démontrant la capacité à construire des KPI à partir de données événementielles PostgreSQL.
