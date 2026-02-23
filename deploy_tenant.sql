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

CREATE SCHEMA IF NOT EXISTS messaging;
COMMENT ON SCHEMA messaging IS 'Player messaging and campaign management';

CREATE SCHEMA IF NOT EXISTS presentation;
COMMENT ON SCHEMA presentation IS 'Frontend presentation: navigation, themes, layouts';

CREATE SCHEMA IF NOT EXISTS support;
COMMENT ON SCHEMA support IS 'Customer support: tickets, agents, representatives, welcome calls';

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

\i tenant/tables/player_auth/players.sql
\i tenant/tables/player_auth/player_categories.sql
\i tenant/tables/player_auth/player_classification.sql
\i tenant/tables/player_auth/player_groups.sql
\i tenant/tables/player_auth/player_password_history.sql
\i tenant/tables/player_auth/email_verification_tokens.sql
\i tenant/tables/player_auth/password_reset_tokens.sql
\i tenant/tables/player_auth/shadow_testers.sql

-- FINANCE TABLES
\i tenant/tables/finance/currency_rates.sql
\i tenant/tables/finance/currency_rates_latest.sql
\i tenant/tables/finance/crypto_rates.sql
\i tenant/tables/finance/crypto_rates_latest.sql
\i tenant/tables/finance/payment_method_settings.sql
\i tenant/tables/finance/payment_method_limits.sql
\i tenant/tables/finance/payment_player_limits.sql
\i tenant/tables/finance/player_financial_limits.sql

-- GAME TABLES
\i tenant/tables/game/game_settings.sql
\i tenant/tables/game/game_limits.sql
\i tenant/tables/game/game_sessions.sql

-- Lobby Curation
\i tenant/tables/game/lobby_sections.sql
\i tenant/tables/game/lobby_section_translations.sql
\i tenant/tables/game/lobby_section_games.sql
\i tenant/tables/game/game_labels.sql

-- PROFILE TABLES
\i tenant/tables/player_profile/player_identity.sql
\i tenant/tables/player_profile/player_profile.sql

-- TRANSACTION TABLES
\i tenant/tables/transaction/operation_types.sql
\i tenant/tables/transaction/transaction_types.sql
\i tenant/tables/transaction/transactions.sql
\i tenant/tables/transaction/transaction_workflows.sql
\i tenant/tables/transaction/transaction_workflow_actions.sql
\i tenant/tables/transaction/payment_sessions.sql
\i tenant/tables/transaction/transaction_adjustments.sql

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

-- BONUS REQUEST TABLES
\i tenant/tables/bonus/requests/bonus_request_settings.sql
\i tenant/tables/bonus/requests/bonus_requests.sql
\i tenant/tables/bonus/requests/bonus_request_actions.sql

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

-- Trust & Compliance
\i tenant/tables/content/trust/trust_logos.sql
\i tenant/tables/content/trust/operator_licenses.sql

-- SEO Redirects
\i tenant/tables/content/seo/seo_redirects.sql

-- PRESENTATION TABLES
\i tenant/tables/presentation/navigation.sql
\i tenant/tables/presentation/themes.sql
\i tenant/tables/presentation/layouts.sql

-- Site Identity & Settings
\i tenant/tables/presentation/site_settings.sql
\i tenant/tables/presentation/social_links.sql
\i tenant/tables/presentation/announcement_bars.sql
\i tenant/tables/presentation/announcement_bar_translations.sql

-- MESSAGING TABLES
\i tenant/tables/messaging/message_templates.sql
\i tenant/tables/messaging/message_template_translations.sql
\i tenant/tables/messaging/message_campaigns.sql
\i tenant/tables/messaging/message_campaign_translations.sql
\i tenant/tables/messaging/message_campaign_segments.sql
\i tenant/tables/messaging/message_campaign_recipients.sql
\i tenant/tables/messaging/player_messages.sql
\i tenant/tables/messaging/player_message_preferences.sql

-- SUPPORT TABLES (Ticket Sistemi — Ücretli Plugin)
\i tenant/tables/support/ticket_categories.sql
\i tenant/tables/support/tickets.sql
\i tenant/tables/support/ticket_actions.sql
\i tenant/tables/support/ticket_tags.sql
\i tenant/tables/support/ticket_tag_assignments.sql
\i tenant/tables/support/canned_responses.sql

