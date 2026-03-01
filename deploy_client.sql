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

-- LOG SCHEMAS (eski client_log DB)
CREATE SCHEMA IF NOT EXISTS affiliate_log;
COMMENT ON SCHEMA affiliate_log IS 'Affiliate system logs';

CREATE SCHEMA IF NOT EXISTS bonus_log;
COMMENT ON SCHEMA bonus_log IS 'Bonus system logs';

CREATE SCHEMA IF NOT EXISTS kyc_log;
COMMENT ON SCHEMA kyc_log IS 'KYC provider API logs (90+ day retention)';

CREATE SCHEMA IF NOT EXISTS messaging_log;
COMMENT ON SCHEMA messaging_log IS 'Message delivery logs (daily partitioned)';

CREATE SCHEMA IF NOT EXISTS game_log;
COMMENT ON SCHEMA game_log IS 'Game round/spin detail logs (daily partitioned)';

CREATE SCHEMA IF NOT EXISTS support_log;
COMMENT ON SCHEMA support_log IS 'Support ticket notification delivery logs (daily partitioned)';

-- AUDIT SCHEMAS (eski client_audit DB)
CREATE SCHEMA IF NOT EXISTS affiliate_audit;
COMMENT ON SCHEMA affiliate_audit IS 'Affiliate audit logs';

CREATE SCHEMA IF NOT EXISTS kyc_audit;
COMMENT ON SCHEMA kyc_audit IS 'KYC/AML compliance audit records (5-10 year retention)';

CREATE SCHEMA IF NOT EXISTS player_audit;
COMMENT ON SCHEMA player_audit IS 'Player login and session audit logs with GeoIP data';

-- REPORT SCHEMAS (eski client_report DB)
CREATE SCHEMA IF NOT EXISTS finance_report;
COMMENT ON SCHEMA finance_report IS 'Financial reporting tables';

CREATE SCHEMA IF NOT EXISTS game_report;
COMMENT ON SCHEMA game_report IS 'Game performance reporting tables';

CREATE SCHEMA IF NOT EXISTS support_report;
COMMENT ON SCHEMA support_report IS 'Support ticket statistics and reporting';

-- AFFILIATE SCHEMAS (eski client_affiliate DB)
CREATE SCHEMA IF NOT EXISTS affiliate;
COMMENT ON SCHEMA affiliate IS 'Affiliate structure';

CREATE SCHEMA IF NOT EXISTS campaign;
COMMENT ON SCHEMA campaign IS 'Affiliate campaigns';

CREATE SCHEMA IF NOT EXISTS commission;
COMMENT ON SCHEMA commission IS 'Commission rules and calculations';

CREATE SCHEMA IF NOT EXISTS payout;
COMMENT ON SCHEMA payout IS 'Affiliate payouts';

CREATE SCHEMA IF NOT EXISTS tracking;
COMMENT ON SCHEMA tracking IS 'Affiliate tracking and stats';

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

\i client/tables/player_auth/players.sql
\i client/tables/player_auth/player_categories.sql
\i client/tables/player_auth/player_classification.sql
\i client/tables/player_auth/player_groups.sql
\i client/tables/player_auth/player_password_history.sql
\i client/tables/player_auth/email_verification_tokens.sql
\i client/tables/player_auth/password_reset_tokens.sql
\i client/tables/player_auth/shadow_testers.sql

-- FINANCE TABLES
\i client/tables/finance/currency_rates.sql
\i client/tables/finance/currency_rates_latest.sql
\i client/tables/finance/crypto_rates.sql
\i client/tables/finance/crypto_rates_latest.sql
\i client/tables/finance/payment_method_settings.sql
\i client/tables/finance/payment_method_limits.sql
\i client/tables/finance/payment_player_limits.sql
\i client/tables/finance/player_financial_limits.sql

-- GAME TABLES
\i client/tables/game/game_settings.sql
\i client/tables/game/game_limits.sql
\i client/tables/game/game_sessions.sql

-- Lobby Curation
\i client/tables/game/lobby_sections.sql
\i client/tables/game/lobby_section_translations.sql
\i client/tables/game/lobby_section_games.sql
\i client/tables/game/game_labels.sql

-- PROFILE TABLES
\i client/tables/player_profile/player_identity.sql
\i client/tables/player_profile/player_profile.sql

-- TRANSACTION TABLES
\i client/tables/transaction/operation_types.sql
\i client/tables/transaction/transaction_types.sql
\i client/tables/transaction/transactions.sql
\i client/tables/transaction/transaction_workflows.sql
\i client/tables/transaction/transaction_workflow_actions.sql
\i client/tables/transaction/payment_sessions.sql
\i client/tables/transaction/transaction_adjustments.sql

-- WALLET TABLES
\i client/tables/wallet/wallets.sql
\i client/tables/wallet/wallet_snapshots.sql


-- KYC TABLES (Business Data - client DB)
\i client/tables/kyc/player_kyc_cases.sql
\i client/tables/kyc/player_kyc_workflows.sql
\i client/tables/kyc/player_documents.sql
\i client/tables/kyc/player_limits.sql
\i client/tables/kyc/player_restrictions.sql
\i client/tables/kyc/player_limit_history.sql
\i client/tables/kyc/player_jurisdiction.sql
\i client/tables/kyc/player_aml_flags.sql
\i client/tables/kyc/document_analysis.sql
\i client/tables/kyc/document_decisions.sql
-- NOTE: player_screening_results, player_risk_assessments -> client_audit DB
-- NOTE: player_kyc_provider_logs -> client_log DB

-- BONUS TABLES
\i client/tables/bonus/awards/bonus_awards.sql
\i client/tables/bonus/redemptions/promo_redemptions.sql

-- BONUS REQUEST TABLES
\i client/tables/bonus/requests/bonus_request_settings.sql
\i client/tables/bonus/requests/bonus_requests.sql
\i client/tables/bonus/requests/bonus_request_actions.sql

