SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS affiliate_audit;
COMMENT ON SCHEMA affiliate_audit IS 'Affiliate audit logs';

CREATE SCHEMA IF NOT EXISTS kyc_audit;
COMMENT ON SCHEMA kyc_audit IS 'KYC/AML compliance audit records (5-10 year retention)';

CREATE SCHEMA IF NOT EXISTS player_audit;
COMMENT ON SCHEMA player_audit IS 'Player login and session audit logs with GeoIP data';

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

-- =============================================================================
-- AFFILIATE AUDIT TABLES
-- Affiliate Backoffice kullanıcı oturum ve aksiyon logları
-- =============================================================================
\i tenant_audit/tables/affiliate/login_sessions.sql
\i tenant_audit/tables/affiliate/login_attempts.sql
\i tenant_audit/tables/affiliate/user_actions.sql

-- =============================================================================
-- KYC AUDIT TABLES
-- PEP/Sanctions tarama sonuçları ve risk değerlendirmeleri
-- Retention: 5-10 yıl (regulatory compliance)
-- =============================================================================
\i tenant_audit/tables/kyc/player_screening_results.sql
\i tenant_audit/tables/kyc/player_risk_assessments.sql

-- =============================================================================
-- PLAYER AUDIT TABLES (Partitioned)
-- Oyuncu giriş denemeleri (daily) ve oturum kayıtları (monthly) - GeoIP ile
-- =============================================================================
\i tenant_audit/tables/player_audit/login_attempts.sql
\i tenant_audit/tables/player_audit/login_sessions.sql

-- =============================================================================
-- PLAYER AUDIT FUNCTIONS
-- Oyuncu giriş ve oturum yönetim fonksiyonları
-- =============================================================================
-- Login Attempts
\i tenant_audit/functions/player_audit/login_attempt_create.sql
\i tenant_audit/functions/player_audit/login_attempt_list.sql
\i tenant_audit/functions/player_audit/login_attempt_failed_list.sql
-- Login Sessions
\i tenant_audit/functions/player_audit/login_session_create.sql
\i tenant_audit/functions/player_audit/login_session_update_activity.sql
\i tenant_audit/functions/player_audit/login_session_end.sql
\i tenant_audit/functions/player_audit/login_session_list.sql
\i tenant_audit/functions/player_audit/login_session_end_all.sql

-- =============================================================================
-- KYC AUDIT FUNCTIONS (Tarama ve risk değerlendirme)
-- =============================================================================

-- KYC Audit: Screening Results
\i tenant_audit/functions/kyc_audit/screening_result_create.sql
\i tenant_audit/functions/kyc_audit/screening_result_review.sql
\i tenant_audit/functions/kyc_audit/screening_result_get.sql
\i tenant_audit/functions/kyc_audit/screening_result_list.sql

-- KYC Audit: Risk Assessment
\i tenant_audit/functions/kyc_audit/risk_assessment_create.sql
\i tenant_audit/functions/kyc_audit/risk_assessment_get.sql
\i tenant_audit/functions/kyc_audit/risk_assessment_list.sql

-- =============================================================================
-- MAINTENANCE FUNCTIONS (Partition Yönetimi)
-- =============================================================================
\i tenant_audit/functions/maintenance/create_partitions.sql
\i tenant_audit/functions/maintenance/drop_expired_partitions.sql
\i tenant_audit/functions/maintenance/partition_info.sql
\i tenant_audit/functions/maintenance/run_maintenance.sql

-- =============================================================================
-- INDEXES
-- =============================================================================
\i tenant_audit/indexes/affiliate.sql
\i tenant_audit/indexes/kyc.sql
\i tenant_audit/indexes/player_audit.sql

-- =============================================================================
-- PARTITION INITIALIZATION
-- =============================================================================
SELECT * FROM maintenance.create_partitions();

COMMIT;
