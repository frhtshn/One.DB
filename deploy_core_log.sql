SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS backoffice;
CREATE SCHEMA IF NOT EXISTS logs;
CREATE SCHEMA IF NOT EXISTS infra;

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;

-- TABLES
\i core_log/tables/backoffice/audit_logs.sql
\i core_log/tables/logs/error_logs.sql
\i core_log/tables/logs/dead_letter_messages.sql
\i core_log/tables/logs/audit_logs.sql

COMMIT;
