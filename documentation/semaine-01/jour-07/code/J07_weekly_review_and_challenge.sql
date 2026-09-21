-- ============================================================
-- Parcours SQL/Data - Semaine 01 - J07
-- Revue hebdomadaire et challenge autonome
-- Base  : sql_training
-- Table : raw.training_events
-- ============================================================


-- ============================================================
-- 01. Inventaire initial
-- ============================================================

SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
ORDER BY event_id;


-- ============================================================
-- 02. Filtrage simple : source sensor_gateway
-- Résultat attendu : 2 lignes
-- ============================================================

SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE source_system = 'sensor_gateway';


-- ============================================================
-- 03. Filtrage numérique : event_value > 100
-- Résultat attendu : 3 lignes
-- ============================================================

SELECT
    event_id,
    event_type,
    event_value
FROM raw.training_events
WHERE event_value > 100
ORDER BY event_value DESC;


-- ============================================================
-- 04. Conditions combinées avec AND
-- microgrid_poc + event_value >= 200
-- Résultat attendu : 2 lignes
-- ============================================================

SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE source_system = 'microgrid_poc'
  AND event_value >= 200
ORDER BY event_value DESC;


-- ============================================================
-- 05. Conditions combinées avec OR
-- ============================================================

SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE event_type = 'temperature'
   OR event_type = 'voltage'
ORDER BY event_type DESC, event_value DESC;


-- ============================================================
-- 06. Valeurs non NULL
-- ============================================================

SELECT
    event_id,
    event_type,
    event_value
FROM raw.training_events
WHERE event_value IS NOT NULL
ORDER BY event_id;


-- ============================================================
-- 07. Challenge multicritère
--
-- IMPORTANT :
-- AND a une priorité supérieure à OR.
-- Les parenthèses expriment ici explicitement la logique métier :
--
-- event_value non NULL
-- ET event_value >= 25
-- ET source appartenant à l'un des deux systèmes.
--
-- Résultat attendu : 3 lignes
-- ============================================================

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


-- ============================================================
-- 08. Métadonnées de raw.training_events
-- information_schema permet d'interroger le catalogue SQL.
-- ordinal_position garantit l'ordre réel des colonnes.
-- ============================================================

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


-- ============================================================
-- 09. Transaction contrôlée
--
-- Objectif :
-- modifier temporairement event_id = 7 de 1.00 vers 2.00,
-- vérifier la modification, puis restaurer l'état initial.
-- ============================================================

BEGIN;

UPDATE raw.training_events
SET event_value = 2.00
WHERE event_id = 7;

-- Dans la transaction : attendu = 2.00
SELECT
    event_id,
    event_type,
    event_value
FROM raw.training_events
WHERE event_id = 7;

ROLLBACK;

-- Après ROLLBACK : attendu = 1.00
SELECT
    event_id,
    event_type,
    event_value
FROM raw.training_events
WHERE event_id = 7;


-- ============================================================
-- 10. Validation finale de l'état de la table
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    MAX(event_id) AS max_event_id
FROM raw.training_events;