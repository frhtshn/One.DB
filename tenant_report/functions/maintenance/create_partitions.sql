-- ================================================================
-- CREATE_PARTITIONS: Aylik partition'lari otomatik olusturur
-- tenant_report veritabani icin monthly partition yonetimi
-- Bu ay + 3 ay ileri partition olusturur
-- Idempotent: Zaten varsa atlar
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.create_partitions();

CREATE OR REPLACE FUNCTION maintenance.create_partitions(
    p_look_ahead_months INT DEFAULT 3  -- Kac ay ileriye partition olusturulsun
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
    v_month_start DATE;
    v_month_end DATE;
    v_partition_name TEXT;
    v_exists BOOLEAN;
    v_tbl RECORD;
BEGIN
    -- Partition olusturulacak tablolar ve partition key'leri
    FOR v_tbl IN
        SELECT * FROM (VALUES
            ('finance', 'player_hourly_stats',       'period_hour'),
            ('finance', 'transaction_hourly_stats',  'period_hour'),
            ('finance', 'system_hourly_kpi',         'period_hour'),
            ('game',    'game_hourly_stats',         'period_hour'),
            ('game',    'game_performance_daily',    'report_date')
        ) AS t(schema_name, tbl_name, partition_key)
    LOOP
        -- Bu aydan itibaren look_ahead_months kadar ileri
        FOR i IN 0..p_look_ahead_months LOOP
            v_month_start := date_trunc('month', CURRENT_DATE)::DATE + (i || ' months')::INTERVAL;
            v_month_end := v_month_start + INTERVAL '1 month';

            v_partition_name := v_tbl.schema_name || '.' || v_tbl.tbl_name
                || '_y' || to_char(v_month_start, 'YYYY')
                || 'm' || to_char(v_month_start, 'MM');

            -- Partition zaten var mi kontrol et
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
                    v_month_end::DATE::TEXT
                );
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_month_start;
                range_end := v_month_end::DATE;
                action := 'CREATED';
                RETURN NEXT;
            ELSE
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_month_start;
                range_end := v_month_end::DATE;
                action := 'EXISTS';
                RETURN NEXT;
            END IF;
        END LOOP;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION maintenance.create_partitions(INT) IS 'Creates monthly partitions for tenant_report tables. Look-ahead: current month + N months. Idempotent.';
