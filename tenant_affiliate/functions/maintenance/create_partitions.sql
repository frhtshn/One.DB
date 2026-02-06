-- ================================================================
-- CREATE_PARTITIONS: Aylık partition'ları otomatik oluşturur
-- tenant_affiliate veritabanı için monthly partition yönetimi
-- Bu ay + 3 ay ileri partition oluşturur
-- Idempotent: Zaten varsa atlar
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.create_partitions(INT);

CREATE OR REPLACE FUNCTION maintenance.create_partitions(
    p_look_ahead_months INT DEFAULT 3  -- Kaç ay ileriye partition oluşturulsun
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
    v_month_start DATE;
    v_month_end DATE;
    v_partition_name TEXT;
    v_exists BOOLEAN;
    v_tbl RECORD;
    v_year INT;
    v_month INT;
BEGIN
    -- ===== DATE-based partition tabloları =====
    FOR v_tbl IN
        SELECT * FROM (VALUES
            ('tracking', 'link_clicks',                'clicked_at'),
            ('tracking', 'transaction_events',         'created_at'),
            ('tracking', 'player_game_stats_daily',    'game_date'),
            ('tracking', 'player_finance_stats_daily', 'stats_date'),
            ('tracking', 'affiliate_stats_daily',      'stats_date')
        ) AS t(schema_name, tbl_name, partition_key)
    LOOP
        FOR i IN 0..p_look_ahead_months LOOP
            v_month_start := date_trunc('month', CURRENT_DATE)::DATE + (i || ' months')::INTERVAL;
            v_month_end := v_month_start + INTERVAL '1 month';

            v_partition_name := v_tbl.schema_name || '.' || v_tbl.tbl_name
                || '_y' || to_char(v_month_start, 'YYYY')
                || 'm' || to_char(v_month_start, 'MM');

            -- Partition zaten var mı kontrol et
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

    -- ===== YEAR/MONTH-based partition tabloları (multi-column range) =====
    FOR v_tbl IN
        SELECT * FROM (VALUES
            ('tracking', 'player_stats_monthly'),
            ('tracking', 'affiliate_stats_monthly')
        ) AS t(schema_name, tbl_name)
    LOOP
        FOR i IN 0..p_look_ahead_months LOOP
            v_month_start := date_trunc('month', CURRENT_DATE)::DATE + (i || ' months')::INTERVAL;
            v_month_end := v_month_start + INTERVAL '1 month';

            v_year := EXTRACT(YEAR FROM v_month_start)::INT;
            v_month := EXTRACT(MONTH FROM v_month_start)::INT;

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
                    'CREATE TABLE %s PARTITION OF %I.%I FOR VALUES FROM (%s, %s) TO (%s, %s)',
                    v_partition_name,
                    v_tbl.schema_name,
                    v_tbl.tbl_name,
                    v_year,
                    v_month,
                    EXTRACT(YEAR FROM v_month_end)::INT,
                    EXTRACT(MONTH FROM v_month_end)::INT
                );
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_year || '-' || lpad(v_month::TEXT, 2, '0');
                range_end := EXTRACT(YEAR FROM v_month_end)::INT || '-' || lpad(EXTRACT(MONTH FROM v_month_end)::INT::TEXT, 2, '0');
                action := 'CREATED';
                RETURN NEXT;
            ELSE
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_year || '-' || lpad(v_month::TEXT, 2, '0');
                range_end := EXTRACT(YEAR FROM v_month_end)::INT || '-' || lpad(EXTRACT(MONTH FROM v_month_end)::INT::TEXT, 2, '0');
                action := 'EXISTS';
                RETURN NEXT;
            END IF;
        END LOOP;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION maintenance.create_partitions(INT) IS 'Creates monthly partitions for tenant_affiliate tracking tables. Look-ahead: current month + N months. Idempotent.';
