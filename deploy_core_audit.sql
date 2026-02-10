SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS backoffice;
COMMENT ON SCHEMA backoffice IS 'Backoffice audit logs';

CREATE SCHEMA IF NOT EXISTS maintenance;
COMMENT ON SCHEMA maintenance IS 'Partition management functions';

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
\i core_audit/tables/backoffice/auth_audit_log.sql

-- FUNCTIONS
\i core_audit/functions/backoffice/auth_audit_create.sql
\i core_audit/functions/backoffice/auth_audit_list_by_user.sql
\i core_audit/functions/backoffice/auth_audit_list_by_type.sql
\i core_audit/functions/backoffice/auth_audit_failed_logins.sql

-- MAINTENANCE FUNCTIONS (Partition yönetimi)
\i core_audit/functions/maintenance/create_partitions.sql
\i core_audit/functions/maintenance/drop_expired_partitions.sql
\i core_audit/functions/maintenance/partition_info.sql
\i core_audit/functions/maintenance/run_maintenance.sql

-- INDEXES (Performans indexleri - en sonda yükle)
\i core_audit/indexes/backoffice.sql

-- INITIAL PARTITION SETUP (Bugün + 7 gün ileri)
SELECT * FROM maintenance.create_partitions();

COMMIT;
