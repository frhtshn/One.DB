SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS game;
COMMENT ON SCHEMA game IS 'Game gateway integration - provider and game catalog';

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
CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA infra;

-- =============================================================================
-- TABLES
-- Oyun sağlayıcı ve oyun kataloğu
-- =============================================================================
\i game/tables/catalog/game_providers.sql
\i game/tables/catalog/games.sql
\i game/tables/catalog/game_currency_limits.sql

-- =============================================================================
-- FUNCTIONS
-- =============================================================================
\i game/functions/catalog/game_provider_sync.sql
\i game/functions/catalog/game_upsert.sql
\i game/functions/catalog/game_bulk_upsert.sql
\i game/functions/catalog/game_update.sql
\i game/functions/catalog/game_get.sql
\i game/functions/catalog/game_list.sql
\i game/functions/catalog/game_lookup.sql
\i game/functions/catalog/game_currency_limit_sync.sql

-- =============================================================================
-- CONSTRAINTS (FK constraints - en sonda yükle)
-- =============================================================================
\i game/constraints/catalog.sql

-- =============================================================================
-- INDEXES (Performans indexleri - en sonda yükle)
-- =============================================================================
\i game/indexes/catalog.sql

COMMIT;
