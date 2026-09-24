-- ============================================================
-- Parcours SQL/Data - Semaine 02 - J10
-- WHERE, GROUP BY, HAVING et filtrage des agrégations
-- Base  : sql_training
-- Table : raw.training_events
-- ============================================================


-- ============================================================
-- 01. Validation du dataset
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT source_system) AS source_count,
    COUNT(DISTINCT event_type) AS event_type_count
FROM raw.training_events;

SELECT
    source_system,
    event_type,
    event_value
FROM raw.training_events
ORDER BY source_system, event_type, event_value;


-- ============================================================
-- 02. WHERE avant agrégation
-- ============================================================

SELECT
    source_system,
    COUNT(*) AS event_count,
    ROUND(AVG(event_value), 2) AS avg_value
FROM raw.training_events
WHERE event_value >= 20
GROUP BY source_system
ORDER BY event_count DESC, source_system;


-- ============================================================
-- 03. HAVING : filtrage des groupes
-- ============================================================

SELECT
    source_system,
    COUNT(*) AS event_count,
    ROUND(AVG(event_value), 2) AS avg_value
FROM raw.training_events
GROUP BY source_system
HAVING COUNT(*) >= 3
ORDER BY event_count DESC, source_system;


-- ============================================================
-- 04. ERREUR PÉDAGOGIQUE
-- Une fonction d'agrégation ne peut pas être utilisée
-- directement dans WHERE.
--
-- Requête volontairement conservée en commentaire afin que
-- l'exécution complète du fichier reste valide.
-- ============================================================

-- SELECT
--     source_system,
--     COUNT(*) AS event_count
-- FROM raw.training_events
-- WHERE COUNT(*) >= 3
-- GROUP BY source_system;


-- ============================================================
-- 05. Correction : HAVING
-- ============================================================

SELECT
    source_system,
    COUNT(*) AS event_count
FROM raw.training_events
GROUP BY source_system
HAVING COUNT(*) >= 3
ORDER BY event_count DESC;


-- ============================================================
-- 06. Combinaison WHERE + GROUP BY + HAVING
-- ============================================================

SELECT
    source_system,
    COUNT(*) AS event_count,
    ROUND(AVG(event_value), 2) AS avg_value,
    MAX(event_value) AS max_value
FROM raw.training_events
WHERE event_value >= 10
GROUP BY source_system
HAVING COUNT(*) >= 2
ORDER BY avg_value DESC;


-- ============================================================
-- 07. Challenge autonome
-- ============================================================

SELECT
    event_type,
    COUNT(*) AS event_count,
    ROUND(AVG(event_value), 2) AS avg_value,
    MAX(event_value) AS max_value
FROM raw.training_events
WHERE event_value >= 10
GROUP BY event_type
HAVING COUNT(*) >= 2
ORDER BY event_count DESC, event_type;


-- ============================================================
-- 08. Validation finale du dataset
-- Le script J10 est analytique : aucune modification des données.
-- Le dataset doit toujours contenir 15 lignes.
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id
FROM raw.training_events;