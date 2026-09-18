-- ============================================================
-- Parcours SQL/Data - Semaine 01 - J04
-- Première table du schéma raw
-- ============================================================

CREATE TABLE raw.training_events (
    event_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    source_system VARCHAR(100) NOT NULL,
    event_value NUMERIC(12,2),
    event_timestamp TIMESTAMPTZ NOT NULL,
    ingested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);