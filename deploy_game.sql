SET client_encoding = 'UTF8';
BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS game;
COMMENT ON SCHEMA game IS 'Game gateway integration - provider and game catalog';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

CREATE SCHEMA IF NOT EXISTS catalog;
COMMENT ON SCHEMA catalog IS 'Payment provider and method catalog';

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

-- =============================================================================
-- LOG SCHEMAS (eski game_log DB)
-- =============================================================================
CREATE SCHEMA IF NOT EXISTS game_log;
COMMENT ON SCHEMA game_log IS 'Game provider API call and callback logs (gateway-level, shared)';

CREATE SCHEMA IF NOT EXISTS maintenance;
COMMENT ON SCHEMA maintenance IS 'Partition management and maintenance utilities';

-- =============================================================================
-- GAME LOG TABLES (daily partitioned)
-- =============================================================================
\i game/tables/game_log/provider_api_requests.sql
\i game/tables/game_log/provider_api_callbacks.sql

-- =============================================================================
-- GAME LOG CONSTRAINTS
-- =============================================================================
\i game/constraints/game_log.sql

-- =============================================================================
-- GAME LOG INDEXES
-- =============================================================================
\i game/indexes/game_log.sql

-- =============================================================================
-- FUNCTIONS - MAINTENANCE (Partition yönetimi)
-- =============================================================================
\i game/functions/maintenance/create_partitions.sql
\i game/functions/maintenance/drop_expired_partitions.sql
\i game/functions/maintenance/partition_info.sql
\i game/functions/maintenance/run_maintenance.sql

-- INITIAL PARTITIONS
SELECT * FROM maintenance.create_partitions();

COMMIT;