-- CONTENT MANAGEMENT TABLES
-- CMS
\i client/tables/content/cms/content_categories.sql
\i client/tables/content/cms/content_category_translations.sql
\i client/tables/content/cms/content_types.sql
\i client/tables/content/cms/content_type_translations.sql
\i client/tables/content/cms/contents.sql
\i client/tables/content/cms/content_translations.sql
\i client/tables/content/cms/content_versions.sql
\i client/tables/content/cms/content_attachments.sql

-- FAQ
\i client/tables/content/faq/faq_categories.sql
\i client/tables/content/faq/faq_category_translations.sql
\i client/tables/content/faq/faq_items.sql
\i client/tables/content/faq/faq_item_translations.sql

-- Promotions
\i client/tables/content/promotion/promotion_types.sql
\i client/tables/content/promotion/promotion_type_translations.sql
\i client/tables/content/promotion/promotions.sql
\i client/tables/content/promotion/promotion_translations.sql
\i client/tables/content/promotion/promotion_banners.sql
\i client/tables/content/promotion/promotion_display_locations.sql
\i client/tables/content/promotion/promotion_segments.sql
\i client/tables/content/promotion/promotion_games.sql

-- Slide Management
\i client/tables/content/slide/slide_placements.sql
\i client/tables/content/slide/slide_categories.sql
\i client/tables/content/slide/slide_category_translations.sql
\i client/tables/content/slide/slides.sql
\i client/tables/content/slide/slide_translations.sql
\i client/tables/content/slide/slide_images.sql
\i client/tables/content/slide/slide_schedules.sql

-- Popup Management
\i client/tables/content/popup/popup_types.sql
\i client/tables/content/popup/popup_type_translations.sql
\i client/tables/content/popup/popups.sql
\i client/tables/content/popup/popup_translations.sql
\i client/tables/content/popup/popup_images.sql
\i client/tables/content/popup/popup_schedules.sql

-- Trust & Compliance
\i client/tables/content/trust/trust_logos.sql
\i client/tables/content/trust/operator_licenses.sql

-- SEO Redirects
\i client/tables/content/seo/seo_redirects.sql

-- PRESENTATION TABLES
\i client/tables/presentation/navigation.sql
\i client/tables/presentation/themes.sql
\i client/tables/presentation/layouts.sql

-- Site Identity & Settings
\i client/tables/presentation/site_settings.sql
\i client/tables/presentation/social_links.sql
\i client/tables/presentation/announcement_bars.sql
\i client/tables/presentation/announcement_bar_translations.sql

-- MESSAGING TABLES
\i client/tables/messaging/message_templates.sql
\i client/tables/messaging/message_template_translations.sql
\i client/tables/messaging/message_campaigns.sql
\i client/tables/messaging/message_campaign_translations.sql
\i client/tables/messaging/message_campaign_segments.sql
\i client/tables/messaging/message_campaign_recipients.sql
\i client/tables/messaging/player_messages.sql
\i client/tables/messaging/player_message_preferences.sql

-- SUPPORT TABLES (Ticket Sistemi — Ücretli Plugin)
\i client/tables/support/ticket_categories.sql
\i client/tables/support/tickets.sql
\i client/tables/support/ticket_actions.sql
\i client/tables/support/ticket_tags.sql
\i client/tables/support/ticket_tag_assignments.sql
\i client/tables/support/canned_responses.sql

-- SUPPORT TABLES (Standart Hizmetler)
\i client/tables/support/agent_settings.sql
\i client/tables/support/player_notes.sql
\i client/tables/support/player_representatives.sql
\i client/tables/support/player_representative_history.sql
\i client/tables/support/welcome_call_tasks.sql

-- VIEWS
\i client/views/v_daily_base_rates.sql
\i client/views/v_cross_rates.sql

-- =============================================================================
-- FUNCTIONS - GATEWAY (Oyun ve finans gateway fonksiyonları)
-- =============================================================================

-- Gateway: Finance (Kur senkronizasyonu ve ücret hesaplama)
\i client/functions/gateway/finance/currency_rates_bulk_upsert.sql
\i client/functions/gateway/finance/currency_rates_latest_list.sql
\i client/functions/gateway/finance/crypto_rates_bulk_upsert.sql
\i client/functions/gateway/finance/crypto_rates_latest_list.sql
\i client/functions/gateway/finance/calculate_fee.sql

-- Gateway: Game Sessions (Oyun oturum yönetimi)
\i client/functions/gateway/game/game_session_create.sql
\i client/functions/gateway/game/game_session_validate.sql
\i client/functions/gateway/game/game_session_end.sql

-- Gateway: Payment Sessions (Ödeme oturum yönetimi)
\i client/functions/gateway/transaction/payment_session_create.sql
\i client/functions/gateway/transaction/payment_session_get.sql
\i client/functions/gateway/transaction/payment_session_update.sql

-- Gateway: Wallet (Bahis, kazanç, deposit, withdrawal işlemleri)
\i client/functions/gateway/wallet/player_info_get.sql
\i client/functions/gateway/wallet/player_balance_get.sql
\i client/functions/gateway/wallet/player_balance_per_game_get.sql
\i client/functions/gateway/wallet/bet_process.sql
\i client/functions/gateway/wallet/win_process.sql
\i client/functions/gateway/wallet/rollback_process.sql
\i client/functions/gateway/wallet/jackpot_win_process.sql
\i client/functions/gateway/wallet/bonus_win_process.sql
\i client/functions/gateway/wallet/promo_win_process.sql
\i client/functions/gateway/wallet/adjustment_process.sql
\i client/functions/gateway/wallet/deposit_initiate.sql
\i client/functions/gateway/wallet/deposit_confirm.sql
\i client/functions/gateway/wallet/deposit_fail.sql
\i client/functions/gateway/wallet/withdrawal_initiate.sql
\i client/functions/gateway/wallet/withdrawal_confirm.sql
\i client/functions/gateway/wallet/withdrawal_cancel.sql
\i client/functions/gateway/wallet/withdrawal_fail.sql
\i client/functions/gateway/wallet/wallet_create.sql

