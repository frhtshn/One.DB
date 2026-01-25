SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS affiliate;
CREATE SCHEMA IF NOT EXISTS campaign;
CREATE SCHEMA IF NOT EXISTS commission;
CREATE SCHEMA IF NOT EXISTS payout;
CREATE SCHEMA IF NOT EXISTS tracking;
CREATE SCHEMA IF NOT EXISTS infra;

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA infra;

-- AFFILIATE TABLES
\i affiliate/tables/affiliate/affiliates.sql
\i affiliate/tables/affiliate/affiliate_network.sql
\i affiliate/tables/affiliate/affiliate_users.sql

-- CAMPAIGN TABLES
\i affiliate/tables/campaign/traffic_sources.sql
\i affiliate/tables/campaign/campaigns.sql
\i affiliate/tables/campaign/attribution_models.sql
\i affiliate/tables/campaign/affiliate_campaigns.sql

-- COMMISSION TABLES
\i affiliate/tables/commission/commission_plans.sql
\i affiliate/tables/commission/commission_tiers.sql
\i affiliate/tables/commission/network_commission_rules.sql
\i affiliate/tables/commission/commissions.sql

-- PAYOUT TABLES
\i affiliate/tables/payout/payout_requests.sql
\i affiliate/tables/payout/payouts.sql

-- TRACKING TABLES
\i affiliate/tables/tracking/player_affiliate_current.sql
\i affiliate/tables/tracking/player_affiliate_history.sql

COMMIT;