-- SUPPORT TABLES (Standart Hizmetler)
\i tenant/tables/support/agent_settings.sql
\i tenant/tables/support/player_notes.sql
\i tenant/tables/support/player_representatives.sql
\i tenant/tables/support/player_representative_history.sql
\i tenant/tables/support/welcome_call_tasks.sql

-- VIEWS
\i tenant/views/v_daily_base_rates.sql
\i tenant/views/v_cross_rates.sql

-- =============================================================================
-- FUNCTIONS - GATEWAY (Oyun ve finans gateway fonksiyonları)
-- =============================================================================

-- Gateway: Finance (Kur senkronizasyonu ve ücret hesaplama)
\i tenant/functions/gateway/finance/currency_rates_bulk_upsert.sql
\i tenant/functions/gateway/finance/currency_rates_latest_list.sql
\i tenant/functions/gateway/finance/crypto_rates_bulk_upsert.sql
\i tenant/functions/gateway/finance/crypto_rates_latest_list.sql
\i tenant/functions/gateway/finance/calculate_fee.sql

-- Gateway: Game Sessions (Oyun oturum yönetimi)
\i tenant/functions/gateway/game/game_session_create.sql
\i tenant/functions/gateway/game/game_session_validate.sql
\i tenant/functions/gateway/game/game_session_end.sql

-- Gateway: Payment Sessions (Ödeme oturum yönetimi)
\i tenant/functions/gateway/transaction/payment_session_create.sql
\i tenant/functions/gateway/transaction/payment_session_get.sql
\i tenant/functions/gateway/transaction/payment_session_update.sql

-- Gateway: Wallet (Bahis, kazanç, deposit, withdrawal işlemleri)
\i tenant/functions/gateway/wallet/player_info_get.sql
\i tenant/functions/gateway/wallet/player_balance_get.sql
\i tenant/functions/gateway/wallet/player_balance_per_game_get.sql
\i tenant/functions/gateway/wallet/bet_process.sql
\i tenant/functions/gateway/wallet/win_process.sql
\i tenant/functions/gateway/wallet/rollback_process.sql
\i tenant/functions/gateway/wallet/jackpot_win_process.sql
\i tenant/functions/gateway/wallet/bonus_win_process.sql
\i tenant/functions/gateway/wallet/promo_win_process.sql
\i tenant/functions/gateway/wallet/adjustment_process.sql
\i tenant/functions/gateway/wallet/deposit_initiate.sql
\i tenant/functions/gateway/wallet/deposit_confirm.sql
\i tenant/functions/gateway/wallet/deposit_fail.sql
\i tenant/functions/gateway/wallet/withdrawal_initiate.sql
\i tenant/functions/gateway/wallet/withdrawal_confirm.sql
\i tenant/functions/gateway/wallet/withdrawal_cancel.sql
\i tenant/functions/gateway/wallet/withdrawal_fail.sql
\i tenant/functions/gateway/wallet/wallet_create.sql

-- Gateway: Bonus Provider Mapping (Provider bonus takibi)
\i tenant/tables/bonus/provider_bonus_mappings.sql
\i tenant/functions/gateway/bonus/provider_bonus_mapping_create.sql
\i tenant/functions/gateway/bonus/provider_bonus_mapping_get.sql
\i tenant/functions/gateway/bonus/provider_bonus_mapping_update_status.sql

-- =============================================================================
-- FUNCTIONS - BACKOFFICE (BO operatör fonksiyonları)
-- =============================================================================

-- Backoffice: Auth — Shadow Test
\i tenant/functions/backoffice/auth/shadow_tester_add.sql
\i tenant/functions/backoffice/auth/shadow_tester_remove.sql
\i tenant/functions/backoffice/auth/shadow_tester_list.sql
\i tenant/functions/backoffice/auth/shadow_tester_get.sql

