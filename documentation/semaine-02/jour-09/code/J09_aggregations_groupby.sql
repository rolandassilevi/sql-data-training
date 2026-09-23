-- ============================================================
-- Parcours SQL/Data - Semaine 02 - J09
-- Agrégations SQL et GROUP BY
-- Base  : sql_training
-- Table : raw.training_events
-- ============================================================


-- ============================================================
-- 01. Validation du dataset
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id
FROM raw.training_events;

SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
ORDER BY event_id;


-- ============================================================
-- 02. COUNT(*) vs COUNT(colonne)
-- ============================================================

-- Compte toutes les lignes
SELECT
    COUNT(*) AS total_events
FROM raw.training_events;

-- Compte uniquement les valeurs non NULL de event_value
SELECT
    COUNT(event_value) AS events_with_value
FROM raw.training_events;

-- Démonstration : COUNT(expression) ignore NULL
SELECT
    COUNT(*) AS total_rows,
    COUNT(NULL) AS counted_nulls
FROM raw.training_events;


-- ============================================================
-- 03. Fonctions d'agrégation globales
-- ============================================================

SELECT
    COUNT(*) AS total_events,
    MIN(event_value) AS min_value,
    MAX(event_value) AS max_value,
    AVG(event_value) AS avg_value,
    SUM(event_value) AS total_value
FROM raw.training_events;

-- Version adaptée au reporting
SELECT
    COUNT(*) AS total_events,
    MIN(event_value) AS min_value,
    MAX(event_value) AS max_value,
    ROUND(AVG(event_value), 2) AS avg_value,
    ROUND(SUM(event_value), 2) AS total_value
FROM raw.training_events;


-- ============================================================
-- 04. GROUP BY : nombre d'événements par source
-- ============================================================

SELECT
    source_system,
    COUNT(*) AS event_count
FROM raw.training_events
GROUP BY source_system
ORDER BY source_system;


-- ============================================================
-- 05. GROUP BY : nombre d'événements par type
-- ============================================================

SELECT
    event_type,
    COUNT(*) AS event_count
FROM raw.training_events
GROUP BY event_type
ORDER BY event_count DESC, event_type;


-- ============================================================
-- 06. KPI par système source
-- ============================================================

SELECT
    source_system,
    COUNT(*) AS event_count,
    MIN(event_value) AS min_value,
    MAX(event_value) AS max_value,
    ROUND(AVG(event_value), 2) AS avg_value
FROM raw.training_events
GROUP BY source_system
ORDER BY event_count DESC, source_system;


-- ============================================================
-- 07. KPI par type d'événement
-- ============================================================

SELECT
    event_type,
    COUNT(*) AS event_count,
    MIN(event_value) AS min_value,
    MAX(event_value) AS max_value,
    ROUND(AVG(event_value), 2) AS avg_value
FROM raw.training_events
GROUP BY event_type
ORDER BY event_count DESC, event_type;


-- ============================================================
-- 08. Challenge autonome :
--     agrégation par source_system + event_type
-- ============================================================

SELECT
    source_system,
    event_type,
    COUNT(*) AS event_count,
    ROUND(AVG(event_value), 2) AS avg_value,
    MAX(event_value) AS max_value
FROM raw.training_events
GROUP BY source_system, event_type
ORDER BY source_system, event_count DESC;


-- ============================================================
-- 09. Correction de l'erreur GROUP BY
-- ============================================================
-- Règle :
-- Toute colonne présente dans SELECT doit :
--   1. appartenir au GROUP BY
-- ou
--   2. être utilisée dans une fonction d'agrégation.
--
-- La requête volontairement incorrecte n'est pas exécutée dans
-- ce script afin de conserver un script entièrement reproductible.
--
-- Exemple incorrect :
--
-- SELECT
--     source_system,
--     event_type,
--     event_value,
--     COUNT(*) AS event_count
-- FROM raw.training_events
-- GROUP BY source_system, event_type;


-- Requête corrigée

SELECT
    source_system,
    event_type,
    ROUND(AVG(event_value), 2) AS avg_value,
    COUNT(*) AS event_count
FROM raw.training_events
GROUP BY source_system, event_type
ORDER BY source_system, event_count;


-- ============================================================
-- 10. Validation finale
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id
FROM raw.training_events;

-- Résultats attendus :
-- total_rows   = 15
-- min_event_id = 1
-- max_event_id = 18

-- Aucune donnée n'est modifiée par ce script.
-- ============================================================