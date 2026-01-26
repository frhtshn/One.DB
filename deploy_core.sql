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
\i core/tables/security/secrets_provider.sql
\i core/tables/security/secrets_tenant.sql
\i core/tables/security/tenant_roles.sql
\i core/tables/security/role_permissions.sql
\i core/tables/security/users.sql
\i core/tables/security/user_roles.sql

-- BILLING TABLES
\i core/tables/billing/billing_periods.sql
\i core/tables/billing/provider_commission_rates.sql
\i core/tables/billing/provider_commission_tiers.sql
\i core/tables/billing/tenant_commission_plans.sql
\i core/tables/billing/tenant_commission_tiers.sql
\i core/tables/billing/tenant_commission_aggregates.sql
\i core/tables/billing/tenant_commissions.sql
\i core/tables/billing/invoices.sql
\i core/tables/billing/invoice_items.sql
\i core/tables/billing/invoice_payments.sql

-- DATA SEEDING
\i core/data/companies.sql
\i core/data/countries.sql
\i core/data/currencies.sql
\i core/data/languages.sql
\i core/data/transaction_types.sql
\i core/data/operation_types.sql
\i core/data/bo_ui.sql

-- FUNCTIONS
-- \i core/functions/your_function.sql

COMMIT;