-- Backoffice: Auth — Player Segmentation
\i tenant/functions/backoffice/auth/player_category_create.sql
\i tenant/functions/backoffice/auth/player_category_update.sql
\i tenant/functions/backoffice/auth/player_category_get.sql
\i tenant/functions/backoffice/auth/player_category_list.sql
\i tenant/functions/backoffice/auth/player_category_delete.sql
\i tenant/functions/backoffice/auth/player_group_create.sql
\i tenant/functions/backoffice/auth/player_group_update.sql
\i tenant/functions/backoffice/auth/player_group_get.sql
\i tenant/functions/backoffice/auth/player_group_list.sql
\i tenant/functions/backoffice/auth/player_group_delete.sql

-- Backoffice: Auth — Player Classification
\i tenant/functions/backoffice/auth/player_classification_assign.sql
\i tenant/functions/backoffice/auth/player_classification_remove.sql
\i tenant/functions/backoffice/auth/player_classification_list.sql
\i tenant/functions/backoffice/auth/player_classification_bulk_assign.sql
\i tenant/functions/backoffice/auth/player_get_segmentation.sql

-- Backoffice: Auth — Player Management (BO oyuncu yönetimi)
\i tenant/functions/backoffice/auth/player_get.sql
\i tenant/functions/backoffice/auth/player_list.sql
\i tenant/functions/backoffice/auth/player_update_status.sql

-- Backoffice: KYC — Case Management
\i tenant/functions/backoffice/kyc/kyc_case_create.sql
\i tenant/functions/backoffice/kyc/kyc_case_update_status.sql
\i tenant/functions/backoffice/kyc/kyc_case_assign_reviewer.sql
\i tenant/functions/backoffice/kyc/kyc_case_get.sql
\i tenant/functions/backoffice/kyc/kyc_case_list.sql

-- Backoffice: KYC — Document Management
\i tenant/functions/backoffice/kyc/document_upload.sql
\i tenant/functions/backoffice/kyc/document_review.sql
\i tenant/functions/backoffice/kyc/document_get.sql
\i tenant/functions/backoffice/kyc/document_list.sql

-- Backoffice: KYC — Restriction Management
\i tenant/functions/backoffice/kyc/restriction_create.sql
\i tenant/functions/backoffice/kyc/restriction_revoke.sql
\i tenant/functions/backoffice/kyc/restriction_get.sql
\i tenant/functions/backoffice/kyc/restriction_list.sql

-- Backoffice: KYC — Limit Management
\i tenant/functions/backoffice/kyc/limit_set.sql
\i tenant/functions/backoffice/kyc/limit_remove.sql
\i tenant/functions/backoffice/kyc/limit_activate_pending.sql
\i tenant/functions/backoffice/kyc/limit_get.sql
\i tenant/functions/backoffice/kyc/limit_history_list.sql

-- Backoffice: KYC — AML Flag Management
\i tenant/functions/backoffice/kyc/aml_flag_create.sql
\i tenant/functions/backoffice/kyc/aml_flag_assign.sql
\i tenant/functions/backoffice/kyc/aml_flag_update_status.sql
\i tenant/functions/backoffice/kyc/aml_flag_add_decision.sql
\i tenant/functions/backoffice/kyc/aml_flag_get.sql
\i tenant/functions/backoffice/kyc/aml_flag_list.sql

-- Backoffice: KYC — Jurisdiction Management
\i tenant/functions/backoffice/kyc/jurisdiction_create.sql
\i tenant/functions/backoffice/kyc/jurisdiction_update.sql
\i tenant/functions/backoffice/kyc/jurisdiction_update_geo.sql
\i tenant/functions/backoffice/kyc/jurisdiction_get.sql

-- Backoffice: Finance (Ödeme ayarları ve limitler)
\i tenant/functions/backoffice/finance/payment_method_settings_sync.sql
\i tenant/functions/backoffice/finance/payment_method_settings_remove.sql
\i tenant/functions/backoffice/finance/payment_method_settings_get.sql
\i tenant/functions/backoffice/finance/payment_method_settings_update.sql
\i tenant/functions/backoffice/finance/payment_method_settings_list.sql
\i tenant/functions/backoffice/finance/payment_method_limits_sync.sql
\i tenant/functions/backoffice/finance/payment_method_limit_upsert.sql
\i tenant/functions/backoffice/finance/payment_method_limit_list.sql
\i tenant/functions/backoffice/finance/payment_provider_rollout_sync.sql
\i tenant/functions/backoffice/finance/payment_player_limit_set.sql
\i tenant/functions/backoffice/finance/payment_player_limit_get.sql
\i tenant/functions/backoffice/finance/payment_player_limit_list.sql
\i tenant/functions/backoffice/finance/player_financial_limit_set.sql
\i tenant/functions/backoffice/finance/player_financial_limit_get.sql
\i tenant/functions/backoffice/finance/player_financial_limit_list.sql

