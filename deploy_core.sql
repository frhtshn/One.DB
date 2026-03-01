SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS catalog;
COMMENT ON SCHEMA catalog IS 'Reference and master data';

CREATE SCHEMA IF NOT EXISTS core;
COMMENT ON SCHEMA core IS 'Client and company information';

CREATE SCHEMA IF NOT EXISTS presentation;
COMMENT ON SCHEMA presentation IS 'Backoffice and Client Frontend configuration';

CREATE SCHEMA IF NOT EXISTS routing;
COMMENT ON SCHEMA routing IS 'Provider endpoint and callback routing';

CREATE SCHEMA IF NOT EXISTS security;
COMMENT ON SCHEMA security IS 'User, role and permission management';

CREATE SCHEMA IF NOT EXISTS billing;
COMMENT ON SCHEMA billing IS 'Commission and billing';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

CREATE SCHEMA IF NOT EXISTS outbox;
COMMENT ON SCHEMA outbox IS 'Transactional outbox pattern for cache invalidation and event publishing';

CREATE SCHEMA IF NOT EXISTS messaging;
COMMENT ON SCHEMA messaging IS 'User messaging system';

CREATE SCHEMA IF NOT EXISTS maintenance;
COMMENT ON SCHEMA maintenance IS 'Partition management functions';

-- Log schemas (eski core_log DB)
CREATE SCHEMA IF NOT EXISTS backoffice_log;
COMMENT ON SCHEMA backoffice_log IS 'Backoffice activity log records';

CREATE SCHEMA IF NOT EXISTS logs;
COMMENT ON SCHEMA logs IS 'System and error logs';

-- Audit schemas (eski core_audit DB)
CREATE SCHEMA IF NOT EXISTS backoffice_audit;
COMMENT ON SCHEMA backoffice_audit IS 'Backoffice authentication audit records';

-- Report schemas (eski core_report DB)
CREATE SCHEMA IF NOT EXISTS finance_report;
COMMENT ON SCHEMA finance_report IS 'Aggregated financial report stats per client/company';

CREATE SCHEMA IF NOT EXISTS billing_report;
COMMENT ON SCHEMA billing_report IS 'Invoicing and commission report data';

CREATE SCHEMA IF NOT EXISTS performance;
COMMENT ON SCHEMA performance IS 'Global system performance stats';

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

-- CATALOG TABLES

-- Reference (Temel referans verileri)
\i core/tables/catalog/reference/countries.sql
\i core/tables/catalog/reference/currencies.sql
\i core/tables/catalog/reference/languages.sql
\i core/tables/catalog/reference/timezones.sql
\i core/tables/catalog/reference/cryptocurrencies.sql

-- Geo (IP çözümleme cache)
\i core/tables/catalog/geo/ip_geo_cache.sql

-- Provider (Sağlayıcı yönetimi)
\i core/tables/catalog/provider/provider_types.sql
\i core/tables/catalog/provider/providers.sql
\i core/tables/catalog/provider/provider_settings.sql

-- Localization (Dil/çeviri yönetimi)
\i core/tables/catalog/localization/localization_keys.sql
\i core/tables/catalog/localization/localization_values.sql

-- Transaction (İşlem tipleri)
\i core/tables/catalog/transaction/operation_types.sql
\i core/tables/catalog/transaction/transaction_types.sql

-- Compliance (Regulatory/KYC/RG)
\i core/tables/catalog/compliance/jurisdictions.sql
\i core/tables/catalog/compliance/kyc_policies.sql
\i core/tables/catalog/compliance/kyc_document_requirements.sql
\i core/tables/catalog/compliance/kyc_level_requirements.sql
\i core/tables/catalog/compliance/responsible_gaming_policies.sql
\i core/tables/catalog/compliance/data_retention_policies.sql

-- UI Kit (Front-end Themes & Widgets)
\i core/tables/catalog/uikit/themes.sql
\i core/tables/catalog/uikit/widgets.sql
\i core/tables/catalog/uikit/ui_positions.sql
\i core/tables/catalog/uikit/navigation_templates.sql
\i core/tables/catalog/uikit/navigation_template_items.sql

-- CORE TABLES

-- Organization (Şirket ve Client yapısı)
\i core/tables/core/organization/companies.sql
\i core/tables/core/organization/clients.sql
\i core/tables/core/organization/departments.sql
\i core/tables/core/organization/user_departments.sql

-- Configuration (Platform ve Client ayarları)
\i core/tables/core/configuration/platform_settings.sql
\i core/tables/core/configuration/client_settings.sql
\i core/tables/core/configuration/client_currencies.sql
\i core/tables/core/configuration/client_cryptocurrencies.sql
\i core/tables/core/configuration/client_languages.sql
\i core/tables/core/configuration/client_jurisdictions.sql
\i core/tables/core/configuration/client_data_policies.sql

