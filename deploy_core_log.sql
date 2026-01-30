SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS backoffice;
COMMENT ON SCHEMA backoffice IS 'Backoffice activity logs';

CREATE SCHEMA IF NOT EXISTS logs;
COMMENT ON SCHEMA logs IS 'System and error logs';

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

-- TABLES
\i core_log/tables/backoffice/audit_logs.sql
\i core_log/tables/logs/error_logs.sql
\i core_log/tables/logs/dead_letter_messages.sql
\i core_log/tables/logs/audit_logs.sql

-- CONSTRAINTS
\i core_log/constraints/logs.sql

-- FUNCTIONS
\i core_log/functions/backoffice/audit_create.sql
\i core_log/functions/backoffice/audit_list.sql
\i core_log/functions/backoffice/audit_get.sql
\i core_log/functions/logs/error_log.sql
\i core_log/functions/logs/error_list.sql
\i core_log/functions/logs/error_get.sql
\i core_log/functions/logs/error_stats.sql
\i core_log/functions/logs/dead_letter_create.sql
\i core_log/functions/logs/dead_letter_list_pending.sql
\i core_log/functions/logs/dead_letter_get.sql
\i core_log/functions/logs/dead_letter_update_status.sql
\i core_log/functions/logs/dead_letter_stats.sql
\i core_log/functions/logs/dead_letter_retry.sql
\i core_log/functions/logs/core_audit_create.sql
\i core_log/functions/logs/core_audit_list.sql

-- INDEXES (Performans indexleri - en sonda yükle)
\i core_log/indexes/backoffice.sql
\i core_log/indexes/logs.sql

COMMIT;