-- Backoffice: Game — Lobby Curation
\i tenant/functions/backoffice/game/lobby_section_upsert.sql
\i tenant/functions/backoffice/game/lobby_section_translation_upsert.sql
\i tenant/functions/backoffice/game/lobby_section_list.sql
\i tenant/functions/backoffice/game/lobby_section_delete.sql
\i tenant/functions/backoffice/game/lobby_section_reorder.sql
\i tenant/functions/backoffice/game/lobby_section_game_add.sql
\i tenant/functions/backoffice/game/lobby_section_game_remove.sql
\i tenant/functions/backoffice/game/lobby_section_game_list.sql
\i tenant/functions/backoffice/game/game_label_upsert.sql
\i tenant/functions/backoffice/game/game_label_list.sql
\i tenant/functions/backoffice/game/game_label_delete.sql

-- Backoffice: Game (Oyun ayarları ve limitler)
\i tenant/functions/backoffice/game/game_settings_sync.sql
\i tenant/functions/backoffice/game/game_settings_remove.sql
\i tenant/functions/backoffice/game/game_settings_get.sql
\i tenant/functions/backoffice/game/game_settings_update.sql
\i tenant/functions/backoffice/game/game_settings_list.sql
\i tenant/functions/backoffice/game/game_limits_sync.sql
\i tenant/functions/backoffice/game/game_limit_upsert.sql
\i tenant/functions/backoffice/game/game_limit_list.sql
\i tenant/functions/backoffice/game/game_provider_rollout_sync.sql

-- Backoffice: Messaging (Template ve kampanya yönetimi)
\i tenant/functions/backoffice/messaging/admin_template_create.sql
\i tenant/functions/backoffice/messaging/admin_template_update.sql
\i tenant/functions/backoffice/messaging/admin_template_get.sql
\i tenant/functions/backoffice/messaging/admin_template_list.sql
\i tenant/functions/backoffice/messaging/admin_campaign_create.sql
\i tenant/functions/backoffice/messaging/admin_campaign_update.sql
\i tenant/functions/backoffice/messaging/admin_campaign_publish.sql
\i tenant/functions/backoffice/messaging/admin_campaign_cancel.sql
\i tenant/functions/backoffice/messaging/admin_campaign_get.sql
\i tenant/functions/backoffice/messaging/admin_campaign_list.sql
\i tenant/functions/backoffice/messaging/admin_player_message_send.sql

-- Backoffice: Transaction — Lookup Sync (Core→Tenant katalog senkronizasyonu)
\i tenant/functions/backoffice/transaction/transaction_types_sync.sql
\i tenant/functions/backoffice/transaction/operation_types_sync.sql

-- Backoffice: Transaction — Workflow (İşlem onay akışları)
\i tenant/functions/backoffice/transaction/workflow_create.sql
\i tenant/functions/backoffice/transaction/workflow_assign.sql
\i tenant/functions/backoffice/transaction/workflow_approve.sql
\i tenant/functions/backoffice/transaction/workflow_reject.sql
\i tenant/functions/backoffice/transaction/workflow_cancel.sql
\i tenant/functions/backoffice/transaction/workflow_escalate.sql
\i tenant/functions/backoffice/transaction/workflow_add_note.sql
\i tenant/functions/backoffice/transaction/workflow_list.sql
\i tenant/functions/backoffice/transaction/workflow_get.sql

-- Backoffice: Transaction — Account Adjustment (Hesap düzeltme)
\i tenant/functions/backoffice/transaction/adjustment_create.sql
\i tenant/functions/backoffice/transaction/adjustment_apply.sql
\i tenant/functions/backoffice/transaction/adjustment_cancel.sql
\i tenant/functions/backoffice/transaction/adjustment_get.sql
\i tenant/functions/backoffice/transaction/adjustment_list.sql