-- Infrastructure (Sunucu envanteri ve provisioning)
\i core/tables/core/configuration/infrastructure_servers.sql
\i core/tables/core/configuration/client_servers.sql
\i core/tables/core/configuration/client_provisioning_log.sql
\i core/tables/core/configuration/template_dumps.sql

-- Integration (Oyun, Provider, Ödeme entegrasyonları)
\i core/tables/core/integration/client_games.sql
\i core/tables/core/integration/client_providers.sql
\i core/tables/core/integration/client_provider_limits.sql
\i core/tables/core/integration/client_payment_methods.sql

-- PRESENTATION TABLES
-- Backoffice UI
\i core/tables/presentation/backoffice/contexts.sql
\i core/tables/presentation/backoffice/menu_groups.sql
\i core/tables/presentation/backoffice/menus.sql
\i core/tables/presentation/backoffice/submenus.sql
\i core/tables/presentation/backoffice/pages.sql
\i core/tables/presentation/backoffice/tabs.sql

-- Frontend (Theme Engine)
\i core/tables/presentation/frontend/client_themes.sql
\i core/tables/presentation/frontend/client_layouts.sql
\i core/tables/presentation/frontend/client_navigation.sql

-- ROUTING TABLES
\i core/tables/routing/callback_routes.sql
\i core/tables/routing/provider_callbacks.sql
\i core/tables/routing/provider_endpoints.sql

-- SECURITY TABLES

-- Identity (Kullanıcı kimliği)
\i core/tables/security/identity/users.sql
\i core/tables/security/identity/user_sessions.sql
\i core/tables/security/identity/user_password_history.sql
\i core/tables/security/identity/company_password_policy.sql
\i core/tables/security/identity/auth_tokens.sql

-- RBAC (Rol ve Yetki Yönetimi)
\i core/tables/security/rbac/roles.sql
\i core/tables/security/rbac/permissions.sql
\i core/tables/security/rbac/role_permissions.sql
\i core/tables/security/rbac/user_roles.sql
\i core/tables/security/rbac/user_allowed_clients.sql
\i core/tables/security/rbac/user_permission_overrides.sql
\i core/tables/security/rbac/permission_templates.sql
\i core/tables/security/rbac/permission_template_items.sql
\i core/tables/security/rbac/permission_template_assignments.sql

-- Secrets (Hassas veriler)
\i core/tables/security/secrets/secrets_provider.sql
\i core/tables/security/secrets/secrets_client.sql