-- Gateway: Bonus Provider Mapping (Provider bonus takibi)
\i client/tables/bonus/provider_bonus_mappings.sql
\i client/functions/gateway/bonus/provider_bonus_mapping_create.sql
\i client/functions/gateway/bonus/provider_bonus_mapping_get.sql
\i client/functions/gateway/bonus/provider_bonus_mapping_update_status.sql

-- =============================================================================
-- FUNCTIONS - BACKOFFICE (BO operatör fonksiyonları)
-- =============================================================================

-- Backoffice: Auth — Shadow Test
\i client/functions/backoffice/auth/shadow_tester_add.sql
\i client/functions/backoffice/auth/shadow_tester_remove.sql
\i client/functions/backoffice/auth/shadow_tester_list.sql
\i client/functions/backoffice/auth/shadow_tester_get.sql

-- Backoffice: Auth — Player Segmentation
\i client/functions/backoffice/auth/player_category_create.sql
\i client/functions/backoffice/auth/player_category_update.sql
\i client/functions/backoffice/auth/player_category_get.sql
\i client/functions/backoffice/auth/player_category_list.sql
\i client/functions/backoffice/auth/player_category_delete.sql
\i client/functions/backoffice/auth/player_group_create.sql
\i client/functions/backoffice/auth/player_group_update.sql
\i client/functions/backoffice/auth/player_group_get.sql
\i client/functions/backoffice/auth/player_group_list.sql
\i client/functions/backoffice/auth/player_group_delete.sql

-- Backoffice: Auth — Player Classification
\i client/functions/backoffice/auth/player_classification_assign.sql
\i client/functions/backoffice/auth/player_classification_remove.sql
\i client/functions/backoffice/auth/player_classification_list.sql
\i client/functions/backoffice/auth/player_classification_bulk_assign.sql
\i client/functions/backoffice/auth/player_get_segmentation.sql

-- Backoffice: Auth — Player Management (BO oyuncu yönetimi)
\i client/functions/backoffice/auth/player_get.sql
\i client/functions/backoffice/auth/player_list.sql
\i client/functions/backoffice/auth/player_update_status.sql

-- Backoffice: KYC — Case Management
\i client/functions/backoffice/kyc/kyc_case_create.sql
\i client/functions/backoffice/kyc/kyc_case_update_status.sql
\i client/functions/backoffice/kyc/kyc_case_assign_reviewer.sql
\i client/functions/backoffice/kyc/kyc_case_get.sql
\i client/functions/backoffice/kyc/kyc_case_list.sql

-- Backoffice: KYC — Document Management
\i client/functions/backoffice/kyc/document_upload.sql
\i client/functions/backoffice/kyc/document_review.sql
\i client/functions/backoffice/kyc/document_get.sql
\i client/functions/backoffice/kyc/document_list.sql
\i client/functions/backoffice/kyc/document_list_encrypted.sql
\i client/functions/backoffice/kyc/document_update_encrypted.sql

-- Backoffice: KYC — Document Analysis (IDManager)
\i client/functions/backoffice/kyc/document_analysis_save.sql
\i client/functions/backoffice/kyc/document_analysis_get.sql
\i client/functions/backoffice/kyc/document_analysis_list_by_case.sql
\i client/functions/backoffice/kyc/document_request_reanalysis.sql

-- Backoffice: KYC — Document Decisions
\i client/functions/backoffice/kyc/document_decision_create.sql
\i client/functions/backoffice/kyc/document_decision_list.sql
\i client/functions/backoffice/kyc/document_decision_list_by_case.sql

-- Backoffice: KYC — Restriction Management
\i client/functions/backoffice/kyc/restriction_create.sql
\i client/functions/backoffice/kyc/restriction_revoke.sql
\i client/functions/backoffice/kyc/restriction_get.sql
\i client/functions/backoffice/kyc/restriction_list.sql

-- Backoffice: KYC — Limit Management
\i client/functions/backoffice/kyc/limit_set.sql
\i client/functions/backoffice/kyc/limit_remove.sql
\i client/functions/backoffice/kyc/limit_activate_pending.sql
\i client/functions/backoffice/kyc/limit_get.sql
\i client/functions/backoffice/kyc/limit_history_list.sql

-- Backoffice: KYC — AML Flag Management
\i client/functions/backoffice/kyc/aml_flag_create.sql
\i client/functions/backoffice/kyc/aml_flag_assign.sql
\i client/functions/backoffice/kyc/aml_flag_update_status.sql
\i client/functions/backoffice/kyc/aml_flag_add_decision.sql
\i client/functions/backoffice/kyc/aml_flag_get.sql
\i client/functions/backoffice/kyc/aml_flag_list.sql

-- Backoffice: KYC — Jurisdiction Management
\i client/functions/backoffice/kyc/jurisdiction_create.sql
\i client/functions/backoffice/kyc/jurisdiction_update.sql
\i client/functions/backoffice/kyc/jurisdiction_update_geo.sql
\i client/functions/backoffice/kyc/jurisdiction_get.sql