-- Backoffice: Wallet (Manuel deposit/withdrawal)
\i tenant/functions/backoffice/wallet/deposit_manual_process.sql
\i tenant/functions/backoffice/wallet/withdrawal_manual_process.sql

-- Backoffice: Bonus — Award ve Promosyon
\i tenant/functions/backoffice/bonus/bonus_award_create.sql
\i tenant/functions/backoffice/bonus/bonus_award_get.sql
\i tenant/functions/backoffice/bonus/bonus_award_list.sql
\i tenant/functions/backoffice/bonus/bonus_award_cancel.sql
\i tenant/functions/backoffice/bonus/bonus_award_complete.sql
\i tenant/functions/backoffice/bonus/bonus_award_expire.sql
\i tenant/functions/backoffice/bonus/promo_redemption_list.sql

-- Backoffice: Bonus — Request Ayarları
\i tenant/functions/backoffice/bonus/bonus_request_setting_upsert.sql
\i tenant/functions/backoffice/bonus/bonus_request_setting_list.sql
\i tenant/functions/backoffice/bonus/bonus_request_setting_get.sql

-- Backoffice: Bonus — Request Yönetimi
\i tenant/functions/backoffice/bonus/bonus_request_create.sql
\i tenant/functions/backoffice/bonus/bonus_request_get.sql
\i tenant/functions/backoffice/bonus/bonus_request_list.sql
\i tenant/functions/backoffice/bonus/bonus_request_assign.sql
\i tenant/functions/backoffice/bonus/bonus_request_start_review.sql
\i tenant/functions/backoffice/bonus/bonus_request_hold.sql
\i tenant/functions/backoffice/bonus/bonus_request_approve.sql
\i tenant/functions/backoffice/bonus/bonus_request_reject.sql
\i tenant/functions/backoffice/bonus/bonus_request_cancel.sql
\i tenant/functions/backoffice/bonus/bonus_request_rollback.sql

-- Backoffice: Support — Ticket yönetimi
\i tenant/functions/backoffice/support/ticket_create.sql
\i tenant/functions/backoffice/support/ticket_get.sql
\i tenant/functions/backoffice/support/ticket_list.sql
\i tenant/functions/backoffice/support/ticket_update.sql
\i tenant/functions/backoffice/support/ticket_assign.sql
\i tenant/functions/backoffice/support/ticket_add_note.sql
\i tenant/functions/backoffice/support/ticket_reply_player.sql
\i tenant/functions/backoffice/support/ticket_resolve.sql
\i tenant/functions/backoffice/support/ticket_close.sql
\i tenant/functions/backoffice/support/ticket_reopen.sql
\i tenant/functions/backoffice/support/ticket_cancel.sql

-- Backoffice: Support — Player Notes
\i tenant/functions/backoffice/support/player_note_create.sql
\i tenant/functions/backoffice/support/player_note_update.sql
\i tenant/functions/backoffice/support/player_note_delete.sql
\i tenant/functions/backoffice/support/player_note_list.sql

-- Backoffice: Support — Agent Settings
\i tenant/functions/backoffice/support/agent_setting_upsert.sql
\i tenant/functions/backoffice/support/agent_setting_get.sql
\i tenant/functions/backoffice/support/agent_setting_list.sql

-- Backoffice: Support — Canned Responses
\i tenant/functions/backoffice/support/canned_response_create.sql
\i tenant/functions/backoffice/support/canned_response_update.sql
\i tenant/functions/backoffice/support/canned_response_delete.sql
\i tenant/functions/backoffice/support/canned_response_list.sql

-- Backoffice: Support — Representative
\i tenant/functions/backoffice/support/player_representative_assign.sql
\i tenant/functions/backoffice/support/player_representative_get.sql
\i tenant/functions/backoffice/support/player_representative_history_list.sql

-- Backoffice: Support — Welcome Call
\i tenant/functions/backoffice/support/welcome_call_task_list.sql
\i tenant/functions/backoffice/support/welcome_call_task_assign.sql
\i tenant/functions/backoffice/support/welcome_call_task_complete.sql
\i tenant/functions/backoffice/support/welcome_call_task_reschedule.sql

