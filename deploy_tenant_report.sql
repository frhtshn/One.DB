SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS finance;
COMMENT ON SCHEMA finance IS 'Financial reporting tables';

CREATE SCHEMA IF NOT EXISTS game;
COMMENT ON SCHEMA game IS 'Game performance reporting tables';

CREATE SCHEMA IF NOT EXISTS support_report;
COMMENT ON SCHEMA support_report IS 'Support ticket statistics and reporting';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

CREATE SCHEMA IF NOT EXISTS maintenance;
COMMENT ON SCHEMA maintenance IS 'Partition management and maintenance utilities';

-- DROP UNUSED SCHEMAS (Clean start)
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

-- FINANCE TABLES
\i tenant_report/tables/finance/player_hourly_stats.sql
\i tenant_report/tables/finance/transaction_hourly_stats.sql
\i tenant_report/tables/finance/system_hourly_kpi.sql

-- GAME TABLES
\i tenant_report/tables/game/game_hourly_stats.sql
\i tenant_report/tables/game/game_performance_daily.sql

-- SUPPORT REPORT TABLES
\i tenant_report/tables/support/ticket_daily_stats.sql

-- CONSTRAINTS
\i tenant_report/constraints/finance.sql
\i tenant_report/constraints/game.sql

-- INDEXES
\i tenant_report/indexes/finance.sql
\i tenant_report/indexes/game.sql

-- FUNCTIONS - MAINTENANCE (Partition yönetimi)
\i tenant_report/functions/maintenance/create_partitions.sql
\i tenant_report/functions/maintenance/drop_expired_partitions.sql
\i tenant_report/functions/maintenance/partition_info.sql
\i tenant_report/functions/maintenance/run_maintenance.sql

-- INITIAL PARTITIONS
SELECT * FROM maintenance.create_partitions();

COMMIT;
