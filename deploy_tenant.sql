BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS profile;
CREATE SCHEMA IF NOT EXISTS transaction;
CREATE SCHEMA IF NOT EXISTS wallet;

-- AUTH TABLES
\i tenant_/tables/auth/players.sql
\i tenant_/tables/auth/player_categories.sql
\i tenant_/tables/auth/player_classification.sql
\i tenant_/tables/auth/player_credentials.sql
\i tenant_/tables/auth/player_groups.sql

-- PROFILE TABLES
\i tenant_/tables/profile/player_identity.sql
\i tenant_/tables/profile/player_profile.sql

-- TRANSACTION TABLES
\i tenant_/tables/transaction/transactions.sql
\i tenant_/tables/transaction/transaction_workflows.sql
\i tenant_/tables/transaction/transaction_workflow_actions.sql

-- WALLET TABLES
\i tenant_/tables/wallet/wallets.sql
\i tenant_/tables/wallet/wallet_snapshots.sql

-- FUNCTIONS
-- \i tenant_/functions/your_function.sql

COMMIT;