-- Backoffice: Finance (Ödeme ayarları ve limitler)
\i client/functions/backoffice/finance/payment_method_settings_sync.sql
\i client/functions/backoffice/finance/payment_method_settings_remove.sql
\i client/functions/backoffice/finance/payment_method_settings_get.sql
\i client/functions/backoffice/finance/payment_method_settings_update.sql
\i client/functions/backoffice/finance/payment_method_settings_list.sql
\i client/functions/backoffice/finance/payment_method_limits_sync.sql
\i client/functions/backoffice/finance/payment_method_limit_upsert.sql
\i client/functions/backoffice/finance/payment_method_limit_list.sql
\i client/functions/backoffice/finance/payment_provider_rollout_sync.sql
\i client/functions/backoffice/finance/payment_player_limit_set.sql
\i client/functions/backoffice/finance/payment_player_limit_get.sql
\i client/functions/backoffice/finance/payment_player_limit_list.sql
\i client/functions/backoffice/finance/player_financial_limit_set.sql
\i client/functions/backoffice/finance/player_financial_limit_get.sql
\i client/functions/backoffice/finance/player_financial_limit_list.sql

-- Backoffice: Game — Lobby Curation
\i client/functions/backoffice/game/lobby_section_upsert.sql
\i client/functions/backoffice/game/lobby_section_translation_upsert.sql
\i client/functions/backoffice/game/lobby_section_list.sql
\i client/functions/backoffice/game/lobby_section_delete.sql
\i client/functions/backoffice/game/lobby_section_reorder.sql
\i client/functions/backoffice/game/lobby_section_game_add.sql
\i client/functions/backoffice/game/lobby_section_game_remove.sql
\i client/functions/backoffice/game/lobby_section_game_list.sql
\i client/functions/backoffice/game/game_label_upsert.sql
\i client/functions/backoffice/game/game_label_list.sql
\i client/functions/backoffice/game/game_label_delete.sql

-- Backoffice: Game (Oyun ayarları ve limitler)
\i client/functions/backoffice/game/game_settings_sync.sql
\i client/functions/backoffice/game/game_settings_remove.sql
\i client/functions/backoffice/game/game_settings_get.sql
\i client/functions/backoffice/game/game_settings_update.sql
\i client/functions/backoffice/game/game_settings_list.sql
\i client/functions/backoffice/game/game_limits_sync.sql
\i client/functions/backoffice/game/game_limit_upsert.sql
\i client/functions/backoffice/game/game_limit_list.sql
\i client/functions/backoffice/game/game_provider_rollout_sync.sql

-- Backoffice: Messaging — Campaign Templates
\i client/functions/backoffice/messaging/campaign_template/admin_template_create.sql
\i client/functions/backoffice/messaging/campaign_template/admin_template_update.sql
\i client/functions/backoffice/messaging/campaign_template/admin_template_get.sql
\i client/functions/backoffice/messaging/campaign_template/admin_template_list.sql
-- Backoffice: Messaging — Campaigns
\i client/functions/backoffice/messaging/campaign/admin_campaign_create.sql
\i client/functions/backoffice/messaging/campaign/admin_campaign_update.sql
\i client/functions/backoffice/messaging/campaign/admin_campaign_publish.sql
\i client/functions/backoffice/messaging/campaign/admin_campaign_cancel.sql
\i client/functions/backoffice/messaging/campaign/admin_campaign_get.sql
\i client/functions/backoffice/messaging/campaign/admin_campaign_list.sql
-- Backoffice: Messaging — Player Messages
\i client/functions/backoffice/messaging/player_message/admin_player_message_send.sql
-- Backoffice: Messaging — Message Templates (Bildirim Şablonları)
\i client/functions/backoffice/messaging/message_template/admin_message_template_create.sql
\i client/functions/backoffice/messaging/message_template/admin_message_template_update.sql
\i client/functions/backoffice/messaging/message_template/admin_message_template_get.sql
\i client/functions/backoffice/messaging/message_template/admin_message_template_list.sql
\i client/functions/backoffice/messaging/message_template/admin_message_template_delete.sql
\i client/functions/backoffice/messaging/message_template/message_template_get_by_code.sql

-- Backoffice: Transaction — Lookup Sync (Core→Client katalog senkronizasyonu)
\i client/functions/backoffice/transaction/transaction_types_sync.sql
\i client/functions/backoffice/transaction/operation_types_sync.sql

-- Backoffice: Transaction — Workflow (İşlem onay akışları)
\i client/functions/backoffice/transaction/workflow_create.sql
\i client/functions/backoffice/transaction/workflow_assign.sql
\i client/functions/backoffice/transaction/workflow_approve.sql
\i client/functions/backoffice/transaction/workflow_reject.sql
\i client/functions/backoffice/transaction/workflow_cancel.sql
\i client/functions/backoffice/transaction/workflow_escalate.sql
\i client/functions/backoffice/transaction/workflow_add_note.sql
\i client/functions/backoffice/transaction/workflow_list.sql
\i client/functions/backoffice/transaction/workflow_get.sql

-- Backoffice: Transaction — Account Adjustment (Hesap düzeltme)
\i client/functions/backoffice/transaction/adjustment_create.sql
\i client/functions/backoffice/transaction/adjustment_apply.sql
\i client/functions/backoffice/transaction/adjustment_cancel.sql
\i client/functions/backoffice/transaction/adjustment_get.sql
\i client/functions/backoffice/transaction/adjustment_list.sql

-- Backoffice: Wallet (Manuel deposit/withdrawal)
\i client/functions/backoffice/wallet/deposit_manual_process.sql
\i client/functions/backoffice/wallet/withdrawal_manual_process.sql

-- Backoffice: Bonus — Award ve Promosyon
\i client/functions/backoffice/bonus/bonus_award_create.sql
\i client/functions/backoffice/bonus/bonus_award_get.sql
\i client/functions/backoffice/bonus/bonus_award_list.sql
\i client/functions/backoffice/bonus/bonus_award_cancel.sql
\i client/functions/backoffice/bonus/bonus_award_complete.sql
\i client/functions/backoffice/bonus/bonus_award_expire.sql
\i client/functions/backoffice/bonus/promo_redemption_list.sql

