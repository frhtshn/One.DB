-- =============================================
-- Read-only kullanıcı oluşturma (Claude MCP için)
-- =============================================
-- Bu script'i psql ile her veritabanında ayrı ayrı çalıştırın.
-- Önce herhangi bir DB'de Step 1'i çalıştırın (role cluster-wide'dır).
-- Sonra HER veritabanına bağlanıp Step 2'yi çalıştırın.

-- =============================================
-- STEP 1: Role oluştur (sadece 1 kez, herhangi bir DB'de)
-- =============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'claude_readonly') THEN
        CREATE ROLE claude_readonly WITH LOGIN PASSWORD 'ClaudeReadOnly2026!';
    END IF;
END $$;

-- =============================================
-- STEP 2: Her veritabanında ayrı ayrı çalıştır
-- =============================================

-- Veritabanına bağlanma izni
GRANT CONNECT ON DATABASE CURRENT_DATABASE TO claude_readonly;

-- Tüm mevcut schemalara USAGE izni
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT schema_name
        FROM information_schema.schemata
        WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
    LOOP
        EXECUTE format('GRANT USAGE ON SCHEMA %I TO claude_readonly', r.schema_name);
        EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA %I TO claude_readonly', r.schema_name);
        EXECUTE format('GRANT SELECT ON ALL SEQUENCES IN SCHEMA %I TO claude_readonly', r.schema_name);
        -- Gelecekte oluşturulacak tablolar için de SELECT izni
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT SELECT ON TABLES TO claude_readonly', r.schema_name);
    END LOOP;
END $$;
