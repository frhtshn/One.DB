SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS backoffice;
COMMENT ON SCHEMA backoffice IS 'Backoffice activity logs';

CREATE SCHEMA IF NOT EXISTS logs;
COMMENT ON SCHEMA logs IS 'System and error logs';

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

-- TABLES (partitioned - daily by created_at/occurred_at)
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
\i core_log/tables/logs/dead_letter_audit.sql
\i core_log/functions/logs/dead_letter_create.sql
\i core_log/functions/logs/dead_letter_get.sql
\i core_log/functions/logs/dead_letter_update_status.sql
\i core_log/functions/logs/dead_letter_list.sql
\i core_log/functions/logs/dead_letter_bulk_retry.sql
\i core_log/functions/logs/dead_letter_bulk_resolve.sql
\i core_log/functions/logs/dead_letter_bulk_ignore.sql
\i core_log/functions/logs/dead_letter_archive.sql
\i core_log/functions/logs/dead_letter_purge.sql
\i core_log/functions/logs/dead_letter_stats_detailed.sql
\i core_log/functions/logs/dead_letter_get_for_auto_retry.sql
\i core_log/functions/logs/dead_letter_schedule_retry.sql
\i core_log/functions/logs/core_audit_create.sql
\i core_log/functions/logs/core_audit_list.sql

-- FUNCTIONS - MAINTENANCE (Partition yönetimi)
\i core_log/functions/maintenance/create_partitions.sql
\i core_log/functions/maintenance/drop_expired_partitions.sql
\i core_log/functions/maintenance/partition_info.sql
\i core_log/functions/maintenance/run_maintenance.sql

-- INDEXES (Performans indexleri - en sonda yükle)
\i core_log/indexes/backoffice.sql
\i core_log/indexes/logs.sql

-- INITIAL PARTITIONS (ilk partition'ları oluştur)
SELECT * FROM maintenance.create_partitions();

COMMIT;
