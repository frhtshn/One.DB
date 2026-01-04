BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS profile;
CREATE SCHEMA IF NOT EXISTS transaction;
CREATE SCHEMA IF NOT EXISTS wallet;

-- AUTH TABLES
\i tenantdb/tables/auth/players.sql
\i tenantdb/tables/auth/player_categories.sql
\i tenantdb/tables/auth/player_classification.sql
\i tenantdb/tables/auth/player_credentials.sql
\i tenantdb/tables/auth/player_groups.sql

-- PROFILE TABLES
\i tenantdb/tables/profile/player_identity.sql
\i tenantdb/tables/profile/player_profile.sql

-- TRANSACTION TABLES
\i tenantdb/tables/transaction/transactions.sql
\i tenantdb/tables/transaction/transaction_workflows.sql
\i tenantdb/tables/transaction/transaction_workflow_actions.sql

-- WALLET TABLES
\i tenantdb/tables/wallet/wallets.sql
\i tenantdb/tables/wallet/wallet_snapshots.sql

-- FUNCTIONS
-- \i tenantdb/functions/your_function.sql

COMMIT;
