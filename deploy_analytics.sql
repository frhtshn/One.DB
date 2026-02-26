SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS risk;
COMMENT ON SCHEMA risk IS 'Risk analysis baselines and player scores';

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
-- RISK TABLES
-- Risk analiz tabloları (baseline + skor)
-- =============================================================================
\i analytics/tables/risk/risk_player_baselines.sql
\i analytics/tables/risk/risk_tenant_baselines.sql
\i analytics/tables/risk/risk_player_scores.sql

-- =============================================================================
-- FUNCTIONS - Risk (RiskManager)
-- Baseline okuma + skor yazma
-- =============================================================================
\i analytics/functions/risk/player_baseline_list.sql
\i analytics/functions/risk/tenant_baseline_list.sql
\i analytics/functions/risk/player_score_upsert.sql

-- =============================================================================
-- FUNCTIONS - Risk (Report Cluster)
-- Baseline yazma
-- =============================================================================
\i analytics/functions/risk/player_baseline_upsert.sql
\i analytics/functions/risk/tenant_baseline_upsert.sql

-- =============================================================================
-- FUNCTIONS - Risk (BO Cluster)
-- Skor okuma (dashboard + Redis fallback)
-- =============================================================================
\i analytics/functions/risk/player_score_get.sql
\i analytics/functions/risk/player_score_list.sql

-- =============================================================================
-- CONSTRAINTS (CHECK constraints - FK yok)
-- =============================================================================
\i analytics/constraints/risk.sql

-- =============================================================================
-- INDEXES (Performans indexleri - en sonda yükle)
-- =============================================================================
\i analytics/indexes/risk.sql

COMMIT;