-- Backoffice: Bonus — Request Ayarları
\i client/functions/backoffice/bonus/bonus_request_setting_upsert.sql
\i client/functions/backoffice/bonus/bonus_request_setting_list.sql
\i client/functions/backoffice/bonus/bonus_request_setting_get.sql

-- Backoffice: Bonus — Request Yönetimi
\i client/functions/backoffice/bonus/bonus_request_create.sql
\i client/functions/backoffice/bonus/bonus_request_get.sql
\i client/functions/backoffice/bonus/bonus_request_list.sql
\i client/functions/backoffice/bonus/bonus_request_assign.sql
\i client/functions/backoffice/bonus/bonus_request_start_review.sql
\i client/functions/backoffice/bonus/bonus_request_hold.sql
\i client/functions/backoffice/bonus/bonus_request_approve.sql
\i client/functions/backoffice/bonus/bonus_request_reject.sql
\i client/functions/backoffice/bonus/bonus_request_cancel.sql
\i client/functions/backoffice/bonus/bonus_request_rollback.sql

-- Backoffice: Support — Ticket yönetimi
\i client/functions/backoffice/support/ticket_create.sql
\i client/functions/backoffice/support/ticket_get.sql
\i client/functions/backoffice/support/ticket_list.sql
\i client/functions/backoffice/support/ticket_update.sql
\i client/functions/backoffice/support/ticket_assign.sql
\i client/functions/backoffice/support/ticket_add_note.sql
\i client/functions/backoffice/support/ticket_reply_player.sql
\i client/functions/backoffice/support/ticket_resolve.sql
\i client/functions/backoffice/support/ticket_close.sql
\i client/functions/backoffice/support/ticket_reopen.sql
\i client/functions/backoffice/support/ticket_cancel.sql

-- Backoffice: Support — Player Notes
\i client/functions/backoffice/support/player_note_create.sql
\i client/functions/backoffice/support/player_note_update.sql
\i client/functions/backoffice/support/player_note_delete.sql
\i client/functions/backoffice/support/player_note_list.sql

-- Backoffice: Support — Agent Settings
\i client/functions/backoffice/support/agent_setting_upsert.sql
\i client/functions/backoffice/support/agent_setting_get.sql
\i client/functions/backoffice/support/agent_setting_list.sql

-- Backoffice: Support — Canned Responses
\i client/functions/backoffice/support/canned_response_create.sql
\i client/functions/backoffice/support/canned_response_update.sql
\i client/functions/backoffice/support/canned_response_delete.sql
\i client/functions/backoffice/support/canned_response_list.sql

-- Backoffice: Support — Representative
\i client/functions/backoffice/support/player_representative_assign.sql
\i client/functions/backoffice/support/player_representative_get.sql
\i client/functions/backoffice/support/player_representative_history_list.sql

-- Backoffice: Support — Welcome Call
\i client/functions/backoffice/support/welcome_call_task_list.sql
\i client/functions/backoffice/support/welcome_call_task_assign.sql
\i client/functions/backoffice/support/welcome_call_task_complete.sql
\i client/functions/backoffice/support/welcome_call_task_reschedule.sql

-- Backoffice: Support — Ticket Category
\i client/functions/backoffice/support/ticket_category_create.sql
\i client/functions/backoffice/support/ticket_category_update.sql
\i client/functions/backoffice/support/ticket_category_delete.sql
\i client/functions/backoffice/support/ticket_category_list.sql

-- Backoffice: Support — Ticket Tag
\i client/functions/backoffice/support/ticket_tag_create.sql
\i client/functions/backoffice/support/ticket_tag_update.sql
\i client/functions/backoffice/support/ticket_tag_list.sql

-- Backoffice: Support — Dashboard
\i client/functions/backoffice/support/ticket_queue_list.sql
\i client/functions/backoffice/support/ticket_dashboard_stats.sql

-- Backoffice: Content — CMS (İçerik yönetimi)
\i client/functions/backoffice/content/content_category_upsert.sql
\i client/functions/backoffice/content/content_category_delete.sql
\i client/functions/backoffice/content/content_category_list.sql
\i client/functions/backoffice/content/content_type_upsert.sql
\i client/functions/backoffice/content/content_type_delete.sql
\i client/functions/backoffice/content/content_type_list.sql
\i client/functions/backoffice/content/content_create.sql
\i client/functions/backoffice/content/content_update.sql
\i client/functions/backoffice/content/content_get.sql
\i client/functions/backoffice/content/content_list.sql
\i client/functions/backoffice/content/content_publish.sql

-- Backoffice: Content — FAQ
\i client/functions/backoffice/content/faq_category_upsert.sql
\i client/functions/backoffice/content/faq_category_delete.sql
\i client/functions/backoffice/content/faq_category_list.sql
\i client/functions/backoffice/content/faq_item_upsert.sql
\i client/functions/backoffice/content/faq_item_delete.sql

-- Backoffice: Content — Popup
\i client/functions/backoffice/content/popup_type_upsert.sql
\i client/functions/backoffice/content/popup_type_list.sql
\i client/functions/backoffice/content/popup_create.sql
\i client/functions/backoffice/content/popup_update.sql
\i client/functions/backoffice/content/popup_get.sql
\i client/functions/backoffice/content/popup_list.sql
\i client/functions/backoffice/content/popup_delete.sql
\i client/functions/backoffice/content/popup_toggle_active.sql

-- Backoffice: Content — Promotion
\i client/functions/backoffice/content/promotion_type_upsert.sql
\i client/functions/backoffice/content/promotion_type_list.sql
\i client/functions/backoffice/content/promotion_create.sql
\i client/functions/backoffice/content/promotion_update.sql
\i client/functions/backoffice/content/promotion_get.sql
\i client/functions/backoffice/content/promotion_list.sql
\i client/functions/backoffice/content/promotion_delete.sql
\i client/functions/backoffice/content/promotion_toggle_featured.sql

