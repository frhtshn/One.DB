SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS bonus;
COMMENT ON SCHEMA bonus IS 'Bonus definitions and rules';

CREATE SCHEMA IF NOT EXISTS promotion;
COMMENT ON SCHEMA promotion IS 'Promotion configurations';

CREATE SCHEMA IF NOT EXISTS campaign;
COMMENT ON SCHEMA campaign IS 'Campaign management';

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
-- BONUS TABLES
-- Bonus tanım ve kuralları
-- =============================================================================
\i bonus/tables/bonus/bonus_types.sql
\i bonus/tables/bonus/bonus_rules.sql

-- =============================================================================
-- PROMOTION TABLES
-- Promosyon kodları
-- =============================================================================
\i bonus/tables/promotion/promo_codes.sql

-- =============================================================================
-- CAMPAIGN TABLES
-- Kampanya yönetimi
-- =============================================================================
\i bonus/tables/campaign/campaigns.sql

-- =============================================================================
-- FUNCTIONS - Bonus
-- =============================================================================
\i bonus/functions/bonus/bonus_type_create.sql
\i bonus/functions/bonus/bonus_type_update.sql
\i bonus/functions/bonus/bonus_type_get.sql
\i bonus/functions/bonus/bonus_type_list.sql
\i bonus/functions/bonus/bonus_rule_create.sql
\i bonus/functions/bonus/bonus_rule_update.sql
\i bonus/functions/bonus/bonus_rule_get.sql
\i bonus/functions/bonus/bonus_rule_list.sql
\i bonus/functions/bonus/bonus_rule_delete.sql

-- =============================================================================
-- FUNCTIONS - Campaign
-- =============================================================================
\i bonus/functions/campaign/campaign_create.sql
\i bonus/functions/campaign/campaign_update.sql
\i bonus/functions/campaign/campaign_get.sql
\i bonus/functions/campaign/campaign_list.sql
\i bonus/functions/campaign/campaign_delete.sql

-- =============================================================================
-- FUNCTIONS - Promotion
-- =============================================================================
\i bonus/functions/promotion/promo_code_create.sql
\i bonus/functions/promotion/promo_code_update.sql
\i bonus/functions/promotion/promo_code_get.sql
\i bonus/functions/promotion/promo_code_list.sql

-- =============================================================================
-- CONSTRAINTS (FK constraints - en sonda yükle)
-- =============================================================================
\i bonus/constraints/bonus.sql

-- =============================================================================
-- INDEXES (Performans indexleri - en sonda yükle)
-- =============================================================================
\i bonus/indexes/bonus.sql

COMMIT;
