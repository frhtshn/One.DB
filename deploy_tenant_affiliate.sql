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
CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA infra;

-- AFFILIATE TABLES
\i tenant_affiliate/tables/affiliate/affiliates.sql
\i tenant_affiliate/tables/affiliate/affiliate_network.sql
\i tenant_affiliate/tables/affiliate/affiliate_users.sql

-- CAMPAIGN TABLES
\i tenant_affiliate/tables/campaign/traffic_sources.sql
\i tenant_affiliate/tables/campaign/campaigns.sql
\i tenant_affiliate/tables/campaign/attribution_models.sql
\i tenant_affiliate/tables/campaign/affiliate_campaigns.sql

-- COMMISSION TABLES
\i tenant_affiliate/tables/commission/commission_plans.sql
\i tenant_affiliate/tables/commission/commission_tiers.sql
\i tenant_affiliate/tables/commission/network_commission_rules.sql
\i tenant_affiliate/tables/commission/network_commission_splits.sql
\i tenant_affiliate/tables/commission/network_commission_distributions.sql
\i tenant_affiliate/tables/commission/cost_allocation_settings.sql
\i tenant_affiliate/tables/commission/negative_balance_carryforward.sql
\i tenant_affiliate/tables/commission/commissions.sql

-- PAYOUT TABLES
\i tenant_affiliate/tables/payout/payout_requests.sql
\i tenant_affiliate/tables/payout/payouts.sql
\i tenant_affiliate/tables/payout/payout_commissions.sql

-- TRACKING TABLES
\i tenant_affiliate/tables/tracking/player_affiliate_current.sql
\i tenant_affiliate/tables/tracking/player_affiliate_history.sql
\i tenant_affiliate/tables/tracking/transaction_events.sql
\i tenant_affiliate/tables/tracking/player_game_stats_daily.sql
\i tenant_affiliate/tables/tracking/player_finance_stats_daily.sql
\i tenant_affiliate/tables/tracking/player_stats_monthly.sql
\i tenant_affiliate/tables/tracking/affiliate_stats_daily.sql
\i tenant_affiliate/tables/tracking/affiliate_stats_monthly.sql
\i tenant_affiliate/tables/tracking/tracking_links.sql
\i tenant_affiliate/tables/tracking/link_clicks.sql
\i tenant_affiliate/tables/tracking/promo_codes.sql
\i tenant_affiliate/tables/tracking/player_registrations.sql

-- =============================================================================
-- CONSTRAINTS - Must be loaded AFTER all tables are created
-- =============================================================================
\i tenant_affiliate/constraints/affiliate.sql
\i tenant_affiliate/constraints/campaign.sql
\i tenant_affiliate/constraints/commission.sql
\i tenant_affiliate/constraints/payout.sql
\i tenant_affiliate/constraints/tracking.sql

-- =============================================================================
-- INDEXES - Must be loaded LAST for optimal performance
-- =============================================================================
\i tenant_affiliate/indexes/affiliate.sql
\i tenant_affiliate/indexes/campaign.sql
\i tenant_affiliate/indexes/commission.sql
\i tenant_affiliate/indexes/payout.sql
\i tenant_affiliate/indexes/tracking.sql

COMMIT;
