SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS bonus;
CREATE SCHEMA IF NOT EXISTS promotion;
CREATE SCHEMA IF NOT EXISTS campaign;
CREATE SCHEMA IF NOT EXISTS infra;

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA infra;

-- BONUS TABLES
\i bonus/tables/bonus/bonus_types.sql
\i bonus/tables/bonus/bonus_rules.sql
\i bonus/tables/bonus/bonus_triggers.sql

-- PROMOTION TABLES
\i bonus/tables/promotion/promo_codes.sql

-- CAMPAIGN TABLES
\i bonus/tables/campaign/campaigns.sql

-- Removed execution tables, moved to deploy_tenant_bonus.sql
COMMIT;
