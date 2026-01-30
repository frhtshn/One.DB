SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS finance;
COMMENT ON SCHEMA finance IS 'Aggregated financial stats per tenant/company';

CREATE SCHEMA IF NOT EXISTS billing;
COMMENT ON SCHEMA billing IS 'Invoicing and commission data';

CREATE SCHEMA IF NOT EXISTS performance;
COMMENT ON SCHEMA performance IS 'Global system performance stats';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

-- DROP UNUSED SCHEMAS (Clean start)
DROP SCHEMA IF EXISTS public CASCADE;

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;
-- Needed for fast aggregations if we add rollup tables later
CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA infra;

-- FINANCE TABLES
\i core_report/tables/finance/tenant_daily_kpi.sql

-- BILLING TABLES
\i core_report/tables/billing/monthly_invoices.sql

-- PERFORMANCE TABLES
\i core_report/tables/performance/provider_global_daily.sql
\i core_report/tables/performance/payment_global_daily.sql
\i core_report/tables/performance/tenant_traffic_hourly.sql

-- CONSTRAINTS
\i core_report/constraints/finance.sql
\i core_report/constraints/billing.sql
\i core_report/constraints/performance.sql

-- INDEXES
\i core_report/indexes/finance.sql
\i core_report/indexes/billing.sql
\i core_report/indexes/performance.sql

COMMIT;