-- Backoffice: Content — Trust Logos & Operator Licenses
\i client/functions/backoffice/content/trust_logo_upsert.sql
\i client/functions/backoffice/content/trust_logo_list.sql
\i client/functions/backoffice/content/trust_logo_delete.sql
\i client/functions/backoffice/content/trust_logo_reorder.sql
\i client/functions/backoffice/content/operator_license_upsert.sql
\i client/functions/backoffice/content/operator_license_list.sql
\i client/functions/backoffice/content/operator_license_get.sql
\i client/functions/backoffice/content/operator_license_delete.sql

-- Backoffice: Content — SEO Redirects
\i client/functions/backoffice/content/seo_redirect_upsert.sql
\i client/functions/backoffice/content/seo_redirect_list.sql
\i client/functions/backoffice/content/seo_redirect_get_by_slug.sql
\i client/functions/backoffice/content/seo_redirect_delete.sql
\i client/functions/backoffice/content/seo_redirect_bulk_import.sql

-- Backoffice: Content — SEO Meta (CMS)
\i client/functions/backoffice/content/content_seo_meta_update.sql
\i client/functions/backoffice/content/content_seo_meta_get.sql
\i client/functions/backoffice/content/content_seo_status_list.sql

-- Backoffice: Content — Slide/Banner
\i client/functions/backoffice/content/slide_placement_upsert.sql
\i client/functions/backoffice/content/slide_placement_list.sql
\i client/functions/backoffice/content/slide_category_upsert.sql
\i client/functions/backoffice/content/slide_category_list.sql
\i client/functions/backoffice/content/slide_create.sql
\i client/functions/backoffice/content/slide_update.sql
\i client/functions/backoffice/content/slide_get.sql
\i client/functions/backoffice/content/slide_list.sql
\i client/functions/backoffice/content/slide_delete.sql
\i client/functions/backoffice/content/slide_reorder.sql

-- Backoffice: Presentation — Social Links
\i client/functions/backoffice/presentation/social_link_upsert.sql
\i client/functions/backoffice/presentation/social_link_list.sql
\i client/functions/backoffice/presentation/social_link_delete.sql
\i client/functions/backoffice/presentation/social_link_reorder.sql

-- Backoffice: Presentation — Site Settings
\i client/functions/backoffice/presentation/site_settings_upsert.sql
\i client/functions/backoffice/presentation/site_settings_get.sql
\i client/functions/backoffice/presentation/site_settings_update_partial.sql

-- Backoffice: Presentation — Announcement Bars
\i client/functions/backoffice/presentation/announcement_bar_upsert.sql
\i client/functions/backoffice/presentation/announcement_bar_translation_upsert.sql
\i client/functions/backoffice/presentation/announcement_bar_list.sql
\i client/functions/backoffice/presentation/announcement_bar_delete.sql

-- Backoffice: Presentation — Navigation
\i client/functions/backoffice/presentation/navigation_create.sql
\i client/functions/backoffice/presentation/navigation_update.sql
\i client/functions/backoffice/presentation/navigation_delete.sql
\i client/functions/backoffice/presentation/navigation_get.sql
\i client/functions/backoffice/presentation/navigation_list.sql
\i client/functions/backoffice/presentation/navigation_reorder.sql
\i client/functions/backoffice/presentation/navigation_toggle_visible.sql

-- Backoffice: Presentation — Theme
\i client/functions/backoffice/presentation/theme_upsert.sql
\i client/functions/backoffice/presentation/theme_activate.sql
\i client/functions/backoffice/presentation/theme_get.sql
\i client/functions/backoffice/presentation/theme_list.sql

-- Backoffice: Presentation — Layout
\i client/functions/backoffice/presentation/layout_upsert.sql
\i client/functions/backoffice/presentation/layout_delete.sql
\i client/functions/backoffice/presentation/layout_get.sql
\i client/functions/backoffice/presentation/layout_list.sql

-- Backoffice: Messaging — Player Message Preferences
\i client/functions/backoffice/messaging/player_message/player_message_preference_bo_get.sql

-- =============================================================================
-- FUNCTIONS - FRONTEND (Oyuncu frontend fonksiyonları)
-- =============================================================================

-- Frontend: Auth (Oyuncu kayıt, giriş, şifre)
\i client/functions/frontend/auth/player_register.sql
\i client/functions/frontend/auth/player_verify_email.sql
\i client/functions/frontend/auth/player_resend_verification.sql
\i client/functions/frontend/auth/player_authenticate.sql
\i client/functions/frontend/auth/player_login_failed_increment.sql
\i client/functions/frontend/auth/player_login_failed_reset.sql
\i client/functions/frontend/auth/player_change_password.sql
\i client/functions/frontend/auth/player_get_password_hash.sql
\i client/functions/frontend/auth/player_get_password_history.sql
\i client/functions/frontend/auth/player_reset_password_request.sql
\i client/functions/frontend/auth/player_reset_password_confirm.sql
\i client/functions/frontend/auth/player_find_by_email_hash.sql

-- Frontend: Auth — PII Re-encryption (Key rotation batch job)
\i client/functions/frontend/auth/player_list_ids.sql
\i client/functions/frontend/auth/player_get_encrypted_email.sql
\i client/functions/frontend/auth/player_update_encrypted_email.sql

-- Frontend: Profile (Profil ve kimlik yönetimi)
\i client/functions/frontend/profile/player_profile_create.sql
\i client/functions/frontend/profile/player_profile_get.sql
\i client/functions/frontend/profile/player_profile_update.sql
\i client/functions/frontend/profile/player_identity_upsert.sql
\i client/functions/frontend/profile/player_identity_get.sql
\i client/functions/frontend/profile/player_identity_update_encrypted.sql

