-- ================================================================
-- CREATE_PARTITIONS: Gunluk partition'lari otomatik olusturur
-- tenant_log veritabani icin daily partition yonetimi
-- Bugun + 7 gun ileri partition olusturur
-- Idempotent: Zaten varsa atlar
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.create_partitions();

CREATE OR REPLACE FUNCTION maintenance.create_partitions(
    p_look_ahead_days INT DEFAULT 7  -- Kac gun ileriye partition olusturulsun
)
RETURNS TABLE (
    table_name TEXT,
    partition_name TEXT,
    range_start DATE,
    range_end DATE,
    action TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_day DATE;
    v_partition_name TEXT;
    v_start TEXT;
    v_end TEXT;
    v_exists BOOLEAN;
    v_tbl RECORD;
BEGIN
    -- Partition olusturulacak tablolar ve partition key'leri
    FOR v_tbl IN
        SELECT * FROM (VALUES
            ('affiliate_log', 'api_requests',             'created_at'),
            ('affiliate_log', 'commission_calculations',  'created_at'),
            ('affiliate_log', 'report_generations',       'created_at'),
            ('kyc_log',       'player_kyc_provider_logs', 'created_at')
        ) AS t(schema_name, tbl_name, partition_key)
    LOOP
        -- Bugunden itibaren look_ahead_days kadar ileri
        FOR i IN 0..p_look_ahead_days LOOP
            v_day := CURRENT_DATE + i;
            v_partition_name := v_tbl.schema_name || '.' || v_tbl.tbl_name
                || '_y' || to_char(v_day, 'YYYY')
                || 'm' || to_char(v_day, 'MM')
                || 'd' || to_char(v_day, 'DD');

            v_start := v_day::TEXT;
            v_end := (v_day + INTERVAL '1 day')::DATE::TEXT;

            -- Partition zaten var mi kontrol et
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
                range_start := v_day;
                range_end := v_day + 1;
                action := 'CREATED';
                RETURN NEXT;
            ELSE
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_day;
                range_end := v_day + 1;
                action := 'EXISTS';
                RETURN NEXT;
            END IF;
        END LOOP;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION maintenance.create_partitions(INT) IS 'Creates daily partitions for tenant_log tables. Look-ahead: today + N days. Idempotent.';
