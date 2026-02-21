-- =====================================================================
-- Orleans PostgreSQL Deployment Script
-- Orleans 10 resmi ADO.NET provider scriptleri
-- https://github.com/dotnet/orleans/tree/main/src/AdoNet/
-- =====================================================================
-- Kullanim:
--   .\deploy.ps1 deploy_orleans.sql
--   .\deploy.ps1 deploy_orleans.sql -Reset
--
-- Not: "orleans" DB'si create_dbs.sql ile olusturulur.
-- =====================================================================

SET client_encoding = 'UTF8';

-- Reset sonrasi public schema yeniden olustur (Orleans tablolari public schema'da)
CREATE SCHEMA IF NOT EXISTS public;

BEGIN;

\i orleans/PostgreSQL-Main.sql
\i orleans/PostgreSQL-Clustering.sql
\i orleans/PostgreSQL-Persistence.sql
\i orleans/PostgreSQL-Reminders.sql

COMMIT;
