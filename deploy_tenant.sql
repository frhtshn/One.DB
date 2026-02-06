SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS auth;
COMMENT ON SCHEMA auth IS 'Player authentication and authorization';

CREATE SCHEMA IF NOT EXISTS profile;
COMMENT ON SCHEMA profile IS 'Player profile and identity management';

CREATE SCHEMA IF NOT EXISTS transaction;
COMMENT ON SCHEMA transaction IS 'Financial transactions and workflows';

CREATE SCHEMA IF NOT EXISTS finance;
COMMENT ON SCHEMA finance IS 'Finance operations and currency rates';

CREATE SCHEMA IF NOT EXISTS wallet;
COMMENT ON SCHEMA wallet IS 'Player wallets and balances';

CREATE SCHEMA IF NOT EXISTS game;
COMMENT ON SCHEMA game IS 'Game specifications and limits';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

CREATE SCHEMA IF NOT EXISTS kyc;
COMMENT ON SCHEMA kyc IS 'Know Your Customer (KYC) processes';

CREATE SCHEMA IF NOT EXISTS bonus;
COMMENT ON SCHEMA bonus IS 'Bonus and promotion management';

CREATE SCHEMA IF NOT EXISTS content;
COMMENT ON SCHEMA content IS 'Content management system (CMS)';

CREATE SCHEMA IF NOT EXISTS maintenance;
COMMENT ON SCHEMA maintenance IS 'Partition management and maintenance utilities';

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

-- AUTH TABLES
\i tenant/tables/player_auth/players.sql
\i tenant/tables/player_auth/player_categories.sql
\i tenant/tables/player_auth/player_classification.sql
\i tenant/tables/player_auth/player_credentials.sql
\i tenant/tables/player_auth/player_groups.sql
\i tenant/tables/player_auth/player_password_history.sql

-- FINANCE TABLES
\i tenant/tables/finance/operation_types.sql
\i tenant/tables/finance/transaction_types.sql
\i tenant/tables/finance/currency_rates.sql
\i tenant/tables/finance/payment_method_settings.sql
\i tenant/tables/finance/payment_method_limits.sql
\i tenant/tables/finance/payment_player_limits.sql

-- GAME TABLES
\i tenant/tables/game/game_settings.sql
\i tenant/tables/game/game_limits.sql

-- PROFILE TABLES
\i tenant/tables/player_profile/player_identity.sql
\i tenant/tables/player_profile/player_profile.sql

-- TRANSACTION TABLES
\i tenant/tables/transaction/transactions.sql
\i tenant/tables/transaction/transaction_workflows.sql
\i tenant/tables/transaction/transaction_workflow_actions.sql

-- WALLET TABLES
\i tenant/tables/wallet/wallets.sql
\i tenant/tables/wallet/wallet_snapshots.sql


-- KYC TABLES (Business Data - tenant DB)
\i tenant/tables/kyc/player_kyc_cases.sql
\i tenant/tables/kyc/player_kyc_workflows.sql
\i tenant/tables/kyc/player_documents.sql
\i tenant/tables/kyc/player_limits.sql
\i tenant/tables/kyc/player_restrictions.sql
\i tenant/tables/kyc/player_limit_history.sql
\i tenant/tables/kyc/player_jurisdiction.sql
\i tenant/tables/kyc/player_aml_flags.sql
-- NOTE: player_screening_results, player_risk_assessments -> tenant_audit DB
-- NOTE: player_kyc_provider_logs -> tenant_log DB

-- BONUS TABLES
\i tenant/tables/bonus/awards/bonus_awards.sql
\i tenant/tables/bonus/redemptions/promo_redemptions.sql

-- CONTENT MANAGEMENT TABLES
-- CMS
\i tenant/tables/content/cms/content_categories.sql
\i tenant/tables/content/cms/content_category_translations.sql
\i tenant/tables/content/cms/content_types.sql
\i tenant/tables/content/cms/content_type_translations.sql
\i tenant/tables/content/cms/contents.sql
\i tenant/tables/content/cms/content_translations.sql
\i tenant/tables/content/cms/content_versions.sql
\i tenant/tables/content/cms/content_attachments.sql

-- FAQ
\i tenant/tables/content/faq/faq_categories.sql
\i tenant/tables/content/faq/faq_category_translations.sql
\i tenant/tables/content/faq/faq_items.sql
\i tenant/tables/content/faq/faq_item_translations.sql

-- Promotions
\i tenant/tables/content/promotion/promotion_types.sql
\i tenant/tables/content/promotion/promotion_type_translations.sql
\i tenant/tables/content/promotion/promotions.sql
\i tenant/tables/content/promotion/promotion_translations.sql
\i tenant/tables/content/promotion/promotion_banners.sql
\i tenant/tables/content/promotion/promotion_display_locations.sql
\i tenant/tables/content/promotion/promotion_segments.sql
\i tenant/tables/content/promotion/promotion_games.sql

-- Slide Management
\i tenant/tables/content/slide/slide_placements.sql
\i tenant/tables/content/slide/slide_categories.sql
\i tenant/tables/content/slide/slide_category_translations.sql
\i tenant/tables/content/slide/slides.sql
\i tenant/tables/content/slide/slide_translations.sql
\i tenant/tables/content/slide/slide_images.sql
\i tenant/tables/content/slide/slide_schedules.sql

-- Popup Management
\i tenant/tables/content/popup/popup_types.sql
\i tenant/tables/content/popup/popup_type_translations.sql
\i tenant/tables/content/popup/popups.sql
\i tenant/tables/content/popup/popup_translations.sql
\i tenant/tables/content/popup/popup_images.sql
\i tenant/tables/content/popup/popup_schedules.sql

-- VIEWS
\i tenant/views/v_daily_base_rates.sql
\i tenant/views/v_cross_rates.sql

-- =============================================================================
-- FUNCTIONS - Backoffice (Auth checked in Core DB)
-- =============================================================================
-- TODO: Add backoffice functions when created

-- =============================================================================
-- FUNCTIONS - Frontend (Public content, no auth required)
-- =============================================================================
-- TODO: Add frontend functions when created

-- =============================================================================
-- CONSTRAINTS - Must be loaded AFTER all tables are created
-- =============================================================================
\i tenant/constraints/auth.sql
\i tenant/constraints/profile.sql
\i tenant/constraints/wallet.sql
\i tenant/constraints/transaction.sql
\i tenant/constraints/kyc.sql
\i tenant/constraints/bonus.sql
\i tenant/constraints/game.sql
\i tenant/constraints/finance.sql
\i tenant/constraints/content.sql

-- =============================================================================
-- INDEXES - Must be loaded LAST for optimal performance
-- =============================================================================
\i tenant/indexes/auth.sql
\i tenant/indexes/profile.sql
\i tenant/indexes/wallet.sql
\i tenant/indexes/transaction.sql
\i tenant/indexes/finance.sql
\i tenant/indexes/kyc.sql
\i tenant/indexes/bonus.sql
\i tenant/indexes/game.sql
\i tenant/indexes/content.sql

-- =============================================================================
-- FUNCTIONS - MAINTENANCE (Partition yönetimi)
-- =============================================================================
\i tenant/functions/maintenance/create_partitions.sql
\i tenant/functions/maintenance/drop_expired_partitions.sql
\i tenant/functions/maintenance/partition_info.sql
\i tenant/functions/maintenance/run_maintenance.sql

-- INITIAL PARTITIONS
SELECT * FROM maintenance.create_partitions();

COMMIT;
