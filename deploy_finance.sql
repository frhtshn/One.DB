SET client_encoding = 'UTF8';
BEGIN;

CREATE SCHEMA IF NOT EXISTS finance;
COMMENT ON SCHEMA finance IS 'Finance gateway integration - payment method and provider catalog';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

CREATE SCHEMA IF NOT EXISTS catalog;
COMMENT ON SCHEMA catalog IS 'Payment provider and method catalog';

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
-- TABLES
-- Ödeme yöntemi ve sağlayıcı kataloğu
-- =============================================================================
\i finance/tables/catalog/payment_providers.sql
\i finance/tables/catalog/payment_methods.sql
\i finance/tables/catalog/payment_method_currency_limits.sql

-- =============================================================================
-- FUNCTIONS
-- =============================================================================
\i finance/functions/catalog/payment_provider_sync.sql
\i finance/functions/catalog/payment_method_create.sql
\i finance/functions/catalog/payment_method_update.sql
\i finance/functions/catalog/payment_method_delete.sql
\i finance/functions/catalog/payment_method_get.sql
\i finance/functions/catalog/payment_method_list.sql
\i finance/functions/catalog/payment_method_lookup.sql
\i finance/functions/catalog/payment_method_currency_limit_sync.sql

-- =============================================================================
-- CONSTRAINTS (FK constraints - en sonda yükle)
-- =============================================================================
\i finance/constraints/catalog.sql

-- =============================================================================
-- INDEXES (Performans indexleri - en sonda yükle)
-- =============================================================================
\i finance/indexes/catalog.sql

-- =============================================================================
-- LOG SCHEMAS (eski finance_log DB)
-- =============================================================================
CREATE SCHEMA IF NOT EXISTS finance_log;
COMMENT ON SCHEMA finance_log IS 'Finance activity logs';

CREATE SCHEMA IF NOT EXISTS maintenance;
COMMENT ON SCHEMA maintenance IS 'Partition management and maintenance utilities';

-- =============================================================================
-- FINANCE LOG TABLES (daily partitioned)
-- =============================================================================
\i finance/tables/finance_log/provider_api_requests.sql
\i finance/tables/finance_log/provider_api_callbacks.sql

-- =============================================================================
-- FINANCE LOG CONSTRAINTS
-- =============================================================================
\i finance/constraints/finance_log.sql

-- =============================================================================
-- FINANCE LOG INDEXES
-- =============================================================================
\i finance/indexes/finance_log.sql

-- =============================================================================
-- FUNCTIONS - MAINTENANCE (Partition yönetimi)
-- =============================================================================
\i finance/functions/maintenance/create_partitions.sql
\i finance/functions/maintenance/drop_expired_partitions.sql
\i finance/functions/maintenance/partition_info.sql
\i finance/functions/maintenance/run_maintenance.sql

-- INITIAL PARTITIONS
SELECT * FROM maintenance.create_partitions();

COMMIT;
