-- ============================================================
-- J16 - Relational JOINs and coverage analysis
-- Database: sql_training
-- ============================================================

\echo '============================================================'
\echo 'J16 - RELATIONAL JOINS AND COVERAGE ANALYSIS'
\echo '============================================================'

-- ------------------------------------------------------------
-- 01. Initial validation
-- ------------------------------------------------------------

\echo ''
\echo '01 - Initial dataset validation'

SELECT
    COUNT(*) AS staging_events,
    COUNT(DISTINCT source_id) AS distinct_source_ids,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id
FROM staging.training_events;

SELECT
    COUNT(*) AS source_systems,
    COUNT(*) FILTER (WHERE is_active) AS active_sources
FROM analytics.source_systems;


-- ------------------------------------------------------------
-- 02. INNER JOIN on PK/FK
-- ------------------------------------------------------------

\echo ''
\echo '02 - INNER JOIN PK/FK'

SELECT
    ste.event_id,
    ste.source_id,
    ss.source_code,
    ss.source_name,
    ste.event_type,
    ste.event_value
FROM staging.training_events AS ste
INNER JOIN analytics.source_systems AS ss
    ON ste.source_id = ss.source_id
ORDER BY ste.event_id ASC;


-- ------------------------------------------------------------
-- 03. LEFT JOIN baseline
-- ------------------------------------------------------------

\echo ''
\echo '03 - LEFT JOIN baseline'

SELECT
    ss.source_id,
    ss.source_code,
    ss.source_name,
    ste.event_id,
    ste.event_type,
    ste.event_value
FROM analytics.source_systems AS ss
LEFT JOIN staging.training_events AS ste
    ON ss.source_id = ste.source_id
ORDER BY
    ss.source_id,
    ste.event_id;


-- ------------------------------------------------------------
-- 04. Controlled unmatched-source experiment
-- Everything after BEGIN is temporary.
-- ------------------------------------------------------------

\echo ''
\echo '04 - Begin controlled transaction'

BEGIN;

INSERT INTO analytics.source_systems (
    source_code,
    source_name,
    source_category
)
VALUES (
    'weather_api',
    'Weather API',
    'external_api'
);


-- ------------------------------------------------------------
-- 05. INNER JOIN vs LEFT JOIN
-- ------------------------------------------------------------

\echo ''
\echo '05 - INNER JOIN coverage'

SELECT
    COUNT(*) AS inner_join_rows,
    COUNT(DISTINCT ss.source_id) AS sources_returned
FROM analytics.source_systems AS ss
INNER JOIN staging.training_events AS ste
    ON ss.source_id = ste.source_id;

\echo ''
\echo '05 - LEFT JOIN coverage'

SELECT
    COUNT(*) AS left_join_rows,
    COUNT(ste.event_id) AS matched_events,
    COUNT(DISTINCT ss.source_id) AS sources_preserved
FROM analytics.source_systems AS ss
LEFT JOIN staging.training_events AS ste
    ON ss.source_id = ste.source_id;


-- ------------------------------------------------------------
-- 06. Anti-join
-- ------------------------------------------------------------

\echo ''
\echo '06 - Sources without events'

SELECT
    ss.source_id,
    ss.source_code,
    ss.source_name
FROM analytics.source_systems AS ss
LEFT JOIN staging.training_events AS ste
    ON ss.source_id = ste.source_id
WHERE ste.event_id IS NULL
ORDER BY ss.source_id;


-- ------------------------------------------------------------
-- 07. Aggregation after LEFT JOIN
-- ------------------------------------------------------------

\echo ''
\echo '07 - Activity by source'

SELECT
    ss.source_code,
    ss.source_name,
    COUNT(ste.event_id) AS event_count,
    ROUND(AVG(ste.event_value), 2) AS average_value,
    ROUND(SUM(ste.event_value), 2) AS total_value
FROM analytics.source_systems AS ss
LEFT JOIN staging.training_events AS ste
    ON ss.source_id = ste.source_id
GROUP BY
    ss.source_id,
    ss.source_code,
    ss.source_name
ORDER BY
    event_count DESC,
    ss.source_code;


-- ------------------------------------------------------------
-- 08. COUNT(*) vs COUNT(column)
-- ------------------------------------------------------------

\echo ''
\echo '08 - COUNT(*) vs COUNT(event_id)'

SELECT
    ss.source_code,
    COUNT(*) AS joined_rows,
    COUNT(ste.event_id) AS actual_events
FROM analytics.source_systems AS ss
LEFT JOIN staging.training_events AS ste
    ON ss.source_id = ste.source_id
GROUP BY
    ss.source_id,
    ss.source_code
ORDER BY ss.source_id;


-- ------------------------------------------------------------
-- 09. Relational coverage KPI
-- ------------------------------------------------------------

\echo ''
\echo '09 - Relational coverage KPI'

WITH source_activity AS (
    SELECT
        ss.source_id,
        ss.source_code,
        COUNT(ste.event_id) AS event_count
    FROM analytics.source_systems AS ss
    LEFT JOIN staging.training_events AS ste
        ON ss.source_id = ste.source_id
    GROUP BY
        ss.source_id,
        ss.source_code
)
SELECT
    COUNT(*) AS total_sources,
    COUNT(*) FILTER (
        WHERE event_count > 0
    ) AS sources_with_events,
    COUNT(*) FILTER (
        WHERE event_count = 0
    ) AS sources_without_events,
    ROUND(
        100.0
        * COUNT(*) FILTER (WHERE event_count > 0)
        / NULLIF(COUNT(*), 0),
        2
    ) AS coverage_rate_pct
FROM source_activity;


-- ------------------------------------------------------------
-- 10. Business activity challenge
-- ------------------------------------------------------------

\echo ''
\echo '10 - Business activity analysis'

WITH source_activity AS (
    SELECT
        ss.source_name,
        ss.source_category,
        COUNT(ste.event_id) AS event_count,
        COALESCE(
            ROUND(AVG(ste.event_value), 2),
            0.00
        ) AS average_value,
        COALESCE(
            ROUND(SUM(ste.event_value), 2),
            0.00
        ) AS total_value
    FROM analytics.source_systems AS ss
    LEFT JOIN staging.training_events AS ste
        ON ss.source_id = ste.source_id
    GROUP BY
        ss.source_id,
        ss.source_name,
        ss.source_category
)
SELECT
    source_name,
    source_category,
    event_count,
    average_value,
    total_value,
    CASE
        WHEN event_count > 0 THEN 'ACTIVE'
        WHEN event_count = 0 THEN 'NO EVENTS'
        ELSE 'UNKNOWN'
    END AS activity_status
FROM source_activity
ORDER BY
    event_count DESC,
    source_name ASC;


-- ------------------------------------------------------------
-- 11. Restore permanent dataset
-- ------------------------------------------------------------

\echo ''
\echo '11 - Rollback controlled experiment'

ROLLBACK;


-- ------------------------------------------------------------
-- 12. Final validation
-- ------------------------------------------------------------

\echo ''
\echo '12 - Final dataset validation'

SELECT
    COUNT(*) AS source_systems,
    COUNT(*) FILTER (WHERE is_active) AS active_sources
FROM analytics.source_systems;

SELECT
    COUNT(*) AS staging_events,
    COUNT(DISTINCT source_id) AS distinct_source_ids,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id
FROM staging.training_events;

SELECT
    COUNT(*) AS weather_api_rows
FROM analytics.source_systems
WHERE source_code = 'weather_api';

\echo ''
\echo '============================================================'
\echo 'J16 COMPLETE'
\echo '============================================================'