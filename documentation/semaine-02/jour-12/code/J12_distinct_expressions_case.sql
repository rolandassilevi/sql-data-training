-- ============================================================
-- Plan d'exécution SQL/Data - 16 semaines
-- Semaine 02 - J12
-- DISTINCT, expressions et CASE
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
-- 02 - DISTINCT SINGLE COLUMN
-- ============================================================

SELECT DISTINCT source_system
FROM raw.training_events
ORDER BY source_system;

SELECT DISTINCT event_type
FROM raw.training_events
ORDER BY event_type;


-- ============================================================
-- 03 - DISTINCT MULTI-COLUMN
-- ============================================================

SELECT DISTINCT
    source_system,
    event_type
FROM raw.training_events
ORDER BY
    source_system,
    event_type;

SELECT COUNT(*) AS distinct_source_event_pairs
FROM (
    SELECT DISTINCT
        source_system,
        event_type
    FROM raw.training_events
) AS distinct_pairs;


-- ============================================================
-- 04 - CALCULATED EXPRESSIONS
-- ============================================================

SELECT
    event_id,
    event_value,
    event_value * 1.10 AS value_plus_10_percent
FROM raw.training_events
WHERE event_value IS NOT NULL
ORDER BY event_id;

SELECT
    event_id,
    event_value,
    ROUND(event_value * 1.10, 2) AS value_plus_10_percent
FROM raw.training_events
WHERE event_value IS NOT NULL
ORDER BY event_id;


-- ============================================================
-- 05 - BASIC CASE
-- ============================================================

SELECT
    event_id,
    source_system,
    event_type,
    event_value,
    CASE
        WHEN event_value >= 200 THEN 'HIGH'
        ELSE 'STANDARD'
    END AS value_category
FROM raw.training_events
ORDER BY
    event_value DESC,
    event_id ASC;


-- ============================================================
-- 06 - MULTI-LEVEL CASE
-- ============================================================

SELECT
    event_id,
    source_system,
    event_type,
    event_value,
    CASE
        WHEN event_value >= 200 THEN 'HIGH'
        WHEN event_value >= 25 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS value_category
FROM raw.training_events
WHERE event_value IS NOT NULL
ORDER BY
    event_value DESC,
    event_id ASC;


-- ============================================================
-- 07 - NULL HANDLING
-- ============================================================

SELECT
    event_id,
    event_value,
    CASE
        WHEN event_value IS NULL THEN 'MISSING'
        WHEN event_value >= 200 THEN 'HIGH'
        WHEN event_value >= 25 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS value_category
FROM raw.training_events
ORDER BY event_id ASC;


-- ============================================================
-- 08 - CASE GROUPED KPI
-- ============================================================

SELECT
    CASE
        WHEN event_value IS NULL THEN 'MISSING'
        WHEN event_value >= 200 THEN 'HIGH'
        WHEN event_value >= 25 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS value_category,
    COUNT(*) AS event_count
FROM raw.training_events
GROUP BY
    CASE
        WHEN event_value IS NULL THEN 'MISSING'
        WHEN event_value >= 200 THEN 'HIGH'
        WHEN event_value >= 25 THEN 'MEDIUM'
        ELSE 'LOW'
    END
ORDER BY event_count DESC;


-- ============================================================
-- 09 - AUTONOMOUS BUSINESS CHALLENGE
-- ============================================================

SELECT
    event_id,
    source_system,
    event_type,
    event_value,
    CASE
        WHEN event_value IS NULL THEN 'UNKNOWN'
        WHEN event_value >= 200 THEN 'CRITICAL'
        WHEN event_value >= 25 THEN 'REVIEW'
        ELSE 'NORMAL'
    END AS priority
FROM raw.training_events
WHERE source_system IN ('microgrid_poc', 'sensor_gateway')
ORDER BY
    event_value DESC,
    event_id ASC
LIMIT 8;


-- ============================================================
-- 10 - FINAL DATASET INTEGRITY VALIDATION
-- J12 is read-only and must not modify the dataset.
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id
FROM raw.training_events;