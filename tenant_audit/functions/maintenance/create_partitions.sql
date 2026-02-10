-- ================================================================
-- CREATE_PARTITIONS: Partition'ları otomatik oluşturur
-- tenant_audit veritabanı için hibrit partition yönetimi
-- login_attempts: günlük partition (bugün + 7 gün)
-- login_sessions: aylık partition (bu ay + 3 ay)
-- Idempotent: Zaten varsa atlar
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.create_partitions(INT, INT);

CREATE OR REPLACE FUNCTION maintenance.create_partitions(
    p_look_ahead_days INT DEFAULT 7,     -- Günlük tablolar için kaç gün ileri
    p_look_ahead_months INT DEFAULT 3    -- Aylık tablolar için kaç ay ileri
)
RETURNS TABLE (
    table_name TEXT,
    partition_name TEXT,
    range_start TEXT,
    range_end TEXT,
    action TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_day DATE;
    v_month_start DATE;
    v_month_end DATE;
    v_partition_name TEXT;
    v_start TEXT;
    v_end TEXT;
    v_exists BOOLEAN;
    v_tbl RECORD;
BEGIN
    -- ===== DAILY partition tabloları =====
    FOR v_tbl IN
        SELECT * FROM (VALUES
            ('player_audit', 'login_attempts', 'attempted_at')
        ) AS t(schema_name, tbl_name, partition_key)
    LOOP
        FOR i IN 0..p_look_ahead_days LOOP
            v_day := CURRENT_DATE + i;
            v_partition_name := v_tbl.schema_name || '.' || v_tbl.tbl_name
                || '_y' || to_char(v_day, 'YYYY')
                || 'm' || to_char(v_day, 'MM')
                || 'd' || to_char(v_day, 'DD');

            v_start := v_day::TEXT;
            v_end := (v_day + INTERVAL '1 day')::DATE::TEXT;

            -- Partition zaten var mı kontrol et
            SELECT EXISTS (
                SELECT 1 FROM pg_class c
                JOIN pg_namespace n ON n.oid = c.relnamespace
                WHERE n.nspname = v_tbl.schema_name
                  AND c.relname = v_tbl.tbl_name
                    || '_y' || to_char(v_day, 'YYYY')
                    || 'm' || to_char(v_day, 'MM')
                    || 'd' || to_char(v_day, 'DD')
            ) INTO v_exists;

            IF NOT v_exists THEN
                EXECUTE format(
                    'CREATE TABLE %s PARTITION OF %I.%I FOR VALUES FROM (%L) TO (%L)',
                    v_partition_name,
                    v_tbl.schema_name,
                    v_tbl.tbl_name,
                    v_start,
                    v_end
                );
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_start;
                range_end := v_end;
                action := 'CREATED';
                RETURN NEXT;
            ELSE
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_start;
                range_end := v_end;
                action := 'EXISTS';
                RETURN NEXT;
            END IF;
        END LOOP;
    END LOOP;

    -- ===== MONTHLY partition tabloları =====
    FOR v_tbl IN
        SELECT * FROM (VALUES
            ('player_audit', 'login_sessions', 'created_at')
        ) AS t(schema_name, tbl_name, partition_key)
    LOOP
        FOR i IN 0..p_look_ahead_months LOOP
            v_month_start := date_trunc('month', CURRENT_DATE)::DATE + (i || ' months')::INTERVAL;
            v_month_end := v_month_start + INTERVAL '1 month';

            v_partition_name := v_tbl.schema_name || '.' || v_tbl.tbl_name
                || '_y' || to_char(v_month_start, 'YYYY')
                || 'm' || to_char(v_month_start, 'MM');

            SELECT EXISTS (
                SELECT 1 FROM pg_class c
                JOIN pg_namespace n ON n.oid = c.relnamespace
                WHERE n.nspname = v_tbl.schema_name
                  AND c.relname = v_tbl.tbl_name
                    || '_y' || to_char(v_month_start, 'YYYY')
                    || 'm' || to_char(v_month_start, 'MM')
            ) INTO v_exists;

            IF NOT v_exists THEN
                EXECUTE format(
                    'CREATE TABLE %s PARTITION OF %I.%I FOR VALUES FROM (%L) TO (%L)',
                    v_partition_name,
                    v_tbl.schema_name,
                    v_tbl.tbl_name,
                    v_month_start::TEXT,
                    v_month_end::TEXT
                );
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_month_start::TEXT;
                range_end := v_month_end::TEXT;
                action := 'CREATED';
                RETURN NEXT;
            ELSE
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_month_start::TEXT;
                range_end := v_month_end::TEXT;
                action := 'EXISTS';
                RETURN NEXT;
            END IF;
        END LOOP;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION maintenance.create_partitions(INT, INT) IS 'Creates partitions for tenant_audit tables. Daily: login_attempts (look-ahead days). Monthly: login_sessions (look-ahead months). Idempotent.';
