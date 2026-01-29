SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS game_log;
CREATE SCHEMA IF NOT EXISTS infra;

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;
-- Partitioning or TimescaleDB extensions could be added here later if needed

-- TABLES
-- \i game_log/tables/...

-- FUNCTIONS
-- \i game_log/functions/...

-- INDEXES
-- \i game_log/indexes/...

COMMIT;
