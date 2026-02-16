SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS game_log;
COMMENT ON SCHEMA game_log IS 'Game provider API call and callback logs (gateway-level, shared)';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

CREATE SCHEMA IF NOT EXISTS maintenance;
COMMENT ON SCHEMA maintenance IS 'Partition management and maintenance utilities';

-- DROP UNUSED SCHEMAS
DROP SCHEMA IF EXISTS metric_helpers CASCADE;
DROP SCHEMA IF EXISTS user_management CASCADE;
DROP SCHEMA IF EXISTS public CASCADE;

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA infra;

-- =============================================================================
-- GAME LOG TABLES
-- =============================================================================
\i game_log/tables/provider_api_requests.sql
\i game_log/tables/provider_api_callbacks.sql

-- =============================================================================
-- CONSTRAINTS
-- =============================================================================
\i game_log/constraints/game_log.sql

-- =============================================================================
-- INDEXES
-- =============================================================================
\i game_log/indexes/game_log.sql

-- =============================================================================
-- FUNCTIONS - MAINTENANCE (Partition yönetimi)
-- =============================================================================
\i game_log/functions/maintenance/create_partitions.sql
\i game_log/functions/maintenance/drop_expired_partitions.sql
\i game_log/functions/maintenance/partition_info.sql
\i game_log/functions/maintenance/run_maintenance.sql

-- INITIAL PARTITIONS
SELECT * FROM maintenance.create_partitions();

COMMIT;
