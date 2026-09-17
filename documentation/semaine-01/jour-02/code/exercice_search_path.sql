-- ============================================================
-- Parcours SQL/Data - S1 J02
-- Expérience : résolution des objets avec search_path
-- ============================================================

-- État initial
SHOW search_path;
SELECT current_schemas(false);
SELECT current_schema();

-- Table expérimentale explicitement créée dans sandbox
CREATE TABLE sandbox.test_search_path (
    id INTEGER
);

-- Accès avec nom qualifié : fonctionne
SELECT *
FROM sandbox.test_search_path;

-- ATTENTION :
-- La requête suivante est volontairement destinée à échouer
-- avec le search_path initial si sandbox n'en fait pas partie.
SELECT *
FROM test_search_path;

-- Modification temporaire de la session
SET search_path TO sandbox, public;

SHOW search_path;
SELECT current_schemas(false);
SELECT current_schema();

-- La même requête non qualifiée fonctionne maintenant
SELECT *
FROM test_search_path;

-- Nettoyage
DROP TABLE sandbox.test_search_path;

-- Restauration de la configuration de session
RESET search_path;

-- Validation finale
SHOW search_path;
SELECT current_schemas(false);
SELECT current_schema();