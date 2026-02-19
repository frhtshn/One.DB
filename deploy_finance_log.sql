SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS finance_log;
COMMENT ON SCHEMA finance_log IS 'Finance activity logs';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

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

CREATE SCHEMA IF NOT EXISTS maintenance;
COMMENT ON SCHEMA maintenance IS 'Partition management and maintenance utilities';

-- =============================================================================
-- FINANCE LOG TABLES
-- =============================================================================
\i finance_log/tables/finance_log/provider_api_requests.sql
\i finance_log/tables/finance_log/provider_api_callbacks.sql

-- =============================================================================
-- CONSTRAINTS
-- =============================================================================
\i finance_log/constraints/finance_log.sql

-- =============================================================================
-- INDEXES
-- =============================================================================
\i finance_log/indexes/finance_log.sql

-- =============================================================================
-- FUNCTIONS - MAINTENANCE (Partition yönetimi)
-- =============================================================================
\i finance_log/functions/maintenance/create_partitions.sql
\i finance_log/functions/maintenance/drop_expired_partitions.sql
\i finance_log/functions/maintenance/partition_info.sql
\i finance_log/functions/maintenance/run_maintenance.sql

-- INITIAL PARTITIONS
SELECT * FROM maintenance.create_partitions();

COMMIT;
