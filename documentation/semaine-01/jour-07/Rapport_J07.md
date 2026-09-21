# Rapport J07
## Parcours SQL/Data — Semaine 01

**Date : 20 septembre 2026**  
**Durée prévue : 60 min**  
**Durée réelle : 75 min**  
**Écart : +15 min (+25 %)**  
**Statut : J07 terminé**

## Objectifs
- Réviser et consolider les acquis SQL/PostgreSQL de S01.
- Réaliser des requêtes autonomes de filtrage et de tri.
- Valider la logique `AND` / `OR` et le traitement de `NULL`.
- Interroger les métadonnées avec `information_schema`.
- Réaliser une transaction contrôlée avec `UPDATE` puis `ROLLBACK`.
- Produire et exécuter un script SQL J07 reproductible.
- Préparer la clôture Git de la journée.

## Validation conceptuelle
L'évaluation a confirmé la compréhension de la hiérarchie serveur PostgreSQL → base de données → schéma → table, de la qualification `raw.training_events`, de `IS NULL`, des transactions, des catégories DDL/DML/interrogation et du workflow Git.

Correction intégrée : `git status` affiche l'état du répertoire de travail et de l'index ; `git log` affiche l'historique des commits.

## Challenge multicritère
```sql
SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE event_value IS NOT NULL
  AND event_value >= 25
  AND (
      source_system = 'sensor_gateway'
      OR source_system = 'microgrid_poc'
  )
ORDER BY source_system, event_value DESC;
```
**Résultat validé : 3 lignes.**

Le point clé est la priorité de `AND` sur `OR`. Le parenthésage explicite traduit correctement la logique métier.

## Métadonnées
```sql
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default,
    is_identity
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name = 'training_events'
ORDER BY ordinal_position;
```
**Résultat : 6 colonnes.** `ordinal_position` garantit l'ordre réel.

## Transaction contrôlée
```sql
BEGIN;

UPDATE raw.training_events
SET event_value = 2.00
WHERE event_id = 7;

SELECT event_id, event_type, event_value
FROM raw.training_events
WHERE event_id = 7;

ROLLBACK;

SELECT event_id, event_type, event_value
FROM raw.training_events
WHERE event_id = 7;
```
Validation : `1.00 → 2.00 → ROLLBACK → 1.00`. La modification temporaire n'a pas persisté.

## Script J07
Fichier :
`documentation/semaine-01/jour-07/code/J07_weekly_review_and_challenge.sql`

Exécution :
```powershell
psql -U postgres -d sql_training -f ".\documentation\semaine-01\jour-07\code\J07_weekly_review_and_challenge.sql"
```

Résultat final : aucune erreur SQL, `COUNT(*) = 7`, `MAX(event_id) = 8`, transaction correctement annulée.

## Captures
- `J07-03b_multicriteria-challenge-corrected.png`
- `J07-04_postgresql-metadata-and-transaction-challenge.png`
- `J07-05_git-status-before-documentation.png`
- `J07-06_weekly-review-script-execution-1.png`
- `J07-06_weekly-review-script-execution-2.png`

## Erreurs / résolutions
- Priorité `AND/OR` : correction par parenthèses.
- Métadonnées : ajout de `ORDER BY ordinal_position`.
- Distinction `git status` / `git log` consolidée.

## KPI J07
- Durée : **75 / 60 min**.
- Écart : **+15 min (+25 %)**.
- Challenge SQL : **validé**.
- Transaction : **validée**.
- Script reproductible : **validé**.
- État final table : **7 lignes**.
- Autonomie : **forte progression**, avec correction ponctuelle sur la logique booléenne.

## Potentiel pédagogique
- Micro-tutoriel sur la priorité `AND/OR`.
- Démonstration `information_schema`.
- Vidéo `UPDATE + ROLLBACK`.
- Lab SQL reproductible à partir de `raw.training_events`.

## Conclusion
J07 valide la consolidation des fondamentaux travaillés pendant S01. La journée est terminée techniquement et peut être versionnée avec le commit de clôture de la semaine.
