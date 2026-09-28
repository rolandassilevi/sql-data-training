-- ============================================================
-- Plan d'exécution SQL/Data - 16 semaines
-- Semaine 02 - J13
-- PostgreSQL Text Functions and Data Cleaning
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
-- 02 - RAW TEXT BUSINESS DATA
-- ============================================================

SELECT
    event_id,
    source_system,
    event_type
FROM raw.training_events
ORDER BY event_id ASC;


-- ============================================================
-- 03 - UPPER AND LOWER
-- ============================================================

SELECT
    event_id,
    source_system,
    UPPER(source_system) AS source_upper,
    LOWER(source_system) AS source_lower
FROM raw.training_events
ORDER BY event_id ASC;


-- ============================================================
-- 04 - TEXT LENGTH ANALYSIS
-- ============================================================

SELECT DISTINCT
    source_system,
    LENGTH(source_system) AS source_length
FROM raw.training_events
ORDER BY source_length DESC, source_system ASC;

SELECT DISTINCT
    event_type,
    LENGTH(event_type) AS event_type_length
FROM raw.training_events
ORDER BY event_type_length DESC, event_type ASC;


-- ============================================================
-- 05 - REPLACE TECHNICAL LABELS
-- ============================================================

SELECT DISTINCT
    source_system,
    REPLACE(source_system, '_', ' ') AS source_label
FROM raw.training_events
ORDER BY source_system ASC;

SELECT DISTINCT
    event_type,
    REPLACE(event_type, '_', ' ') AS event_label
FROM raw.training_events
ORDER BY event_type ASC;


-- ============================================================
-- 06 - BUSINESS-READABLE LABELS
-- ============================================================

SELECT DISTINCT
    source_system,
    INITCAP(REPLACE(source_system, '_', ' ')) AS source_label
FROM raw.training_events
ORDER BY source_system ASC;

SELECT DISTINCT
    event_type,
    INITCAP(REPLACE(event_type, '_', ' ')) AS event_label
FROM raw.training_events
ORDER BY event_type ASC;


-- ============================================================
-- 07 - TRIM AND WHITESPACE CLEANING
-- ============================================================

SELECT
    '  microgrid_poc  ' AS raw_text,
    TRIM('  microgrid_poc  ') AS cleaned_text;

SELECT
    LENGTH('  microgrid_poc  ') AS raw_length,
    LENGTH(TRIM('  microgrid_poc  ')) AS cleaned_length;


-- ============================================================
-- 08 - TEXT CONCATENATION
-- ============================================================

SELECT
    event_id,
    source_system,
    event_type,
    source_system || ' - ' || event_type AS event_descriptor
FROM raw.training_events
ORDER BY event_id ASC;

SELECT
    event_id,
    INITCAP(REPLACE(source_system, '_', ' '))
        || ' - ' ||
    INITCAP(REPLACE(event_type, '_', ' ')) AS event_descriptor
FROM raw.training_events
ORDER BY event_id ASC;


-- ============================================================
-- 09 - COALESCE AND NULL HANDLING
-- ============================================================

SELECT
    event_id,
    event_value,
    COALESCE(event_value, 0) AS event_value_safe
FROM raw.training_events
ORDER BY event_id ASC;

SELECT
    COALESCE(NULL::numeric, 0) AS null_replaced,
    COALESCE(125.50::numeric, 0) AS existing_value;


-- ============================================================
-- 10 - GUIDED TEXT TRANSFORMATION EXERCISE
-- ============================================================

SELECT
    event_id,
    source_system,
    INITCAP(REPLACE(source_system, '_', ' ')) AS source_label,
    event_type,
    INITCAP(REPLACE(event_type, '_', ' ')) AS event_label,
    event_value
FROM raw.training_events
WHERE source_system IN ('microgrid_poc', 'sensor_gateway')
ORDER BY event_value DESC, event_id ASC;


-- ============================================================
-- 11 - AUTONOMOUS BUSINESS CHALLENGE
-- ============================================================

SELECT
    event_id,
    INITCAP(REPLACE(source_system, '_', ' '))
        || ' - ' ||
    INITCAP(REPLACE(event_type, '_', ' ')) AS event_descriptor,
    event_value,
    CASE
        WHEN event_value IS NULL THEN 'UNKNOWN'
        WHEN event_value >= 200 THEN 'CRITICAL'
        WHEN event_value >= 25 THEN 'REVIEW'
        ELSE 'NORMAL'
    END AS priority
FROM raw.training_events
WHERE source_system IN ('microgrid_poc', 'sensor_gateway')
ORDER BY event_value DESC, event_id ASC
LIMIT 8;


-- ============================================================
-- 12 - FINAL DATASET INTEGRITY VALIDATION
-- J13 is read-only and must not modify the dataset.
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id,
    ROUND(SUM(event_value), 2) AS total_value
FROM raw.training_events;