-- Backoffice: Support — Ticket Category
\i tenant/functions/backoffice/support/ticket_category_create.sql
\i tenant/functions/backoffice/support/ticket_category_update.sql
\i tenant/functions/backoffice/support/ticket_category_delete.sql
\i tenant/functions/backoffice/support/ticket_category_list.sql

-- Backoffice: Support — Ticket Tag
\i tenant/functions/backoffice/support/ticket_tag_create.sql
\i tenant/functions/backoffice/support/ticket_tag_update.sql
\i tenant/functions/backoffice/support/ticket_tag_list.sql

-- Backoffice: Support — Dashboard
\i tenant/functions/backoffice/support/ticket_queue_list.sql
\i tenant/functions/backoffice/support/ticket_dashboard_stats.sql

-- Backoffice: Content — CMS (İçerik yönetimi)
\i tenant/functions/backoffice/content/content_category_upsert.sql
\i tenant/functions/backoffice/content/content_category_delete.sql
\i tenant/functions/backoffice/content/content_category_list.sql
\i tenant/functions/backoffice/content/content_type_upsert.sql
\i tenant/functions/backoffice/content/content_type_delete.sql
\i tenant/functions/backoffice/content/content_type_list.sql
\i tenant/functions/backoffice/content/content_create.sql
\i tenant/functions/backoffice/content/content_update.sql
\i tenant/functions/backoffice/content/content_get.sql
\i tenant/functions/backoffice/content/content_list.sql
\i tenant/functions/backoffice/content/content_publish.sql

-- Backoffice: Content — FAQ
\i tenant/functions/backoffice/content/faq_category_upsert.sql
\i tenant/functions/backoffice/content/faq_category_delete.sql
\i tenant/functions/backoffice/content/faq_category_list.sql
\i tenant/functions/backoffice/content/faq_item_upsert.sql
\i tenant/functions/backoffice/content/faq_item_delete.sql

-- Backoffice: Content — Popup
\i tenant/functions/backoffice/content/popup_type_upsert.sql
\i tenant/functions/backoffice/content/popup_type_list.sql
\i tenant/functions/backoffice/content/popup_create.sql
\i tenant/functions/backoffice/content/popup_update.sql
\i tenant/functions/backoffice/content/popup_get.sql
\i tenant/functions/backoffice/content/popup_list.sql
\i tenant/functions/backoffice/content/popup_delete.sql
\i tenant/functions/backoffice/content/popup_toggle_active.sql

-- Backoffice: Content — Promotion
\i tenant/functions/backoffice/content/promotion_type_upsert.sql
\i tenant/functions/backoffice/content/promotion_type_list.sql
\i tenant/functions/backoffice/content/promotion_create.sql
\i tenant/functions/backoffice/content/promotion_update.sql
\i tenant/functions/backoffice/content/promotion_get.sql
\i tenant/functions/backoffice/content/promotion_list.sql
\i tenant/functions/backoffice/content/promotion_delete.sql
\i tenant/functions/backoffice/content/promotion_toggle_featured.sql

-- Backoffice: Content — Trust Logos & Operator Licenses
\i tenant/functions/backoffice/content/trust_logo_upsert.sql
\i tenant/functions/backoffice/content/trust_logo_list.sql
\i tenant/functions/backoffice/content/trust_logo_delete.sql
\i tenant/functions/backoffice/content/trust_logo_reorder.sql
\i tenant/functions/backoffice/content/operator_license_upsert.sql
\i tenant/functions/backoffice/content/operator_license_list.sql
\i tenant/functions/backoffice/content/operator_license_get.sql
\i tenant/functions/backoffice/content/operator_license_delete.sql

-- Backoffice: Content — SEO Redirects
\i tenant/functions/backoffice/content/seo_redirect_upsert.sql
\i tenant/functions/backoffice/content/seo_redirect_list.sql
\i tenant/functions/backoffice/content/seo_redirect_get_by_slug.sql
\i tenant/functions/backoffice/content/seo_redirect_delete.sql
\i tenant/functions/backoffice/content/seo_redirect_bulk_import.sql

-- Backoffice: Content — SEO Meta (CMS)
\i tenant/functions/backoffice/content/content_seo_meta_update.sql
\i tenant/functions/backoffice/content/content_seo_meta_get.sql
\i tenant/functions/backoffice/content/content_seo_status_list.sql