-- Frontend: Messaging (Mesaj okuma/silme)
\i client/functions/frontend/messaging/player_message_list.sql
\i client/functions/frontend/messaging/player_message_read.sql
\i client/functions/frontend/messaging/player_message_delete.sql

-- Frontend: Bonus (Promo ve bonus talep)
\i client/functions/frontend/bonus/promo_redeem.sql
\i client/functions/frontend/bonus/player_requestable_bonus_types.sql
\i client/functions/frontend/bonus/player_bonus_request_create.sql
\i client/functions/frontend/bonus/player_bonus_request_list.sql
\i client/functions/frontend/bonus/player_bonus_request_cancel.sql

-- Frontend: Support (Ticket self-service)
\i client/functions/frontend/support/player_ticket_create.sql
\i client/functions/frontend/support/player_ticket_list.sql
\i client/functions/frontend/support/player_ticket_get.sql
\i client/functions/frontend/support/player_ticket_reply.sql

-- Frontend: Messaging — Preferences
\i client/functions/frontend/messaging/player_message_preference_get.sql
\i client/functions/frontend/messaging/player_message_preference_upsert.sql

-- Frontend: Content — Public APIs
\i client/functions/frontend/content/public_content_get.sql
\i client/functions/frontend/content/public_content_list.sql
\i client/functions/frontend/content/public_faq_list.sql
\i client/functions/frontend/content/public_faq_get.sql
\i client/functions/frontend/content/public_popup_list.sql
\i client/functions/frontend/content/public_promotion_list.sql
\i client/functions/frontend/content/public_promotion_get.sql
\i client/functions/frontend/content/public_slide_list.sql
\i client/functions/frontend/content/get_public_trust_elements.sql

-- Frontend: Game — Public APIs
\i client/functions/frontend/game/public_lobby_get.sql
\i client/functions/frontend/game/public_game_list.sql

-- Frontend: Presentation — Public APIs
\i client/functions/frontend/presentation/public_navigation_get.sql
\i client/functions/frontend/presentation/public_theme_get.sql
\i client/functions/frontend/presentation/public_layout_get.sql
\i client/functions/frontend/presentation/get_active_announcement_bars.sql

-- =============================================================================
-- CONSTRAINTS - Must be loaded AFTER all tables are created
-- =============================================================================
\i client/constraints/auth.sql
\i client/constraints/profile.sql
\i client/constraints/wallet.sql
\i client/constraints/transaction.sql
\i client/constraints/kyc.sql
\i client/constraints/bonus.sql
\i client/constraints/bonus_requests.sql
\i client/constraints/game.sql
\i client/constraints/finance.sql
\i client/constraints/content.sql
\i client/constraints/messaging.sql
\i client/constraints/presentation.sql
\i client/constraints/support.sql

-- =============================================================================
-- INDEXES - Must be loaded LAST for optimal performance
-- =============================================================================
\i client/indexes/auth.sql
\i client/indexes/profile.sql
\i client/indexes/wallet.sql
\i client/indexes/transaction.sql
\i client/indexes/finance.sql
\i client/indexes/kyc.sql
\i client/indexes/bonus.sql
\i client/indexes/bonus_requests.sql
\i client/indexes/game.sql
\i client/indexes/content.sql
\i client/indexes/messaging.sql
\i client/indexes/presentation.sql
\i client/indexes/support.sql

-- =============================================================================
-- FUNCTIONS - MAINTENANCE (Partition yönetimi)
-- =============================================================================
\i client/functions/maintenance/partition/create_partitions.sql
\i client/functions/maintenance/partition/drop_expired_partitions.sql
\i client/functions/maintenance/partition/partition_info.sql
\i client/functions/maintenance/partition/run_maintenance.sql

-- MAINTENANCE — Bonus (Request expire/cleanup)
\i client/functions/maintenance/bonus/bonus_request_expire.sql
\i client/functions/maintenance/bonus/bonus_request_cleanup.sql

-- MAINTENANCE — Support (Welcome call cleanup)
\i client/functions/maintenance/support/welcome_call_task_cleanup.sql

-- =============================================================================
-- LOG TABLES (eski client_log DB)
-- =============================================================================
\i client/tables/affiliate_log/api_requests.sql
\i client/tables/affiliate_log/report_generations.sql
\i client/tables/affiliate_log/commission_calculations.sql
\i client/tables/bonus_log/bonus_evaluation_logs.sql
\i client/tables/kyc_log/player_kyc_provider_logs.sql
\i client/tables/messaging_log/message_delivery_logs.sql
\i client/tables/game_log/game_rounds.sql
\i client/tables/game_log/reconciliation_reports.sql
\i client/tables/game_log/reconciliation_mismatches.sql
\i client/tables/support_log/ticket_activity_logs.sql

-- =============================================================================
-- AUDIT TABLES (eski client_audit DB)
-- =============================================================================
\i client/tables/affiliate_audit/login_sessions.sql
\i client/tables/affiliate_audit/login_attempts.sql
\i client/tables/affiliate_audit/user_actions.sql
\i client/tables/kyc_audit/player_screening_results.sql
\i client/tables/kyc_audit/player_risk_assessments.sql
\i client/tables/player_audit/login_attempts.sql
\i client/tables/player_audit/login_sessions.sql

-- =============================================================================
-- REPORT TABLES (eski client_report DB)
-- =============================================================================
\i client/tables/finance_report/player_hourly_stats.sql
\i client/tables/finance_report/transaction_hourly_stats.sql
\i client/tables/finance_report/system_hourly_kpi.sql
\i client/tables/game_report/game_hourly_stats.sql
\i client/tables/game_report/game_performance_daily.sql
\i client/tables/support_report/ticket_daily_stats.sql

