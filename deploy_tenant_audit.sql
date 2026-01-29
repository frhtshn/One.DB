SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS affiliate_audit;
COMMENT ON SCHEMA affiliate_audit IS 'Affiliate audit logs';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

-- DROP UNUSED SCHEMAS
DROP SCHEMA IF EXISTS metric_helpers CASCADE;
DROP SCHEMA IF EXISTS user_management CASCADE;
DROP SCHEMA IF EXISTS public CASCADE;

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;

-- =============================================================================
-- AFFILIATE AUDIT TABLES
-- Affiliate Backoffice kullanıcı oturum ve aksiyon logları
-- =============================================================================
\i tenant_audit/tables/affiliate/login_sessions.sql
\i tenant_audit/tables/affiliate/login_attempts.sql
\i tenant_audit/tables/affiliate/user_actions.sql

-- =============================================================================
-- INDEXES
-- =============================================================================
\i tenant_audit/indexes/affiliate.sql

COMMIT;
