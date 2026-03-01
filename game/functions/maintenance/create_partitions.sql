-- ================================================================
-- CREATE_PARTITIONS: Daily partition'ları otomatik oluşturur
-- Game veritabanı: game_log schema'sı için
-- Bugün + N gün ileri partition oluşturur
-- Idempotent: Zaten varsa atlar
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.create_partitions(INT);

CREATE OR REPLACE FUNCTION maintenance.create_partitions(
    p_look_ahead_days INT DEFAULT 7  -- Kaç gün ileriye partition oluşturulsun
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
    v_day_start DATE;
    v_day_end DATE;
    v_partition_name TEXT;
    v_exists BOOLEAN;
    v_tbl RECORD;
BEGIN
    FOR v_tbl IN
        SELECT * FROM (VALUES
            ('game_log', 'provider_api_requests', 'created_at'),
            ('game_log', 'provider_api_callbacks', 'created_at')
        ) AS t(schema_name, tbl_name, partition_key)
    LOOP
        FOR i IN 0..p_look_ahead_days LOOP
            v_day_start := CURRENT_DATE + i;
            v_day_end := v_day_start + INTERVAL '1 day';

            v_partition_name := v_tbl.schema_name || '.' || v_tbl.tbl_name
                || '_y' || to_char(v_day_start, 'YYYY')
                || 'm' || to_char(v_day_start, 'MM')
                || 'd' || to_char(v_day_start, 'DD');

            SELECT EXISTS (
                SELECT 1 FROM pg_class c
                JOIN pg_namespace n ON n.oid = c.relnamespace
                WHERE n.nspname = v_tbl.schema_name
                  AND c.relname = v_tbl.tbl_name
                    || '_y' || to_char(v_day_start, 'YYYY')
                    || 'm' || to_char(v_day_start, 'MM')
                    || 'd' || to_char(v_day_start, 'DD')
            ) INTO v_exists;

            IF NOT v_exists THEN
                EXECUTE format(
                    'CREATE TABLE %s PARTITION OF %I.%I FOR VALUES FROM (%L) TO (%L)',
                    v_partition_name,
                    v_tbl.schema_name,
                    v_tbl.tbl_name,
                    v_day_start::TEXT,
                    v_day_end::TEXT
                );
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_day_start::TEXT;
                range_end := v_day_end::TEXT;
                action := 'CREATED';
                RETURN NEXT;
            ELSE
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_day_start::TEXT;
                range_end := v_day_end::TEXT;
                action := 'EXISTS';
                RETURN NEXT;
            END IF;
        END LOOP;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION maintenance.create_partitions(INT) IS 'Creates daily partitions for game_log tables (provider_api_requests, provider_api_callbacks). Look-ahead: today + N days. Idempotent.';
