SET client_encoding = 'UTF8';

BEGIN;
TR87 0001 2009 1410 0001 3208 19
-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS profile;
CREATE SCHEMA IF NOT EXISTS transaction;
CREATE SCHEMA IF NOT EXISTS finance;
CREATE SCHEMA IF NOT EXISTS wallet;
CREATE SCHEMA IF NOT EXISTS game;
CREATE SCHEMA IF NOT EXISTS infra;
CREATE SCHEMA IF NOT EXISTS kyc;

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA infra;

-- AUTH TABLES
\i tenant/tables/auth/players.sql
\i tenant/tables/auth/player_categories.sql
\i tenant/tables/auth/player_classification.sql
\i tenant/tables/auth/player_credentials.sql
\i tenant/tables/auth/player_groups.sql

-- FINANCE TABLES
\i tenant/tables/finance/operation_types.sql
\i tenant/tables/finance/transaction_types.sql
\i tenant/tables/finance/currency_rates.sql
\i tenant/tables/finance/payment_method_settings.sql
\i tenant/tables/finance/payment_method_limits.sql
\i tenant/tables/finance/payment_player_limits.sql

-- GAME TABLES
\i tenant/tables/game/game_settings.sql

-- PROFILE TABLES
\i tenant/tables/profile/player_identity.sql
\i tenant/tables/profile/player_profile.sql

-- TRANSACTION TABLES
\i tenant/tables/transaction/transactions.sql
\i tenant/tables/transaction/transaction_workflows.sql
\i tenant/tables/transaction/transaction_workflow_actions.sql

-- WALLET TABLES
\i tenant/tables/wallet/wallets.sql
\i tenant/tables/wallet/wallet_snapshots.sql


-- KYC TABLES
\i tenant/tables/kyc/player_kyc_cases.sql
\i tenant/tables/kyc/player_kyc_workflows.sql
\i tenant/tables/kyc/player_documents.sql
\i tenant/tables/kyc/player_kyc_provider_logs.sql

-- VIEWS
\i tenant/views/finance/v_daily_base_rates.sql
\i tenant/views/finance/v_cross_rates.sql

-- FUNCTIONS
-- \i tenant/functions/your_function.sql

COMMIT;
