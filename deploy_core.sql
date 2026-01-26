SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS catalog;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS presentation;
CREATE SCHEMA IF NOT EXISTS routing;
CREATE SCHEMA IF NOT EXISTS security;
CREATE SCHEMA IF NOT EXISTS billing;
CREATE SCHEMA IF NOT EXISTS infra;

-- DROP UNUSED SCHEMAS
DROP SCHEMA IF EXISTS metric_helpers CASCADE;
DROP SCHEMA IF EXISTS user_management CASCADE;

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA infra;

-- CATALOG TABLES
\i core/tables/catalog/countries.sql
\i core/tables/catalog/currencies.sql
\i core/tables/catalog/games.sql
\i core/tables/catalog/languages.sql
\i core/tables/catalog/localization_keys.sql
\i core/tables/catalog/localization_values.sql
\i core/tables/catalog/operation_types.sql
\i core/tables/catalog/payment_methods.sql
\i core/tables/catalog/provider_settings.sql
\i core/tables/catalog/provider_types.sql
\i core/tables/catalog/providers.sql
\i core/tables/catalog/transaction_types.sql

-- CORE TABLES
\i core/tables/core/companies.sql
\i core/tables/core/tenants.sql
\i core/tables/core/tenant_currencies.sql
\i core/tables/core/tenant_games.sql
\i core/tables/core/tenant_languages.sql
\i core/tables/core/tenant_payment_methods.sql
\i core/tables/core/tenant_providers.sql
\i core/tables/core/tenant_provider_limits.sql
\i core/tables/core/tenant_settings.sql

-- PRESENTATION TABLES
\i core/tables/presentation/contexts.sql
\i core/tables/presentation/menu_groups.sql
\i core/tables/presentation/menus.sql
\i core/tables/presentation/submenus.sql
\i core/tables/presentation/pages.sql
\i core/tables/presentation/tabs.sql

-- ROUTING TABLES
\i core/tables/routing/callback_routes.sql
\i core/tables/routing/provider_callbacks.sql
\i core/tables/routing/provider_endpoints.sql

-- SECURITY TABLES
\i core/tables/security/permissions.sql
\i core/tables/security/roles.sql
\i core/tables/security/role_permissions.sql
\i core/tables/security/secrets_provider.sql
\i core/tables/security/secrets_tenant.sql
\i core/tables/security/users.sql
\i core/tables/security/user_roles.sql
\i core/tables/security/user_tenant_roles.sql
\i core/tables/security/user_sessions.sql
\i core/tables/security/user_permission_overrides.sql
\i core/tables/security/user_allowed_tenants.sql

-- BILLING TABLES (Tenant Faturalama - Nucleo'nun Alacakları)
\i core/tables/billing/tenant/tenant_billing_periods.sql
\i core/tables/billing/tenant/tenant_commission_rates.sql
\i core/tables/billing/tenant/tenant_commission_rate_tiers.sql
\i core/tables/billing/tenant/tenant_commission_plans.sql
\i core/tables/billing/tenant/tenant_commission_plan_tiers.sql
\i core/tables/billing/tenant/tenant_commission_aggregates.sql
\i core/tables/billing/tenant/tenant_commissions.sql
\i core/tables/billing/tenant/tenant_invoices.sql
\i core/tables/billing/tenant/tenant_invoice_items.sql
\i core/tables/billing/tenant/tenant_invoice_payments.sql

-- BILLING TABLES (Provider Ödemeleri - Nucleo'nun Borçları)
\i core/tables/billing/provider/provider_commission_rates.sql
\i core/tables/billing/provider/provider_commission_tiers.sql
\i core/tables/billing/provider/provider_settlements.sql
\i core/tables/billing/provider/provider_settlement_tenants.sql
\i core/tables/billing/provider/provider_invoices.sql
\i core/tables/billing/provider/provider_invoice_items.sql
\i core/tables/billing/provider/provider_payments.sql

-- DATA SEEDING
\i core/data/companies.sql
\i core/data/countries.sql
\i core/data/currencies.sql
\i core/data/languages.sql
\i core/data/transaction_types.sql
\i core/data/operation_types.sql
\i core/data/localization_keys.sql
\i core/data/localization_values_en.sql
\i core/data/localization_values_tr.sql
--\i core/data/bo_ui.sql

-- FUNCTIONS
-- Language Functions
\i core/functions/catalog/languages/language_list_active.sql
\i core/functions/catalog/languages/language_list.sql
\i core/functions/catalog/languages/language_get.sql
\i core/functions/catalog/languages/language_create.sql
\i core/functions/catalog/languages/language_update.sql
\i core/functions/catalog/languages/language_delete.sql

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
-- Session Functions
\i core/functions/security/session/session_list.sql
\i core/functions/security/session/session_save.sql
\i core/functions/security/session/session_revoke.sql
\i core/functions/security/session/session_revoke_all.sql
\i core/functions/security/session/session_cleanup_expired.sql

-- User Functions
\i core/functions/security/users/user_login_failed_increment.sql
\i core/functions/security/users/user_login_failed_reset.sql
\i core/functions/security/users/user_unlock.sql

-- Permission Functions
\i core/functions/security/permissions/permission_exists.sql
\i core/functions/security/permissions/permission_category_list.sql
\i core/functions/security/permissions/permission_list.sql
\i core/functions/security/permissions/permission_get.sql
\i core/functions/security/permissions/permission_create.sql
\i core/functions/security/permissions/permission_update.sql
\i core/functions/security/permissions/permission_delete.sql
\i core/functions/security/permissions/permission_restore.sql
\i core/functions/security/permissions/permission_cleanup_expired.sql
\i core/functions/security/permissions/permission_check.sql
\i core/functions/security/permissions/user_permission_list.sql
\i core/functions/security/permissions/user_permission_override_list.sql
\i core/functions/security/permissions/user_permission_set.sql
\i core/functions/security/permissions/user_permission_remove.sql

-- Role Functions
\i core/functions/security/roles/is_system_role.sql
\i core/functions/security/roles/role_list.sql
\i core/functions/security/roles/role_get.sql
\i core/functions/security/roles/role_create.sql
\i core/functions/security/roles/role_update.sql
\i core/functions/security/roles/role_delete.sql
\i core/functions/security/roles/role_restore.sql
\i core/functions/security/roles/role_permission_list.sql
\i core/functions/security/roles/role_permission_assign.sql
\i core/functions/security/roles/role_permission_remove.sql
\i core/functions/security/roles/role_permission_bulk_assign.sql
\i core/functions/security/roles/user_role_list.sql
\i core/functions/security/roles/user_role_assign.sql
\i core/functions/security/roles/user_role_remove.sql
\i core/functions/security/roles/user_tenant_role_list.sql
\i core/functions/security/roles/user_tenant_role_assign.sql
\i core/functions/security/roles/user_tenant_role_remove.sql

-- Auth Functions
\i core/functions/security/auth/user_authenticate.sql

-- Presentation Functions
\i core/functions/presentation/build_page_json.sql
\i core/functions/presentation/get_structure.sql

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

-- INDEXES (Performans indexleri - en sonda yükle)
\i core/indexes/catalog.sql
\i core/indexes/core.sql
\i core/indexes/presentation.sql
\i core/indexes/routing.sql
\i core/indexes/security.sql
\i core/indexes/billing.sql

COMMIT;
