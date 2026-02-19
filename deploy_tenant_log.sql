SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS affiliate_log;
COMMENT ON SCHEMA affiliate_log IS 'Affiliate system logs';

CREATE SCHEMA IF NOT EXISTS bonus_log;
COMMENT ON SCHEMA bonus_log IS 'Bonus system logs';

CREATE SCHEMA IF NOT EXISTS kyc_log;
COMMENT ON SCHEMA kyc_log IS 'KYC provider API logs (90+ day retention)';

CREATE SCHEMA IF NOT EXISTS messaging_log;
COMMENT ON SCHEMA messaging_log IS 'Message delivery logs (daily partitioned)';

CREATE SCHEMA IF NOT EXISTS game_log;
COMMENT ON SCHEMA game_log IS 'Game round/spin detail logs (per-tenant, daily partitioned)';

CREATE SCHEMA IF NOT EXISTS support_log;
COMMENT ON SCHEMA support_log IS 'Support ticket notification delivery logs (daily partitioned)';

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

\i tenant_log/tables/bonus_log/bonus_evaluation_logs.sql

-- =============================================================================
-- KYC LOG TABLES
-- KYC provider API call logları
-- Retention: 90+ gün (KYC compliance için uzatılmış)
-- =============================================================================
\i tenant_log/tables/kyc/player_kyc_provider_logs.sql

-- =============================================================================
-- MESSAGING LOG TABLES
-- Mesaj gönderim logları
-- Retention: 90 gün (partition ile yönetilir)
-- =============================================================================
\i tenant_log/tables/messaging/message_delivery_logs.sql

-- =============================================================================
-- GAME LOG TABLES
-- Oyun round/spin detay logları (per-tenant izolasyon)
-- Retention: 30 gün (partition ile yönetilir)
-- =============================================================================
\i tenant_log/tables/game_log/game_rounds.sql

-- =============================================================================
-- RECONCILIATION TABLES
-- Provider data feed uzlaştırma tabloları
-- =============================================================================
\i tenant_log/tables/game_log/reconciliation_reports.sql
\i tenant_log/tables/game_log/reconciliation_mismatches.sql

-- =============================================================================
-- SUPPORT LOG TABLES
-- Ticket bildirim gönderim logları
-- Retention: 90 gün (partition ile yönetilir)
-- =============================================================================
\i tenant_log/tables/support/ticket_activity_logs.sql

-- =============================================================================
-- CONSTRAINTS
-- =============================================================================
\i tenant_log/constraints/kyc.sql
\i tenant_log/constraints/messaging.sql
\i tenant_log/constraints/game_log.sql

-- =============================================================================
-- INDEXES
-- =============================================================================
\i tenant_log/indexes/affiliate.sql
\i tenant_log/indexes/bonus_log.sql
\i tenant_log/indexes/kyc.sql
\i tenant_log/indexes/messaging.sql
\i tenant_log/indexes/game_log.sql

-- =============================================================================
-- FUNCTIONS - Game Log (Round yaşam döngüsü)
-- =============================================================================
\i tenant_log/functions/game_log/round_upsert.sql
\i tenant_log/functions/game_log/round_close.sql
\i tenant_log/functions/game_log/round_cancel.sql

-- =============================================================================
-- FUNCTIONS - Reconciliation (Provider uzlaştırma)
-- =============================================================================
\i tenant_log/functions/game_log/reconciliation_report_create.sql
\i tenant_log/functions/game_log/reconciliation_mismatch_upsert.sql
\i tenant_log/functions/game_log/reconciliation_report_list.sql

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
