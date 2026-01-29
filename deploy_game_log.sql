SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS game_log;
COMMENT ON SCHEMA game_log IS 'Game activity logs';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

-- DROP UNUSED SCHEMAS
DROP SCHEMA IF EXISTS metric_helpers CASCADE;
DROP SCHEMA IF EXISTS user_management CASCADE;
DROP SCHEMA IF EXISTS public CASCADE;

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
