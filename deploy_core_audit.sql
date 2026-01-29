SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS backoffice;
COMMENT ON SCHEMA backoffice IS 'Backoffice audit logs';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA infra;
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;

-- TABLES
\i core_audit/tables/backoffice/auth_audit_log.sql

-- FUNCTIONS
\i core_audit/functions/backoffice/auth_audit_create.sql
\i core_audit/functions/backoffice/auth_audit_list_by_user.sql
\i core_audit/functions/backoffice/auth_audit_list_by_type.sql
\i core_audit/functions/backoffice/auth_audit_failed_logins.sql

-- INDEXES (Performans indexleri - en sonda yükle)
\i core_audit/indexes/backoffice.sql

COMMIT;
