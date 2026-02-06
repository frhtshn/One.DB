SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS affiliate_log;
COMMENT ON SCHEMA affiliate_log IS 'Affiliate system logs';

CREATE SCHEMA IF NOT EXISTS bonus_log;
COMMENT ON SCHEMA bonus_log IS 'Bonus system logs';

CREATE SCHEMA IF NOT EXISTS kyc_log;
COMMENT ON SCHEMA kyc_log IS 'KYC provider API logs (90+ day retention)';

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
-- AFFILIATE LOG TABLES
-- Affiliate Backoffice API ve işlem logları
-- =============================================================================
\i tenant_log/tables/affiliate/api_requests.sql
\i tenant_log/tables/affiliate/report_generations.sql
\i tenant_log/tables/affiliate/commission_calculations.sql

-- =============================================================================
-- BONUS LOG TABLES
-- Bonus işlem ve aktivite logları
-- =============================================================================
-- \i tenant_log/tables/bonus/transaction_logs.sql
-- \i tenant_log/tables/bonus/rule_execution_logs.sql

-- =============================================================================
-- KYC LOG TABLES
-- KYC provider API call logları
-- Retention: 90+ gün (KYC compliance için uzatılmış)
-- =============================================================================
\i tenant_log/tables/kyc/player_kyc_provider_logs.sql

-- =============================================================================
-- INDEXES
-- =============================================================================
\i tenant_log/indexes/affiliate.sql
-- \i tenant_log/indexes/bonus.sql
\i tenant_log/indexes/kyc.sql

-- =============================================================================
-- FUNCTIONS - MAINTENANCE (Partition yönetimi)
-- =============================================================================
\i tenant_log/functions/maintenance/create_partitions.sql
\i tenant_log/functions/maintenance/drop_expired_partitions.sql
\i tenant_log/functions/maintenance/partition_info.sql
\i tenant_log/functions/maintenance/run_maintenance.sql

-- INITIAL PARTITIONS
SELECT * FROM maintenance.create_partitions();

COMMIT;
