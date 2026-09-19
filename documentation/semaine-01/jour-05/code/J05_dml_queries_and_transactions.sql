-- ============================================================
-- Parcours SQL/Data - Semaine 01 - J05
-- DML, filtrage, tri, NULL et transactions
-- Base : sql_training
-- Table : raw.training_events
-- ============================================================


-- 01. Lecture des données
SELECT
    event_id,
    event_type,
    source_system,
    event_value,
    event_timestamp,
    ingested_at
FROM raw.training_events
ORDER BY event_id;


-- 02. Alias et expression calculée
SELECT
    event_id AS id,
    event_type AS type_evenement,
    event_value AS valeur,
    event_value * 2 AS valeur_double
FROM raw.training_events
ORDER BY event_id;


-- 03. Filtrage
SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE source_system = 'microgrid_poc'
ORDER BY event_id;


-- 04. Plusieurs conditions
SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE source_system = 'microgrid_poc'
  AND event_value > 20
ORDER BY event_id;


-- 05. Gestion de NULL
SELECT
    event_id,
    event_type,
    event_value
FROM raw.training_events
WHERE event_value IS NULL;


-- 06. Tri et limitation
SELECT
    event_id,
    event_type,
    event_value
FROM raw.training_events
ORDER BY event_value DESC NULLS LAST
LIMIT 3;


-- 07. Challenge autonome : sensor_gateway
SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE source_system = 'sensor_gateway'
ORDER BY event_id;


-- 08. Challenge autonome : valeur > 25
SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE event_value > 25
ORDER BY event_value DESC NULLS LAST;


-- 09. Challenge autonome : temperature OU voltage
SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE event_type = 'temperature'
   OR event_type = 'voltage'
ORDER BY event_id;


-- 10. Challenge autonome : BETWEEN
SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE event_value BETWEEN 20 AND 250
ORDER BY event_id;


-- 11. Challenge autonome : compter les NULL
SELECT COUNT(*) AS null_event_values
FROM raw.training_events
WHERE event_value IS NULL;


/*
-- ============================================================
-- COMMANDES QUI MODIFIENT LES DONNEES
-- À exécuter volontairement, pas automatiquement.
-- ============================================================

-- Exemple UPDATE
UPDATE raw.training_events
SET event_value = 1.00
WHERE event_type = 'machine_alarm'
  AND source_system = 'tomra_training';


-- Exemple transaction protégée par ROLLBACK
BEGIN;

DELETE FROM raw.training_events
WHERE event_type = 'current'
  AND source_system = 'microgrid_poc';

SELECT COUNT(*) AS total_during_transaction
FROM raw.training_events;

ROLLBACK;

SELECT COUNT(*) AS total_after_rollback
FROM raw.training_events;
*/