-- =============================================================================
-- AFFILIATE TABLES (eski client_affiliate DB)
-- =============================================================================
\i client/tables/affiliate/affiliates.sql
DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'affiliate' AND table_name = 'affiliates') THEN
		RAISE EXCEPTION 'affiliate.affiliates tablosu oluşturulamadı!';
	END IF;
END $$;
\i client/tables/affiliate/affiliate_network.sql
\i client/tables/affiliate/affiliate_users.sql

\i client/tables/campaign/traffic_sources.sql
\i client/tables/campaign/campaigns.sql
\i client/tables/campaign/attribution_models.sql
\i client/tables/campaign/affiliate_campaigns.sql

\i client/tables/commission/commission_plans.sql
DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'commission' AND table_name = 'commission_plans') THEN
		RAISE EXCEPTION 'commission.commission_plans tablosu oluşturulamadı!';
	END IF;
END $$;
\i client/tables/commission/commission_tiers.sql
\i client/tables/commission/network_commission_rules.sql
\i client/tables/commission/network_commission_splits.sql
\i client/tables/commission/network_commission_distributions.sql
\i client/tables/commission/cost_allocation_settings.sql
\i client/tables/commission/negative_balance_carryforward.sql
\i client/tables/commission/commissions.sql

\i client/tables/payout/payout_requests.sql
DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'payout' AND table_name = 'payout_requests') THEN
		RAISE EXCEPTION 'payout.payout_requests tablosu oluşturulamadı!';
	END IF;
END $$;
\i client/tables/payout/payouts.sql
DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'payout' AND table_name = 'payouts') THEN
		RAISE EXCEPTION 'payout.payouts tablosu oluşturulamadı!';
	END IF;
END $$;
\i client/tables/payout/payout_commissions.sql

\i client/tables/tracking/player_affiliate_current.sql
\i client/tables/tracking/player_affiliate_history.sql
\i client/tables/tracking/transaction_events.sql
\i client/tables/tracking/player_game_stats_daily.sql
\i client/tables/tracking/player_finance_stats_daily.sql
\i client/tables/tracking/player_stats_monthly.sql
\i client/tables/tracking/affiliate_stats_daily.sql
\i client/tables/tracking/affiliate_stats_monthly.sql
\i client/tables/tracking/tracking_links.sql
\i client/tables/tracking/link_clicks.sql
\i client/tables/tracking/promo_codes.sql
\i client/tables/tracking/player_registrations.sql

-- =============================================================================
-- FUNCTIONS - Log (Game Log, KYC Log)
-- =============================================================================
\i client/functions/log/game_log/round_upsert.sql
\i client/functions/log/game_log/round_close.sql
\i client/functions/log/game_log/round_cancel.sql
\i client/functions/log/game_log/reconciliation_report_create.sql
\i client/functions/log/game_log/reconciliation_mismatch_upsert.sql
\i client/functions/log/game_log/reconciliation_report_list.sql
\i client/functions/log/kyc_log/provider_log_create.sql
\i client/functions/log/kyc_log/provider_log_list.sql

-- =============================================================================
-- FUNCTIONS - Audit (Player Audit, KYC Audit)
-- =============================================================================
\i client/functions/audit/player_audit/login_attempt_create.sql
\i client/functions/audit/player_audit/login_attempt_list.sql
\i client/functions/audit/player_audit/login_attempt_failed_list.sql
\i client/functions/audit/player_audit/login_session_create.sql
\i client/functions/audit/player_audit/login_session_update_activity.sql
\i client/functions/audit/player_audit/login_session_end.sql
\i client/functions/audit/player_audit/login_session_list.sql
\i client/functions/audit/player_audit/login_session_end_all.sql
\i client/functions/audit/kyc_audit/screening_result_create.sql
\i client/functions/audit/kyc_audit/screening_result_review.sql
\i client/functions/audit/kyc_audit/screening_result_get.sql
\i client/functions/audit/kyc_audit/screening_result_list.sql
\i client/functions/audit/kyc_audit/risk_assessment_create.sql
\i client/functions/audit/kyc_audit/risk_assessment_get.sql
\i client/functions/audit/kyc_audit/risk_assessment_list.sql

-- =============================================================================
-- LOG CONSTRAINTS
-- =============================================================================
\i client/constraints/kyc_log.sql
\i client/constraints/messaging_log.sql
\i client/constraints/game_log.sql

-- =============================================================================
-- AUDIT CONSTRAINTS
-- =============================================================================
\i client/constraints/kyc_audit.sql

-- =============================================================================
-- REPORT CONSTRAINTS
-- =============================================================================
\i client/constraints/finance_report.sql
\i client/constraints/game_report.sql

-- =============================================================================
-- AFFILIATE CONSTRAINTS
-- =============================================================================
\i client/constraints/affiliate.sql
\i client/constraints/campaign.sql
\i client/constraints/commission.sql
\i client/constraints/payout.sql
\i client/constraints/tracking.sql

-- =============================================================================
-- LOG INDEXES
-- =============================================================================
\i client/indexes/affiliate_log.sql
\i client/indexes/bonus_log.sql
\i client/indexes/kyc_log.sql
\i client/indexes/messaging_log.sql
\i client/indexes/game_log.sql

-- =============================================================================
-- AUDIT INDEXES
-- =============================================================================
\i client/indexes/affiliate_audit.sql
\i client/indexes/kyc_audit.sql
\i client/indexes/player_audit.sql

-- =============================================================================
-- REPORT INDEXES
-- =============================================================================
\i client/indexes/finance_report.sql
\i client/indexes/game_report.sql

-- =============================================================================
-- AFFILIATE INDEXES
-- =============================================================================
\i client/indexes/affiliate.sql
\i client/indexes/campaign.sql
\i client/indexes/commission.sql
\i client/indexes/payout.sql
\i client/indexes/tracking.sql

-- INITIAL PARTITIONS (birleşik: monthly + daily)
SELECT * FROM maintenance.create_partitions();

COMMIT;
