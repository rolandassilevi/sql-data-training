-- ============================================================
-- Parcours SQL/Data - Semaine 1 - J02
-- Initialisation de l'environnement de formation PostgreSQL
-- ============================================================

-- À exécuter depuis psql en étant connecté à une autre base,
-- par exemple postgres.

CREATE DATABASE sql_training;

\connect sql_training

CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA analytics;
CREATE SCHEMA sandbox;

-- Validation
SELECT
    current_database() AS database_name,
    current_user AS connected_user;

SELECT
    schema_name,
    schema_owner
FROM information_schema.schemata
WHERE schema_name IN ('raw', 'staging', 'analytics', 'sandbox')
ORDER BY schema_name;