-- BILLING TABLES (Client Faturalama - Sortis One'ın Alacakları)
\i core/tables/billing/client/client_billing_periods.sql
\i core/tables/billing/client/client_commission_rates.sql
\i core/tables/billing/client/client_commission_rate_tiers.sql
\i core/tables/billing/client/client_commission_plans.sql
\i core/tables/billing/client/client_commission_plan_tiers.sql
\i core/tables/billing/client/client_commission_aggregates.sql
\i core/tables/billing/client/client_commissions.sql
\i core/tables/billing/client/client_invoices.sql
\i core/tables/billing/client/client_invoice_items.sql
\i core/tables/billing/client/client_invoice_payments.sql

-- BILLING TABLES (Provider Ödemeleri - Sortis One'ın Borçları)
\i core/tables/billing/provider/provider_commission_rates.sql
\i core/tables/billing/provider/provider_commission_tiers.sql
\i core/tables/billing/provider/provider_settlements.sql
\i core/tables/billing/provider/provider_settlement_clients.sql
\i core/tables/billing/provider/provider_invoices.sql
\i core/tables/billing/provider/provider_invoice_items.sql
\i core/tables/billing/provider/provider_payments.sql

-- OUTBOX TABLES
\i core/tables/outbox/outbox_messages.sql

-- MESSAGING TABLES
\i core/tables/messaging/user_message_drafts.sql
\i core/tables/messaging/user_messages.sql
\i core/tables/messaging/message_templates.sql
\i core/tables/messaging/message_template_translations.sql

-- DATA SEEDING
\i core/data/companies.sql
\i core/data/timezones.sql
\i core/data/countries.sql
\i core/data/currencies.sql
\i core/data/cryptocurrencies.sql
\i core/data/languages.sql
\i core/data/transaction_types.sql
\i core/data/operation_types.sql
\i core/data/localization_keys.sql
\i core/data/localization_values_en.sql
\i core/data/localization_values_tr.sql
\i core/data/compliance_seed.sql
\i core/data/security_seed.sql
\i core/data/seed_uikit.sql

-- FUNCTIONS
-- Core Functions
-- Companies
\i core/functions/core/companies/company_list.sql
\i core/functions/core/companies/company_get.sql
\i core/functions/core/companies/company_create.sql
\i core/functions/core/companies/company_update.sql

\i core/functions/core/companies/company_lookup.sql

-- Clients
\i core/functions/core/clients/client_list.sql
\i core/functions/core/clients/client_get.sql
\i core/functions/core/clients/client_create.sql
\i core/functions/core/clients/client_update.sql

\i core/functions/core/clients/client_lookup.sql
\i core/functions/core/clients/client_get_verification_timing.sql

-- Platform Settings
\i core/functions/core/platform_settings/platform_setting_create.sql
\i core/functions/core/platform_settings/platform_setting_update.sql
\i core/functions/core/platform_settings/platform_setting_delete.sql
\i core/functions/core/platform_settings/platform_setting_get.sql
\i core/functions/core/platform_settings/platform_setting_list.sql

-- Client Settings
\i core/functions/core/client_settings/client_setting_upsert.sql
\i core/functions/core/client_settings/client_setting_get.sql
\i core/functions/core/client_settings/client_setting_list.sql
\i core/functions/core/client_settings/client_setting_delete.sql
\i core/functions/core/client_settings/client_setting_list_by_key.sql

-- Client Configs - Currencies
\i core/functions/core/client_currencies/client_currency_upsert.sql
\i core/functions/core/client_currencies/client_currency_list.sql
\i core/functions/core/client_currencies/client_currency_mapping_list.sql

-- Client Configs - Cryptocurrencies
\i core/functions/core/client_cryptocurrencies/client_cryptocurrency_upsert.sql
\i core/functions/core/client_cryptocurrencies/client_cryptocurrency_list.sql
\i core/functions/core/client_cryptocurrencies/client_cryptocurrency_mapping_list.sql

-- Client Configs - Languages
\i core/functions/core/client_languages/client_language_upsert.sql
\i core/functions/core/client_languages/client_language_list.sql

-- Departments
\i core/functions/core/departments/department_create.sql
\i core/functions/core/departments/department_get.sql
\i core/functions/core/departments/department_list.sql
\i core/functions/core/departments/department_lookup.sql
\i core/functions/core/departments/department_update.sql
\i core/functions/core/departments/department_delete.sql
\i core/functions/core/departments/user_department_assign.sql
\i core/functions/core/departments/user_department_list.sql
\i core/functions/core/departments/user_department_remove.sql

-- Infrastructure Functions (Sunucu envanteri)
\i core/functions/core/infrastructure/infrastructure_server_list.sql
\i core/functions/core/infrastructure/infrastructure_server_get.sql
\i core/functions/core/infrastructure/infrastructure_server_create.sql
\i core/functions/core/infrastructure/infrastructure_server_update.sql

-- Provisioning Functions (Client yaşam döngüsü)
\i core/functions/core/provisioning/client_config_auto_populate.sql
\i core/functions/core/provisioning/client_secrets_generate.sql
\i core/functions/core/provisioning/client_provision_start.sql
\i core/functions/core/provisioning/client_provision_step_update.sql
\i core/functions/core/provisioning/client_provision_complete.sql
\i core/functions/core/provisioning/client_provision_fail.sql
\i core/functions/core/provisioning/client_provision_status.sql
\i core/functions/core/provisioning/client_provision_history_list.sql
\i core/functions/core/provisioning/client_decommission_start.sql
\i core/functions/core/provisioning/client_decommission_complete.sql

-- Client Server Functions (Sunucu ataması)
\i core/functions/core/client_servers/client_server_list.sql
\i core/functions/core/client_servers/client_server_assign.sql
\i core/functions/core/client_servers/client_server_update.sql

-- Client Provider Functions (Provider entegrasyonu)
\i core/functions/core/client_providers/client_provider_list.sql
\i core/functions/core/client_providers/client_provider_enable.sql
\i core/functions/core/client_providers/client_provider_disable.sql
\i core/functions/core/client_providers/client_provider_set_rollout.sql

-- Client Game Functions (Oyun yönetimi)
\i core/functions/core/client_games/client_game_list.sql
\i core/functions/core/client_games/client_game_upsert.sql
\i core/functions/core/client_games/client_game_remove.sql
\i core/functions/core/client_games/client_game_refresh.sql

-- Client Payment Method Functions (Ödeme yöntemi)
\i core/functions/core/client_payment_methods/client_payment_method_list.sql
\i core/functions/core/client_payment_methods/client_payment_method_upsert.sql
\i core/functions/core/client_payment_methods/client_payment_method_remove.sql
\i core/functions/core/client_payment_methods/client_payment_method_refresh.sql

-- Client Payment Provider Functions (Ödeme sağlayıcı)
\i core/functions/core/client_payment_providers/client_payment_provider_list.sql
\i core/functions/core/client_payment_providers/client_payment_provider_enable.sql
\i core/functions/core/client_payment_providers/client_payment_provider_disable.sql

-- Country Functions
\i core/functions/catalog/countries/country_list.sql

-- Currency Functions
\i core/functions/catalog/currencies/currency_list.sql
\i core/functions/catalog/currencies/currency_get.sql
\i core/functions/catalog/currencies/currency_create.sql
\i core/functions/catalog/currencies/currency_update.sql
\i core/functions/catalog/currencies/currency_delete.sql

-- Cryptocurrency Functions
\i core/functions/catalog/cryptocurrencies/cryptocurrency_upsert.sql
\i core/functions/catalog/cryptocurrencies/cryptocurrency_list.sql
\i core/functions/catalog/cryptocurrencies/cryptocurrency_get.sql
\i core/functions/catalog/cryptocurrencies/cryptocurrency_update.sql
\i core/functions/catalog/cryptocurrencies/cryptocurrency_delete.sql

-- Language Functions
\i core/functions/catalog/languages/language_list.sql
\i core/functions/catalog/languages/language_get.sql
\i core/functions/catalog/languages/language_create.sql
\i core/functions/catalog/languages/language_update.sql
\i core/functions/catalog/languages/language_delete.sql

-- Timezone Functions
\i core/functions/catalog/timezones/timezone_list.sql

-- Transaction Type Functions
\i core/functions/catalog/transaction/transaction_type_list.sql

-- Operation Type Functions
\i core/functions/catalog/transaction/operation_type_list.sql

-- Geo Functions (IP çözümleme cache)
\i core/functions/catalog/geo/ip_geo_cache_upsert.sql
\i core/functions/catalog/geo/ip_geo_cache_get.sql
\i core/functions/catalog/geo/ip_geo_cache_cleanup.sql

-- Localization Functions
-- Localization Functions
\i core/functions/catalog/localization/localization_key_list.sql
\i core/functions/catalog/localization/localization_key_get.sql
\i core/functions/catalog/localization/localization_key_create.sql
\i core/functions/catalog/localization/localization_key_update.sql
\i core/functions/catalog/localization/localization_key_delete.sql
\i core/functions/catalog/localization/localization_value_upsert.sql
\i core/functions/catalog/localization/localization_value_delete.sql
\i core/functions/catalog/localization/localization_domain_list.sql
\i core/functions/catalog/localization/localization_category_list.sql
\i core/functions/catalog/localization/localization_export.sql
\i core/functions/catalog/localization/localization_import.sql
\i core/functions/catalog/localization/localization_messages_get.sql

-- Provider Type Functions
\i core/functions/catalog/providers/provider_type_list.sql
\i core/functions/catalog/providers/provider_type_get.sql
\i core/functions/catalog/providers/provider_type_create.sql
\i core/functions/catalog/providers/provider_type_update.sql
\i core/functions/catalog/providers/provider_type_delete.sql
\i core/functions/catalog/providers/provider_type_lookup.sql

-- Provider Functions
\i core/functions/catalog/providers/provider_list.sql
\i core/functions/catalog/providers/provider_get.sql
\i core/functions/catalog/providers/provider_create.sql
\i core/functions/catalog/providers/provider_update.sql
\i core/functions/catalog/providers/provider_delete.sql
\i core/functions/catalog/providers/provider_lookup.sql

-- Provider Setting Functions
\i core/functions/catalog/providers/provider_setting_list.sql
\i core/functions/catalog/providers/provider_setting_get.sql
\i core/functions/catalog/providers/provider_setting_upsert.sql
\i core/functions/catalog/providers/provider_setting_delete.sql

-- Compliance Functions
-- Jurisdictions
\i core/functions/catalog/compliance/jurisdiction_list.sql
\i core/functions/catalog/compliance/jurisdiction_get.sql
\i core/functions/catalog/compliance/jurisdiction_create.sql
\i core/functions/catalog/compliance/jurisdiction_update.sql
\i core/functions/catalog/compliance/jurisdiction_delete.sql
\i core/functions/catalog/compliance/jurisdiction_lookup.sql

-- KYC Policies
\i core/functions/catalog/compliance/kyc_policy_list.sql
\i core/functions/catalog/compliance/kyc_policy_get.sql
\i core/functions/catalog/compliance/kyc_policy_create.sql
\i core/functions/catalog/compliance/kyc_policy_update.sql
\i core/functions/catalog/compliance/kyc_policy_delete.sql

-- KYC Document Requirements
\i core/functions/catalog/compliance/kyc_document_requirement_list.sql
\i core/functions/catalog/compliance/kyc_document_requirement_get.sql
\i core/functions/catalog/compliance/kyc_document_requirement_create.sql
\i core/functions/catalog/compliance/kyc_document_requirement_update.sql
\i core/functions/catalog/compliance/kyc_document_requirement_delete.sql

-- KYC Level Requirements
\i core/functions/catalog/compliance/kyc_level_requirement_list.sql
\i core/functions/catalog/compliance/kyc_level_requirement_get.sql
\i core/functions/catalog/compliance/kyc_level_requirement_create.sql
\i core/functions/catalog/compliance/kyc_level_requirement_update.sql
\i core/functions/catalog/compliance/kyc_level_requirement_delete.sql

-- Responsible Gaming Policies
\i core/functions/catalog/compliance/responsible_gaming_policy_list.sql
\i core/functions/catalog/compliance/responsible_gaming_policy_get.sql
\i core/functions/catalog/compliance/responsible_gaming_policy_create.sql
\i core/functions/catalog/compliance/responsible_gaming_policy_update.sql
\i core/functions/catalog/compliance/responsible_gaming_policy_delete.sql

-- Data Retention Policies
\i core/functions/catalog/compliance/data_retention_policy_list.sql
\i core/functions/catalog/compliance/data_retention_policy_get.sql
\i core/functions/catalog/compliance/data_retention_policy_create.sql
\i core/functions/catalog/compliance/data_retention_policy_update.sql
\i core/functions/catalog/compliance/data_retention_policy_delete.sql
\i core/functions/catalog/compliance/data_retention_policy_lookup.sql

-- UIKit Functions
-- Themes
\i core/functions/catalog/uikit/theme_list.sql
\i core/functions/catalog/uikit/theme_get.sql
\i core/functions/catalog/uikit/theme_create.sql
\i core/functions/catalog/uikit/theme_update.sql
\i core/functions/catalog/uikit/theme_delete.sql
\i core/functions/catalog/uikit/theme_lookup.sql

-- Widgets
\i core/functions/catalog/uikit/widget_list.sql
\i core/functions/catalog/uikit/widget_get.sql
\i core/functions/catalog/uikit/widget_create.sql
\i core/functions/catalog/uikit/widget_update.sql
\i core/functions/catalog/uikit/widget_delete.sql

-- UI Positions
\i core/functions/catalog/uikit/ui_position_list.sql
\i core/functions/catalog/uikit/ui_position_get.sql
\i core/functions/catalog/uikit/ui_position_create.sql
\i core/functions/catalog/uikit/ui_position_update.sql
\i core/functions/catalog/uikit/ui_position_delete.sql

-- Navigation Templates
\i core/functions/catalog/uikit/navigation_template_list.sql
\i core/functions/catalog/uikit/navigation_template_get.sql
\i core/functions/catalog/uikit/navigation_template_create.sql
\i core/functions/catalog/uikit/navigation_template_update.sql
\i core/functions/catalog/uikit/navigation_template_delete.sql
\i core/functions/catalog/uikit/navigation_template_lookup.sql

-- Navigation Template Items
\i core/functions/catalog/uikit/navigation_template_item_list.sql
\i core/functions/catalog/uikit/navigation_template_item_get.sql
\i core/functions/catalog/uikit/navigation_template_item_create.sql
\i core/functions/catalog/uikit/navigation_template_item_update.sql
\i core/functions/catalog/uikit/navigation_template_item_delete.sql

-- Access Helper Functions (IDOR Protection)
\i core/functions/security/access/user_get_access_level.sql
\i core/functions/security/access/user_can_access_client.sql
\i core/functions/security/access/user_can_access_company.sql
\i core/functions/security/access/user_can_manage_user.sql
\i core/functions/security/access/user_assert_access_client.sql
\i core/functions/security/access/user_assert_access_company.sql
\i core/functions/security/access/user_assert_manage_user.sql

-- Session Functions
\i core/functions/security/session/session_list.sql
\i core/functions/security/session/session_save.sql
\i core/functions/security/session/session_revoke.sql
\i core/functions/security/session/session_revoke_all.sql
\i core/functions/security/session/session_cleanup_expired.sql
\i core/functions/security/session/session_belongs_to_user.sql
\i core/functions/security/session/session_update_activity.sql
\i core/functions/security/session/session_enforce_limit.sql

-- User Functions
\i core/functions/security/users/user_check_email_exists.sql
\i core/functions/security/users/user_check_username_exists.sql
\i core/functions/security/users/user_create.sql
\i core/functions/security/users/user_update.sql
\i core/functions/security/users/user_delete.sql
\i core/functions/security/users/user_get.sql
\i core/functions/security/users/user_list.sql
\i core/functions/security/users/user_reset_password.sql
\i core/functions/security/users/user_change_password.sql
\i core/functions/security/users/user_login_failed_increment.sql
\i core/functions/security/users/user_login_failed_reset.sql
\i core/functions/security/users/user_unlock.sql
\i core/functions/security/users/user_get_password_hash.sql
\i core/functions/security/users/user_password_history_list.sql
\i core/functions/security/users/user_2fa_get_secret.sql
\i core/functions/security/users/user_2fa_set.sql

-- Permission Functions
\i core/functions/security/permissions/permission_exists.sql
\i core/functions/security/permissions/permission_category_list.sql
\i core/functions/security/permissions/permission_list.sql
\i core/functions/security/permissions/permission_get.sql
\i core/functions/security/permissions/permission_create.sql
\i core/functions/security/permissions/permission_update.sql

\i core/functions/security/permissions/permission_cleanup_expired.sql
\i core/functions/security/permissions/permission_check.sql
\i core/functions/security/permissions/user_permission_list.sql
\i core/functions/security/permissions/user_permission_override_list.sql
\i core/functions/security/permissions/user_permission_override_load.sql
\i core/functions/security/permissions/user_permission_set.sql
\i core/functions/security/permissions/user_permission_set_with_outbox.sql
\i core/functions/security/permissions/user_permission_remove.sql
\i core/functions/security/permissions/user_context_overrides_load.sql

-- Permission Template Functions
\i core/functions/security/permissions/permission_template_create.sql
\i core/functions/security/permissions/permission_template_update.sql
\i core/functions/security/permissions/permission_template_delete.sql
\i core/functions/security/permissions/permission_template_get.sql
\i core/functions/security/permissions/permission_template_list.sql
\i core/functions/security/permissions/permission_template_item_set.sql
\i core/functions/security/permissions/permission_template_assign.sql
\i core/functions/security/permissions/permission_template_unassign.sql
\i core/functions/security/permissions/permission_template_clone.sql
\i core/functions/security/permissions/permission_template_from_user.sql
\i core/functions/security/permissions/permission_template_assignment_list.sql
\i core/functions/security/permissions/permission_template_cleanup_expired.sql

-- Role Functions
\i core/functions/security/roles/is_system_role.sql
\i core/functions/security/roles/role_list.sql
\i core/functions/security/roles/role_get.sql
\i core/functions/security/roles/role_create.sql
\i core/functions/security/roles/role_update.sql

\i core/functions/security/roles/role_permission_list.sql
\i core/functions/security/roles/role_permission_assign.sql
\i core/functions/security/roles/role_permission_remove.sql
\i core/functions/security/roles/role_permission_bulk_assign.sql
\i core/functions/security/roles/user_role_list.sql
\i core/functions/security/roles/user_role_assign.sql
\i core/functions/security/roles/user_role_remove.sql

-- Auth Functions
\i core/functions/security/auth/user_authenticate.sql
\i core/functions/security/auth/auth_token_save.sql
\i core/functions/security/auth/auth_token_get.sql
\i core/functions/security/auth/auth_token_delete.sql
\i core/functions/security/auth/auth_token_revoke.sql
\i core/functions/security/auth/auth_token_is_revoked.sql
\i core/functions/security/auth/auth_user_tokens_list.sql
\i core/functions/security/auth/auth_token_cleanup.sql

-- Password Policy Functions
\i core/functions/security/policy/company_password_policy_get.sql
\i core/functions/security/policy/company_password_policy_upsert.sql
\i core/functions/security/policy/company_password_policy_list.sql
\i core/functions/security/policy/company_password_policy_reset.sql

-- Presentation Functions (Backoffice)
-- Menu Groups
\i core/functions/presentation/backoffice/menu_groups/menu_group_list.sql
\i core/functions/presentation/backoffice/menu_groups/menu_group_get.sql
\i core/functions/presentation/backoffice/menu_groups/menu_group_create.sql
\i core/functions/presentation/backoffice/menu_groups/menu_group_update.sql
\i core/functions/presentation/backoffice/menu_groups/menu_group_delete.sql

-- Menus
\i core/functions/presentation/backoffice/menus/menu_list.sql
\i core/functions/presentation/backoffice/menus/menu_get.sql
\i core/functions/presentation/backoffice/menus/menu_create.sql
\i core/functions/presentation/backoffice/menus/menu_update.sql
\i core/functions/presentation/backoffice/menus/menu_delete.sql

-- Submenus
\i core/functions/presentation/backoffice/submenus/submenu_list.sql
\i core/functions/presentation/backoffice/submenus/submenu_create.sql
\i core/functions/presentation/backoffice/submenus/submenu_update.sql
\i core/functions/presentation/backoffice/submenus/submenu_delete.sql

-- Pages
\i core/functions/presentation/backoffice/pages/page_list.sql
\i core/functions/presentation/backoffice/pages/page_get.sql
\i core/functions/presentation/backoffice/pages/page_create.sql
\i core/functions/presentation/backoffice/pages/page_update.sql
\i core/functions/presentation/backoffice/pages/page_delete.sql

-- Tabs
\i core/functions/presentation/backoffice/tabs/tab_list.sql
\i core/functions/presentation/backoffice/tabs/tab_create.sql
\i core/functions/presentation/backoffice/tabs/tab_update.sql
\i core/functions/presentation/backoffice/tabs/tab_delete.sql

-- Contexts
\i core/functions/presentation/backoffice/contexts/context_list.sql
\i core/functions/presentation/backoffice/contexts/context_create.sql
\i core/functions/presentation/backoffice/contexts/context_update.sql
\i core/functions/presentation/backoffice/contexts/context_delete.sql

\i core/functions/presentation/backoffice/pages/build_page_json.sql
\i core/functions/presentation/backoffice/structure/menu_structure.sql

-- Presentation Functions (Frontend)
-- Management (Platform Admin + CompanyAdmin + ClientAdmin with IDOR)
-- Client Navigation
\i core/functions/presentation/frontend/management/client_navigation/client_navigation_init_from_template.sql
\i core/functions/presentation/frontend/management/client_navigation/client_navigation_list.sql
\i core/functions/presentation/frontend/management/client_navigation/client_navigation_get.sql
\i core/functions/presentation/frontend/management/client_navigation/client_navigation_create.sql
\i core/functions/presentation/frontend/management/client_navigation/client_navigation_update.sql
\i core/functions/presentation/frontend/management/client_navigation/client_navigation_delete.sql
\i core/functions/presentation/frontend/management/client_navigation/client_navigation_reorder.sql

-- Client Themes
\i core/functions/presentation/frontend/management/client_themes/client_theme_list.sql
\i core/functions/presentation/frontend/management/client_themes/client_theme_get.sql
\i core/functions/presentation/frontend/management/client_themes/client_theme_upsert.sql
\i core/functions/presentation/frontend/management/client_themes/client_theme_activate.sql

-- Client Layouts
\i core/functions/presentation/frontend/management/client_layouts/client_layout_list.sql
\i core/functions/presentation/frontend/management/client_layouts/client_layout_get.sql
\i core/functions/presentation/frontend/management/client_layouts/client_layout_upsert.sql
\i core/functions/presentation/frontend/management/client_layouts/client_layout_delete.sql

-- Consumer (Frontend App - Read Only)
\i core/functions/presentation/frontend/consumer/get_navigation.sql
\i core/functions/presentation/frontend/consumer/get_active_theme.sql
\i core/functions/presentation/frontend/consumer/get_layout.sql

-- Outbox Functions
\i core/functions/outbox/outbox_create.sql
\i core/functions/outbox/outbox_create_batch.sql
\i core/functions/outbox/outbox_get_pending.sql
\i core/functions/outbox/outbox_mark_completed.sql
\i core/functions/outbox/outbox_mark_completed_batch.sql
\i core/functions/outbox/outbox_mark_failed.sql
\i core/functions/outbox/outbox_mark_failed_batch.sql
\i core/functions/outbox/outbox_stats.sql
\i core/functions/outbox/outbox_cleanup.sql

-- Messaging Functions - Admin (Draft Yönetimi)
\i core/functions/messaging/draft/admin_message_draft_create.sql
\i core/functions/messaging/draft/admin_message_draft_update.sql
\i core/functions/messaging/draft/admin_message_draft_get.sql
\i core/functions/messaging/draft/admin_message_draft_list.sql
\i core/functions/messaging/draft/admin_message_draft_list_due_scheduled.sql
\i core/functions/messaging/draft/admin_message_draft_delete.sql
\i core/functions/messaging/draft/admin_message_draft_cancel.sql
\i core/functions/messaging/draft/admin_message_draft_unschedule.sql
-- Messaging Functions - Admin (Publish, Recall, Send)
\i core/functions/messaging/publish/admin_message_publish.sql
\i core/functions/messaging/publish/admin_message_recall.sql
\i core/functions/messaging/publish/admin_message_send.sql
\i core/functions/messaging/publish/get_published_recipients.sql
-- Messaging Functions - User (Inbox)
\i core/functions/messaging/inbox/user_message_list.sql
\i core/functions/messaging/inbox/user_message_read.sql
\i core/functions/messaging/inbox/user_message_read_all.sql
\i core/functions/messaging/inbox/user_message_delete.sql
\i core/functions/messaging/inbox/user_message_get_by_ids.sql
\i core/functions/messaging/inbox/user_message_unread_count.sql
\i core/functions/messaging/inbox/user_message_cleanup_expired.sql
-- Messaging Functions - Message Templates
\i core/functions/messaging/message_template/admin_message_template_create.sql
\i core/functions/messaging/message_template/admin_message_template_update.sql
\i core/functions/messaging/message_template/admin_message_template_get.sql
\i core/functions/messaging/message_template/admin_message_template_list.sql
\i core/functions/messaging/message_template/admin_message_template_delete.sql
\i core/functions/messaging/message_template/message_template_get_by_code.sql

-- Maintenance Functions (Partition Yönetimi)
\i core/functions/maintenance/create_partitions.sql
\i core/functions/maintenance/drop_expired_partitions.sql
\i core/functions/maintenance/partition_info.sql
\i core/functions/maintenance/run_maintenance.sql

-- TRIGGERS
\i core/triggers/update_updated_at_column.sql
\i core/triggers/security_triggers.sql
\i core/triggers/presentation_triggers.sql

-- CONSTRAINTS (FK constraints - en sonda yükle)
\i core/constraints/catalog.sql
\i core/constraints/core.sql
\i core/constraints/presentation.sql
\i core/constraints/routing.sql
\i core/constraints/security.sql
\i core/constraints/billing.sql
\i core/constraints/outbox.sql
\i core/constraints/messaging.sql
\i core/constraints/messaging_notification_template.sql

-- INDEXES (Performans indexleri - en sonda yükle)
\i core/indexes/catalog.sql
\i core/indexes/core.sql
\i core/indexes/presentation.sql
\i core/indexes/routing.sql
\i core/indexes/security.sql
\i core/indexes/billing.sql
\i core/indexes/outbox.sql
\i core/indexes/messaging.sql
\i core/indexes/messaging_notification_template.sql

-- =============================================================================
-- LOG TABLES (eski core_log DB — daily partitioned)
-- =============================================================================
\i core/tables/backoffice_log/audit_logs.sql
\i core/tables/logs/error_logs.sql
\i core/tables/logs/dead_letter_messages.sql
\i core/tables/logs/dead_letter_audit.sql
\i core/tables/logs/audit_logs.sql

-- =============================================================================
-- AUDIT TABLES (eski core_audit DB — daily partitioned)
-- =============================================================================
\i core/tables/backoffice_audit/auth_audit_log.sql

-- =============================================================================
-- REPORT TABLES (eski core_report DB — monthly partitioned)
-- =============================================================================
\i core/tables/finance_report/client_daily_kpi.sql
\i core/tables/billing_report/monthly_invoices.sql
\i core/tables/performance/provider_global_daily.sql
\i core/tables/performance/payment_global_daily.sql
\i core/tables/performance/client_traffic_hourly.sql

-- =============================================================================
-- FUNCTIONS — Log (eski core_log DB)
-- =============================================================================
\i core/functions/backoffice_log/audit_create.sql
\i core/functions/backoffice_log/audit_list.sql
\i core/functions/backoffice_log/audit_get.sql
\i core/functions/logs/error_log.sql
\i core/functions/logs/error_list.sql
\i core/functions/logs/error_get.sql
\i core/functions/logs/error_stats.sql
\i core/functions/logs/dead_letter_create.sql
\i core/functions/logs/dead_letter_get.sql
\i core/functions/logs/dead_letter_update_status.sql
\i core/functions/logs/dead_letter_list.sql
\i core/functions/logs/dead_letter_bulk_retry.sql
\i core/functions/logs/dead_letter_bulk_resolve.sql
\i core/functions/logs/dead_letter_bulk_ignore.sql
\i core/functions/logs/dead_letter_archive.sql
\i core/functions/logs/dead_letter_purge.sql
\i core/functions/logs/dead_letter_stats_detailed.sql
\i core/functions/logs/dead_letter_get_for_auto_retry.sql
\i core/functions/logs/dead_letter_schedule_retry.sql
\i core/functions/logs/core_audit_create.sql
\i core/functions/logs/core_audit_list.sql

-- =============================================================================
-- FUNCTIONS — Audit (eski core_audit DB)
-- =============================================================================
\i core/functions/backoffice_audit/auth_audit_create.sql
\i core/functions/backoffice_audit/auth_audit_list_by_user.sql
\i core/functions/backoffice_audit/auth_audit_list_by_type.sql
\i core/functions/backoffice_audit/auth_audit_failed_logins.sql

-- =============================================================================
-- CONSTRAINTS — Log / Audit / Report
-- =============================================================================
\i core/constraints/logs.sql
\i core/constraints/finance_report.sql
\i core/constraints/billing_report.sql
\i core/constraints/performance.sql

-- =============================================================================
-- INDEXES — Log / Audit / Report
-- =============================================================================
\i core/indexes/backoffice_log.sql
\i core/indexes/logs.sql
\i core/indexes/backoffice_audit.sql
\i core/indexes/finance_report.sql
\i core/indexes/billing_report.sql
\i core/indexes/performance.sql

-- PARTITION INITIALIZATION
SELECT * FROM maintenance.create_partitions();

COMMIT;
