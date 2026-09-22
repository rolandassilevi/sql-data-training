-- ============================================================
-- Parcours SQL/Data - Semaine 02 - J08
-- SQL métier : projection, tri, alias, expressions calculées,
-- BETWEEN, IN et filtrage multi-critères
--
-- Base   : sql_training
-- Schéma : raw
-- Table  : raw.training_events
-- ============================================================


-- ============================================================
-- 01. VALIDATION DU DATASET
-- ============================================================

-- Objectif :
-- Vérifier le volume et l'étendue des identifiants avant analyse.

SELECT
    COUNT(*) AS total_rows,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id
FROM raw.training_events;

-- Insertion de 8 nouvelles lignes pour compléter le dataset et permettre l'exercice de filtrage multi-critères.

-- ============================================================
-- 02. PROJECTION
-- ============================================================

-- Objectif :
-- Ne sélectionner que les attributs nécessaires à l'analyse.

SELECT
    event_type,
    source_system,
    event_value
FROM raw.training_events;


-- ============================================================
-- 03. TRI
-- ============================================================

-- Objectif :
-- Classer les événements de la valeur la plus élevée
-- à la plus faible.

SELECT
    event_id,
    event_type,
    event_value
FROM raw.training_events
ORDER BY event_value DESC NULLS LAST;


-- ============================================================
-- 04. ALIAS ET EXPRESSION CALCULÉE
-- ============================================================

-- Objectif :
-- Produire une valeur dérivée sans modifier la donnée source.

SELECT
    event_id,
    event_type,
    event_value AS raw_value,
    event_value * 2 AS doubled_value
FROM raw.training_events
WHERE event_value IS NOT NULL
ORDER BY event_id;


-- ============================================================
-- 05. CALCUL : AUGMENTATION DE 10 %
-- ============================================================

SELECT
    event_id,
    event_type,
    event_value,
    ROUND(event_value * 1.10, 2) AS value_plus_10_percent
FROM raw.training_events
WHERE event_value IS NOT NULL
ORDER BY event_value DESC;


-- ============================================================
-- 06. BETWEEN
-- ============================================================

-- Objectif :
-- Identifier les valeurs comprises entre 25 et 100.
-- BETWEEN inclut les deux bornes.

SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE event_value BETWEEN 25 AND 100
ORDER BY event_value DESC;


-- Écriture équivalente permettant de valider BETWEEN.

SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE event_value >= 25
  AND event_value <= 100
ORDER BY event_value DESC;


-- ============================================================
-- 07. IN
-- ============================================================

-- Objectif :
-- Filtrer plusieurs valeurs possibles d'un même attribut
-- sans multiplier les conditions OR.

SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE source_system IN ('sensor_gateway', 'microgrid_poc')
ORDER BY source_system, event_value DESC;


-- Écriture équivalente avec OR pour comparaison.

SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE source_system = 'sensor_gateway'
   OR source_system = 'microgrid_poc'
ORDER BY source_system, event_value DESC;


-- ============================================================
-- 08. CHALLENGE AUTONOME J08
-- ============================================================

-- Besoin métier :
-- Sélectionner les événements :
--   1. dont event_value n'est pas NULL ;
--   2. provenant de sensor_gateway ou microgrid_poc ;
--   3. dont la valeur est comprise entre 25 et 320 inclus ;
--   4. triés par source puis par valeur décroissante.
--
-- Prévision avant exécution : 8 lignes
-- Résultat obtenu            : 8 lignes
-- Écart                      : 0

SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE event_value IS NOT NULL
  AND source_system IN ('sensor_gateway', 'microgrid_poc')
  AND event_value BETWEEN 25 AND 320
ORDER BY source_system, event_value DESC;


-- ============================================================
-- 09. VALIDATION FINALE
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    MIN(event_id) AS min_event_id,
    MAX(event_id) AS max_event_id
FROM raw.training_events;