-- Backoffice: Content — Slide/Banner
\i tenant/functions/backoffice/content/slide_placement_upsert.sql
\i tenant/functions/backoffice/content/slide_placement_list.sql
\i tenant/functions/backoffice/content/slide_category_upsert.sql
\i tenant/functions/backoffice/content/slide_category_list.sql
\i tenant/functions/backoffice/content/slide_create.sql
\i tenant/functions/backoffice/content/slide_update.sql
\i tenant/functions/backoffice/content/slide_get.sql
\i tenant/functions/backoffice/content/slide_list.sql
\i tenant/functions/backoffice/content/slide_delete.sql
\i tenant/functions/backoffice/content/slide_reorder.sql

-- Backoffice: Presentation — Social Links
\i tenant/functions/backoffice/presentation/social_link_upsert.sql
\i tenant/functions/backoffice/presentation/social_link_list.sql
\i tenant/functions/backoffice/presentation/social_link_delete.sql
\i tenant/functions/backoffice/presentation/social_link_reorder.sql

-- Backoffice: Presentation — Site Settings
\i tenant/functions/backoffice/presentation/site_settings_upsert.sql
\i tenant/functions/backoffice/presentation/site_settings_get.sql
\i tenant/functions/backoffice/presentation/site_settings_update_partial.sql

-- Backoffice: Presentation — Announcement Bars
\i tenant/functions/backoffice/presentation/announcement_bar_upsert.sql
\i tenant/functions/backoffice/presentation/announcement_bar_translation_upsert.sql
\i tenant/functions/backoffice/presentation/announcement_bar_list.sql
\i tenant/functions/backoffice/presentation/announcement_bar_delete.sql

-- Backoffice: Presentation — Navigation
\i tenant/functions/backoffice/presentation/navigation_create.sql
\i tenant/functions/backoffice/presentation/navigation_update.sql
\i tenant/functions/backoffice/presentation/navigation_delete.sql
\i tenant/functions/backoffice/presentation/navigation_get.sql
\i tenant/functions/backoffice/presentation/navigation_list.sql
\i tenant/functions/backoffice/presentation/navigation_reorder.sql
\i tenant/functions/backoffice/presentation/navigation_toggle_visible.sql

-- Backoffice: Presentation — Theme
\i tenant/functions/backoffice/presentation/theme_upsert.sql
\i tenant/functions/backoffice/presentation/theme_activate.sql
\i tenant/functions/backoffice/presentation/theme_get.sql
\i tenant/functions/backoffice/presentation/theme_list.sql

-- Backoffice: Presentation — Layout
\i tenant/functions/backoffice/presentation/layout_upsert.sql
\i tenant/functions/backoffice/presentation/layout_delete.sql
\i tenant/functions/backoffice/presentation/layout_get.sql
\i tenant/functions/backoffice/presentation/layout_list.sql

-- Backoffice: Messaging — Player Message Preferences
\i tenant/functions/backoffice/messaging/player_message_preference_bo_get.sql

-- =============================================================================
-- FUNCTIONS - FRONTEND (Oyuncu frontend fonksiyonları)
-- =============================================================================

-- Frontend: Auth (Oyuncu kayıt, giriş, şifre)
\i tenant/functions/frontend/auth/player_register.sql
\i tenant/functions/frontend/auth/player_verify_email.sql
\i tenant/functions/frontend/auth/player_resend_verification.sql
\i tenant/functions/frontend/auth/player_authenticate.sql
\i tenant/functions/frontend/auth/player_login_failed_increment.sql
\i tenant/functions/frontend/auth/player_login_failed_reset.sql
\i tenant/functions/frontend/auth/player_change_password.sql
\i tenant/functions/frontend/auth/player_reset_password_request.sql
\i tenant/functions/frontend/auth/player_reset_password_confirm.sql
\i tenant/functions/frontend/auth/player_find_by_email_hash.sql

-- Frontend: Profile (Profil ve kimlik yönetimi)
\i tenant/functions/frontend/profile/player_profile_create.sql
\i tenant/functions/frontend/profile/player_profile_get.sql
\i tenant/functions/frontend/profile/player_profile_update.sql
\i tenant/functions/frontend/profile/player_identity_upsert.sql
\i tenant/functions/frontend/profile/player_identity_get.sql

