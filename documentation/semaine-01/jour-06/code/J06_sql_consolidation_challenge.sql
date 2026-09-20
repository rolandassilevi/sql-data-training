-- ============================================================
-- Parcours SQL/Data - Semaine 01 - J06
-- Consolidation SQL : SELECT, filtres, NULL, transaction,
-- IDENTITY et séquence PostgreSQL
-- Base  : sql_training
-- Table : raw.training_events
-- ============================================================


-- ============================================================
-- 01. État initial
-- ============================================================

-- Vérification de l'environnement courant
SELECT
    current_database() AS database_name,
    current_user AS user_name,
    current_schema() AS current_schema;

-- Nombre initial de lignes : attendu = 7
SELECT COUNT(*) AS total_events
FROM raw.training_events;

-- Consultation des données initiales
SELECT
    event_id,
    event_type,
    source_system,
    event_value,
    event_timestamp
FROM raw.training_events
ORDER BY event_id;


-- ============================================================
-- 02. Challenge A - sensor_gateway
-- Résultat attendu : 2 lignes
-- ============================================================

SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE source_system = 'sensor_gateway';


-- ============================================================
-- 03. Challenge B - event_value > 100
-- Résultat attendu : 3 lignes
-- ============================================================

SELECT
    event_id,
    event_type,
    event_value
FROM raw.training_events
WHERE event_value > 100
ORDER BY event_value DESC;


-- ============================================================
-- 04. Challenge C - microgrid_poc et event_value >= 200
-- Résultat attendu : 2 lignes
-- ============================================================

SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE source_system = 'microgrid_poc'
  AND event_value >= 200
ORDER BY event_value DESC;


-- ============================================================
-- 05. Challenge D - temperature ou voltage
-- Résultat attendu : 3 lignes
-- ============================================================

SELECT
    event_id,
    event_type,
    source_system,
    event_value
FROM raw.training_events
WHERE event_type = 'temperature'
   OR event_type = 'voltage'
ORDER BY event_type DESC, event_value DESC;


-- ============================================================
-- 06. Challenge E - valeurs non NULL
-- Résultat attendu : 7 lignes
-- ============================================================

SELECT
    event_id,
    event_type,
    event_value
FROM raw.training_events
WHERE event_value IS NOT NULL
ORDER BY event_id;


-- ============================================================
-- 07. Comptage des valeurs non NULL
-- Résultat attendu : 7
-- ============================================================

SELECT COUNT(*) AS nombre_non_null
FROM raw.training_events
WHERE event_value IS NOT NULL;


-- ============================================================
-- 08. Transaction contrôlée
-- Objectif :
--   - insérer temporairement un événement
--   - constater son existence dans la transaction
--   - annuler la transaction avec ROLLBACK
-- ============================================================

BEGIN;

-- Nombre de lignes avant l'INSERT : attendu = 7
SELECT COUNT(*)
FROM raw.training_events;

-- Insertion temporaire
INSERT INTO raw.training_events (
    event_type,
    source_system,
    event_value,
    event_timestamp
)
VALUES (
    'pressure',
    'sensor_gateway',
    101.35,
    CURRENT_TIMESTAMP
);

-- Nombre de lignes pendant la transaction : attendu = 8
SELECT COUNT(*)
FROM raw.training_events;

-- Annulation de la transaction
ROLLBACK;


-- ============================================================
-- 09. Vérification après ROLLBACK
-- ============================================================

-- La ligne pressure ne doit plus exister : attendu = 0 ligne
SELECT
    event_id,
    event_type
FROM raw.training_events
WHERE event_type = 'pressure';

-- Le nombre de lignes doit être revenu à 7
SELECT COUNT(*)
FROM raw.training_events;


-- ============================================================
-- 10. Comparaison COUNT(*) / MAX(event_id)
-- Résultats observés :
--   total_rows   = 7
--   max_event_id = 8
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    MAX(event_id) AS max_event_id
FROM raw.training_events;


-- ============================================================
-- 11. Identification de la séquence associée à IDENTITY
-- Résultat :
-- raw.training_events_event_id_seq
-- ============================================================

SELECT
    pg_get_serial_sequence(
        'raw.training_events',
        'event_id'
    ) AS identity_sequence;


-- ============================================================
-- 12. État de la séquence
-- Résultats observés après le ROLLBACK :
--   sequence_last_value = 9
--   is_called           = true
--
-- Observation importante :
-- ROLLBACK a supprimé l'INSERT de la table,
-- mais n'a pas restauré la valeur de la séquence.
-- ============================================================

SELECT
    last_value AS sequence_last_value,
    is_called
FROM raw.training_events_event_id_seq;


-- ============================================================
-- 13. Validation finale : table vs séquence
-- ============================================================

-- État réel de la table :
--   7 lignes
--   MAX(event_id) = 8
SELECT
    COUNT(*) AS total_rows,
    MAX(event_id) AS max_event_id
FROM raw.training_events;

-- État de la séquence :
--   last_value = 9
SELECT
    last_value AS sequence_last_value
FROM raw.training_events_event_id_seq;


-- ============================================================
-- CONCLUSION J06
--
-- 1. La table contient 7 lignes.
-- 2. Le plus grand event_id réellement présent est 8.
-- 3. La séquence associée à event_id a atteint 9.
-- 4. L'INSERT temporaire effectué dans la transaction a consommé
--    la valeur 9 de la séquence.
-- 5. ROLLBACK a annulé l'INSERT, mais pas l'incrémentation
--    de la séquence.
-- 6. Une colonne IDENTITY garantit la génération d'identifiants ;
--    elle ne garantit pas une suite d'identifiants sans trous.
-- ============================================================