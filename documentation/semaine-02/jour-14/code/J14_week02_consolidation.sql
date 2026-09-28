-- ============================================================
-- Plan d'exécution SQL/Data - 16 semaines
-- Semaine 02 - J14
-- Week 02 SQL Consolidation
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
    MAX(event_id) AS max_event_id,
    ROUND(SUM(event_value), 2) AS total_value
FROM raw.training_events;


-- ============================================================
-- 02 - FILTERING REVIEW
-- ============================================================

SELECT
    event_id,
    source_system,
    event_type,
    event_value
FROM raw.training_events
WHERE event_value >= 25
ORDER BY event_value DESC, event_id ASC;


-- ============================================================
-- 03 - GROUP BY AND AGGREGATION REVIEW
-- ============================================================

SELECT
    source_system,
    COUNT(*) AS event_count,
    ROUND(AVG(event_value), 2) AS average_value,
    ROUND(SUM(event_value), 2) AS total_value
FROM raw.training_events
GROUP BY source_system
ORDER BY total_value DESC;


-- ============================================================
-- 04 - HAVING REVIEW
-- ============================================================

SELECT
    source_system,
    COUNT(*) AS event_count,
    ROUND(AVG(event_value), 2) AS average_value,
    ROUND(SUM(event_value), 2) AS total_value
FROM raw.training_events
GROUP BY source_system
HAVING COUNT(*) >= 3
ORDER BY total_value DESC;


-- ============================================================
-- 05 - DISTINCT REVIEW
-- ============================================================

SELECT DISTINCT
    source_system,
    event_type
FROM raw.training_events
ORDER BY source_system ASC, event_type ASC;


-- ============================================================
-- 06 - CASE AND TEXT FUNCTIONS REVIEW
-- ============================================================

SELECT
    event_id,
    INITCAP(REPLACE(source_system, '_', ' ')) AS source_label,
    INITCAP(REPLACE(event_type, '_', ' ')) AS event_label,
    event_value,
    CASE
        WHEN event_value >= 200 THEN 'HIGH'
        WHEN event_value >= 25 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS value_category
FROM raw.training_events
ORDER BY event_value DESC, event_id ASC;


-- ============================================================
-- 07 - WEEK 02 AUTONOMOUS BUSINESS CHALLENGE
-- ============================================================

SELECT
    INITCAP(REPLACE(source_system, '_', ' ')) AS source_label,
    INITCAP(REPLACE(event_type, '_', ' ')) AS event_label,
    COUNT(*) AS event_count,
    ROUND(AVG(event_value), 2) AS average_value,
    ROUND(SUM(event_value), 2) AS total_value
FROM raw.training_events
WHERE event_value >= 25
GROUP BY source_system, event_type
HAVING COUNT(*) >= 2
ORDER BY total_value DESC, source_label ASC;


-- ============================================================
-- 08 - FINAL DATASET INTEGRITY VALIDATION
-- J14 is read-only.
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT source_system) AS source_count,
    COUNT(DISTINCT event_type) AS event_type_count,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id,
    ROUND(SUM(event_value), 2) AS total_value
FROM raw.training_events;