-- Frontend: Messaging (Mesaj okuma/silme)
\i tenant/functions/frontend/messaging/player_message_list.sql
\i tenant/functions/frontend/messaging/player_message_read.sql
\i tenant/functions/frontend/messaging/player_message_delete.sql

-- Frontend: Bonus (Promo ve bonus talep)
\i tenant/functions/frontend/bonus/promo_redeem.sql
\i tenant/functions/frontend/bonus/player_requestable_bonus_types.sql
\i tenant/functions/frontend/bonus/player_bonus_request_create.sql
\i tenant/functions/frontend/bonus/player_bonus_request_list.sql
\i tenant/functions/frontend/bonus/player_bonus_request_cancel.sql

-- Frontend: Support (Ticket self-service)
\i tenant/functions/frontend/support/player_ticket_create.sql
\i tenant/functions/frontend/support/player_ticket_list.sql
\i tenant/functions/frontend/support/player_ticket_get.sql
\i tenant/functions/frontend/support/player_ticket_reply.sql

-- Frontend: Messaging — Preferences
\i tenant/functions/frontend/messaging/player_message_preference_get.sql
\i tenant/functions/frontend/messaging/player_message_preference_upsert.sql

-- Frontend: Content — Public APIs
\i tenant/functions/frontend/content/public_content_get.sql
\i tenant/functions/frontend/content/public_content_list.sql
\i tenant/functions/frontend/content/public_faq_list.sql
\i tenant/functions/frontend/content/public_faq_get.sql
\i tenant/functions/frontend/content/public_popup_list.sql
\i tenant/functions/frontend/content/public_promotion_list.sql
\i tenant/functions/frontend/content/public_promotion_get.sql
\i tenant/functions/frontend/content/public_slide_list.sql
\i tenant/functions/frontend/content/get_public_trust_elements.sql

-- Frontend: Game — Public APIs
\i tenant/functions/frontend/game/public_lobby_get.sql
\i tenant/functions/frontend/game/public_game_list.sql

-- Frontend: Presentation — Public APIs
\i tenant/functions/frontend/presentation/public_navigation_get.sql
\i tenant/functions/frontend/presentation/public_theme_get.sql
\i tenant/functions/frontend/presentation/public_layout_get.sql
\i tenant/functions/frontend/presentation/get_active_announcement_bars.sql

-- =============================================================================
-- CONSTRAINTS - Must be loaded AFTER all tables are created
-- =============================================================================
\i tenant/constraints/auth.sql
\i tenant/constraints/profile.sql
\i tenant/constraints/wallet.sql
\i tenant/constraints/transaction.sql
\i tenant/constraints/kyc.sql
\i tenant/constraints/bonus.sql
\i tenant/constraints/bonus_requests.sql
\i tenant/constraints/game.sql
\i tenant/constraints/finance.sql
\i tenant/constraints/content.sql
\i tenant/constraints/messaging.sql
\i tenant/constraints/presentation.sql
\i tenant/constraints/support.sql

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
\i tenant/indexes/bonus_requests.sql
\i tenant/indexes/game.sql
\i tenant/indexes/content.sql
\i tenant/indexes/messaging.sql
\i tenant/indexes/presentation.sql
\i tenant/indexes/support.sql

-- =============================================================================
-- FUNCTIONS - MAINTENANCE (Partition yönetimi)
-- =============================================================================
\i tenant/functions/maintenance/partition/create_partitions.sql
\i tenant/functions/maintenance/partition/drop_expired_partitions.sql
\i tenant/functions/maintenance/partition/partition_info.sql
\i tenant/functions/maintenance/partition/run_maintenance.sql

-- MAINTENANCE — Bonus (Request expire/cleanup)
\i tenant/functions/maintenance/bonus/bonus_request_expire.sql
\i tenant/functions/maintenance/bonus/bonus_request_cleanup.sql

-- MAINTENANCE — Support (Welcome call cleanup)
\i tenant/functions/maintenance/support/welcome_call_task_cleanup.sql

-- INITIAL PARTITIONS
SELECT * FROM maintenance.create_partitions();

COMMIT;
