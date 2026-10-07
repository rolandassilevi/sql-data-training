\echo '============================================================'
\echo 'J17 - Join filter semantics and conditional aggregation'
\echo '============================================================'

\echo 'J17-01 - Relational baseline'

SELECT
    COUNT(*) AS staging_events,
    COUNT(DISTINCT source_id) AS distinct_source_ids,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id
FROM staging.training_events;

SELECT
    COUNT(*) AS source_systems,
    COUNT(*) FILTER (WHERE is_active) AS active_sources,
    COUNT(DISTINCT source_code) AS distinct_source_codes
FROM analytics.source_systems;


\echo 'J17-02 - Multi-table business filter'

SELECT
    ste.event_id,
    ss.source_code,
    ss.source_category,
    ste.event_type,
    ste.event_value
FROM staging.training_events AS ste
INNER JOIN analytics.source_systems AS ss
    ON ste.source_id = ss.source_id
WHERE ss.source_category IN ('energy', 'iot')
  AND ste.event_value >= 30
ORDER BY
    ss.source_category,
    ste.event_value DESC;


\echo 'J17-03 - INNER JOIN: filter in WHERE'

SELECT
    ste.event_id,
    ss.source_code,
    ss.source_category,
    ste.event_value
FROM staging.training_events AS ste
INNER JOIN analytics.source_systems AS ss
    ON ste.source_id = ss.source_id
WHERE ss.source_category = 'energy'
ORDER BY ste.event_id;


\echo 'J17-03 - INNER JOIN: filter in ON'

SELECT
    ste.event_id,
    ss.source_code,
    ss.source_category,
    ste.event_value
FROM staging.training_events AS ste
INNER JOIN analytics.source_systems AS ss
    ON ste.source_id = ss.source_id
   AND ss.source_category = 'energy'
ORDER BY ste.event_id;


\echo 'J17-04 - LEFT JOIN: right-table filter in WHERE'

SELECT
    ss.source_code,
    ste.event_id,
    ste.event_value
FROM analytics.source_systems AS ss
LEFT JOIN staging.training_events AS ste
    ON ss.source_id = ste.source_id
WHERE ste.event_value >= 100
ORDER BY
    ss.source_code,
    ste.event_id;


\echo 'J17-04 - LEFT JOIN: right-table filter in ON'

SELECT
    ss.source_code,
    ste.event_id,
    ste.event_value
FROM analytics.source_systems AS ss
LEFT JOIN staging.training_events AS ste
    ON ss.source_id = ste.source_id
   AND ste.event_value >= 100
ORDER BY
    ss.source_code,
    ste.event_id;


\echo 'J17-05 - Conditional aggregation'

SELECT
    ss.source_code,
    COUNT(ste.event_id) AS total_events,
    COUNT(ste.event_id)
        FILTER (WHERE ste.event_value >= 100) AS high_value_events,
    ROUND(AVG(ste.event_value), 2) AS average_value
FROM analytics.source_systems AS ss
LEFT JOIN staging.training_events AS ste
    ON ss.source_id = ste.source_id
GROUP BY
    ss.source_id,
    ss.source_code
ORDER BY
    ss.source_code;


\echo 'J17-06 - Conditional rate KPI'

SELECT
    ss.source_code,
    COUNT(ste.event_id) AS total_events,
    COUNT(ste.event_id)
        FILTER (WHERE ste.event_value >= 100) AS high_value_events,
    ROUND(
        100.0
        * COUNT(ste.event_id)
            FILTER (WHERE ste.event_value >= 100)
        / NULLIF(COUNT(ste.event_id), 0),
        2
    ) AS high_value_rate_pct
FROM analytics.source_systems AS ss
LEFT JOIN staging.training_events AS ste
    ON ss.source_id = ste.source_id
GROUP BY
    ss.source_id,
    ss.source_code
ORDER BY
    high_value_rate_pct DESC NULLS LAST,
    ss.source_code ASC;


\echo 'J17-07/J17-08 - Final analytical dashboard'

WITH source_activity AS (
    SELECT
        ss.source_code,
        ss.source_name,
        ss.source_category,
        COUNT(ste.event_id) AS total_events,
        COUNT(ste.event_id)
            FILTER (WHERE ste.event_value >= 100) AS high_value_events,
        ROUND(AVG(ste.event_value), 2) AS average_value,
        COALESCE(ROUND(SUM(ste.event_value), 2), 0.00) AS total_value,
        ROUND(
            100.0
            * COUNT(ste.event_id)
                FILTER (WHERE ste.event_value >= 100)
            / NULLIF(COUNT(ste.event_id), 0),
            2
        ) AS high_value_rate_pct
    FROM analytics.source_systems AS ss
    LEFT JOIN staging.training_events AS ste
        ON ss.source_id = ste.source_id
    GROUP BY
        ss.source_code,
        ss.source_name,
        ss.source_category
)
SELECT
    source_code,
    source_name,
    source_category,
    total_events,
    high_value_events,
    average_value,
    total_value,
    high_value_rate_pct,
    CASE
        WHEN total_events > 0 THEN 'ACTIVE'
        ELSE 'NO EVENTS'
    END AS activity_status
FROM source_activity
ORDER BY
    high_value_rate_pct DESC NULLS LAST,
    source_code ASC;


\echo 'J17-09 - Zero-event source robustness test'

BEGIN;

INSERT INTO analytics.source_systems (
    source_code,
    source_name,
    source_category
)
VALUES (
    'billing_api',
    'Billing API',
    'external_api'
);

WITH source_activity AS (
    SELECT
        ss.source_code,
        COUNT(ste.event_id) AS total_events,
        COUNT(ste.event_id)
            FILTER (WHERE ste.event_value >= 100) AS high_value_events,
        ROUND(AVG(ste.event_value), 2) AS average_value,
        COALESCE(ROUND(SUM(ste.event_value), 2), 0.00) AS total_value,
        ROUND(
            100.0
            * COUNT(ste.event_id)
                FILTER (WHERE ste.event_value >= 100)
            / NULLIF(COUNT(ste.event_id), 0),
            2
        ) AS high_value_rate_pct
    FROM analytics.source_systems AS ss
    LEFT JOIN staging.training_events AS ste
        ON ss.source_id = ste.source_id
    GROUP BY ss.source_code
)
SELECT *
FROM source_activity
WHERE source_code = 'billing_api';

ROLLBACK;


\echo 'J17-09 - Permanent-state validation'

SELECT
    COUNT(*) AS source_systems,
    COUNT(*) FILTER (WHERE is_active) AS active_sources,
    COUNT(*) FILTER (
        WHERE source_code = 'billing_api'
    ) AS billing_api_remaining
FROM analytics.source_systems;

SELECT
    COUNT(*) AS staging_events,
    COUNT(DISTINCT source_id) AS distinct_source_ids
FROM staging.training_events;

\echo '============================================================'
\echo 'J17 COMPLETE'
\echo '============================================================'