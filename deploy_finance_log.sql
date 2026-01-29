SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS finance_log;
COMMENT ON SCHEMA finance_log IS 'Finance activity logs';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;

-- TABLES
-- \i finance_log/tables/...

-- FUNCTIONS
-- \i finance_log/functions/...

-- INDEXES
-- \i finance_log/indexes/...

COMMIT;
