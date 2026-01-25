SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS bonus;
CREATE SCHEMA IF NOT EXISTS promotion;
CREATE SCHEMA IF NOT EXISTS campaign;
CREATE SCHEMA IF NOT EXISTS execution;
CREATE SCHEMA IF NOT EXISTS infra;

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA infra;

-- BONUS TABLES
\i bonus/tables/bonus/bonus_types.sql
\i bonus/tables/bonus/bonus_rules.sql
\i bonus/tables/bonus/bonus_triggers.sql

-- PROMOTION TABLES
\i bonus/tables/promotion/promo_codes.sql

-- CAMPAIGN TABLES
\i bonus/tables/campaign/campaigns.sql

-- EXECUTION TABLES
\i bonus/tables/execution/bonus_awards.sql
\i bonus/tables/execution/promo_redemptions.sql

COMMIT;
