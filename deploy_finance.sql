SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS finance;
COMMENT ON SCHEMA finance IS 'Finance gateway integration';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

-- DROP UNUSED SCHEMAS
DROP SCHEMA IF EXISTS metric_helpers CASCADE;
DROP SCHEMA IF EXISTS user_management CASCADE;
DROP SCHEMA IF EXISTS public CASCADE;

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA infra;

-- TABLES
-- \i finance/tables/...

-- FUNCTIONS
-- \i finance/functions/...

-- INDEXES
-- \i finance/indexes/...

COMMIT;
