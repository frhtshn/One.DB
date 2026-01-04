-- CREATE DATABASE
-- Note: This must be run separately if the database doesn't exist
-- CREATE DATABASE core WITH ENCODING 'UTF8';

-- Connect to the core database before running the rest of this script
-- Example: psql -U postgres -d core -f deploy_core.sql

SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS catalog;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS routing;
CREATE SCHEMA IF NOT EXISTS security;

-- CATALOG TABLES
\i core/tables/catalog/countries.sql
\i core/tables/catalog/currencies.sql
\i core/tables/catalog/currency_rates.sql
\i core/tables/catalog/games.sql
\i core/tables/catalog/languages.sql
\i core/tables/catalog/localization_keys.sql
\i core/tables/catalog/localization_values.sql
\i core/tables/catalog/operation_types.sql
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
\i core/tables/core/tenant_providers.sql
\i core/tables/core/tenant_settings.sql

-- ROUTING TABLES
\i core/tables/routing/callback_routes.sql
\i core/tables/routing/provider_callbacks.sql
\i core/tables/routing/provider_endpoints.sql

-- SECURITY TABLES
\i core/tables/security/provider_secrets.sql
\i core/tables/security/tenant_secrets.sql

-- DATA SEEDING
\i core/data/countries.sql
\i core/data/currencies.sql
\i core/data/languages.sql


-- FUNCTIONS
-- \i core/functions/your_function.sql

COMMIT;
