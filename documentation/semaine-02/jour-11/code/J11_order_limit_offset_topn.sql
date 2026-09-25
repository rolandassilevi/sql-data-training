-- ============================================================
-- Plan d'exécution SQL/Data - 16 semaines
-- Semaine 02 - J11
-- ORDER BY, LIMIT, OFFSET et Top-N
-- Database : sql_training
-- Table    : raw.training_events
-- ============================================================


-- ============================================================
-- 01 - DATASET VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT source_system) AS source_count,
    COUNT(DISTINCT event_type) AS event_type_count,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id
FROM raw.training_events;


-- ============================================================
-- 02 - ORDER BY ASC / DESC
-- ============================================================

SELECT
    event_id,
    source_system,
    event_type,
    event_value
FROM raw.training_events
ORDER BY event_value DESC;

SELECT
    event_id,
    source_system,
    event_type,
    event_value
FROM raw.training_events
ORDER BY event_value ASC;


-- ============================================================
-- 03 - MULTI-COLUMN DETERMINISTIC ORDERING
-- ============================================================

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


-- ============================================================
-- 04 - TOP-N
-- Top 5 events by event_value
-- ============================================================

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


-- ============================================================
-- 05 - LIMIT / OFFSET PAGINATION
-- 3 pages of 5 rows ordered by event_id
-- ============================================================

-- Page 1
SELECT
    event_id,
    source_system,
    event_type,
    event_value
FROM raw.training_events
ORDER BY event_id ASC
LIMIT 5 OFFSET 0;

-- Page 2
SELECT
    event_id,
    source_system,
    event_type,
    event_value
FROM raw.training_events
ORDER BY event_id ASC
LIMIT 5 OFFSET 5;

-- Page 3
SELECT
    event_id,
    source_system,
    event_type,
    event_value
FROM raw.training_events
ORDER BY event_id ASC
LIMIT 5 OFFSET 10;


-- ============================================================
-- 06 - DETERMINISTIC BUSINESS PAGINATION
-- ============================================================

-- Page 1
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

-- Page 2
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
LIMIT 5 OFFSET 5;


-- ============================================================
-- 07 - AUTONOMOUS TOP-N CHALLENGE
-- Top 3 microgrid_poc events
-- ============================================================

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


-- ============================================================
-- 08 - FINAL DATASET INTEGRITY CHECK
-- J11 must not modify the dataset
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id
FROM raw.training_events;