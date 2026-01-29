SET client_encoding = 'UTF8';

BEGIN;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS bonus;
COMMENT ON SCHEMA bonus IS 'Bonus definitions and rules';

CREATE SCHEMA IF NOT EXISTS promotion;
COMMENT ON SCHEMA promotion IS 'Promotion configurations';

CREATE SCHEMA IF NOT EXISTS campaign;
COMMENT ON SCHEMA campaign IS 'Campaign management';

CREATE SCHEMA IF NOT EXISTS infra;
COMMENT ON SCHEMA infra IS 'PostgreSQL extensions and infrastructure';

-- ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA infra;
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA infra;

-- BONUS TABLES
\i bonus/tables/bonus/bonus_types.sql
\i bonus/tables/bonus/bonus_rules.sql
\i bonus/tables/bonus/bonus_triggers.sql

-- PROMOTION TABLES
\i bonus/tables/promotion/promo_codes.sql

-- CAMPAIGN TABLES
\i bonus/tables/campaign/campaigns.sql

-- CONSTRAINTS (FK constraints - en sonda yükle)
\i bonus/constraints/bonus.sql

-- INDEXES (Performans indexleri - en sonda yükle)
\i bonus/indexes/bonus.sql

COMMIT;
