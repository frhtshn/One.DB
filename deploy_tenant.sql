SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS profile;
CREATE SCHEMA IF NOT EXISTS transaction;
CREATE SCHEMA IF NOT EXISTS finance;
CREATE SCHEMA IF NOT EXISTS wallet;
CREATE SCHEMA IF NOT EXISTS game;
CREATE SCHEMA IF NOT EXISTS infra;
CREATE SCHEMA IF NOT EXISTS kyc;
CREATE SCHEMA IF NOT EXISTS bonus;
CREATE SCHEMA IF NOT EXISTS content;

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

-- BONUS TABLES
\i tenant/tables/bonus/bonus_awards.sql
\i tenant/tables/bonus/promo_redemptions.sql

-- CONTENT MANAGEMENT TABLES
\i tenant/tables/content/content_categories.sql
\i tenant/tables/content/content_category_translations.sql
\i tenant/tables/content/content_types.sql
\i tenant/tables/content/content_type_translations.sql
\i tenant/tables/content/contents.sql
\i tenant/tables/content/content_translations.sql
\i tenant/tables/content/content_versions.sql
\i tenant/tables/content/content_attachments.sql
\i tenant/tables/content/faq_categories.sql
\i tenant/tables/content/faq_category_translations.sql
\i tenant/tables/content/faq_items.sql
\i tenant/tables/content/faq_item_translations.sql
\i tenant/tables/content/promotions.sql
\i tenant/tables/content/promotion_translations.sql
\i tenant/tables/content/promotion_banners.sql
\i tenant/tables/content/promotion_display_locations.sql
\i tenant/tables/content/promotion_segments.sql
\i tenant/tables/content/promotion_games.sql

-- Slide Management
\i tenant/tables/content/slide_placements.sql
\i tenant/tables/content/slide_categories.sql
\i tenant/tables/content/slide_category_translations.sql
\i tenant/tables/content/slides.sql
\i tenant/tables/content/slide_translations.sql
\i tenant/tables/content/slide_images.sql
\i tenant/tables/content/slide_schedules.sql

-- Popup Management
\i tenant/tables/content/popup_types.sql
\i tenant/tables/content/popup_type_translations.sql
\i tenant/tables/content/popups.sql
\i tenant/tables/content/popup_translations.sql
\i tenant/tables/content/popup_images.sql
\i tenant/tables/content/popup_schedules.sql

-- VIEWS
\i tenant/views/finance/v_daily_base_rates.sql
\i tenant/views/finance/v_cross_rates.sql

-- FUNCTIONS
-- \i tenant/functions/your_function.sql

-- =============================================================================
-- CONSTRAINTS - Must be loaded AFTER all tables are created
-- =============================================================================
\i tenant/constraints/auth.sql
\i tenant/constraints/profile.sql
\i tenant/constraints/wallet.sql
\i tenant/constraints/transaction.sql
\i tenant/constraints/kyc.sql
\i tenant/constraints/bonus.sql
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

COMMIT;
