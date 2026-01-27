SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS affiliate_log;
CREATE SCHEMA IF NOT EXISTS infra;

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;

-- =============================================================================
-- AFFILIATE LOG TABLES
-- Affiliate Backoffice API ve işlem logları
-- =============================================================================
\i tenant_log/tables/affiliate/api_requests.sql
\i tenant_log/tables/affiliate/report_generations.sql
\i tenant_log/tables/affiliate/commission_calculations.sql

-- =============================================================================
-- INDEXES
-- =============================================================================
\i tenant_log/indexes/affiliate.sql

COMMIT;
