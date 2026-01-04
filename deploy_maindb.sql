BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS catalog;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS routing;
CREATE SCHEMA IF NOT EXISTS security;

-- CATALOG TABLES
\i db/tables/catalog/countries.sql
\i db/tables/catalog/currencies.sql
\i db/tables/catalog/currency_rates.sql
\i db/tables/catalog/games.sql
\i db/tables/catalog/languages.sql
\i db/tables/catalog/localization_keys.sql
\i db/tables/catalog/localization_values.sql
\i db/tables/catalog/operation_types.sql
\i db/tables/catalog/provider_settings.sql
\i db/tables/catalog/provider_types.sql
\i db/tables/catalog/providers.sql
\i db/tables/catalog/transaction_types.sql

-- CORE TABLES
\i db/tables/core/companies.sql
\i db/tables/core/tenants.sql
\i db/tables/core/tenant_currencies.sql
\i db/tables/core/tenant_games.sql
\i db/tables/core/tenant_languages.sql
\i db/tables/core/tenant_providers.sql
\i db/tables/core/tenant_settings.sql

-- ROUTING TABLES
\i db/tables/routing/callback_routes.sql
\i db/tables/routing/provider_callbacks.sql
\i db/tables/routing/provider_endpoints.sql

-- SECURITY TABLES
\i db/tables/security/provider_secrets.sql
\i db/tables/security/tenant_secrets.sql

-- FUNCTIONS
-- \i db/functions/your_function.sql

COMMIT;
