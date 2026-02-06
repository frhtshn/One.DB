-- ================================================================
-- CREATE_PARTITIONS: Aylık partition'ları otomatik oluşturur
-- Mevcut ay + ileriye dönük belirtilen ay sayısı kadar partition
-- oluşturur. Zaten varsa atlar (IF NOT EXISTS).
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.create_partitions(INT);

CREATE OR REPLACE FUNCTION maintenance.create_partitions(
    p_look_ahead_months INT DEFAULT 3    -- Kaç ay ileriye partition oluşturulsun
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_table RECORD;
    v_start_date DATE;
    v_end_date DATE;
    v_partition_name TEXT;
    v_sql TEXT;
    v_created_count INT := 0;
    v_skipped_count INT := 0;
    v_details JSONB := '[]'::JSONB;
BEGIN
    -- Partition oluşturulacak tablo listesi
    FOR v_table IN
        SELECT *
        FROM (VALUES
            ('performance', 'tenant_traffic_hourly', 'period_hour'),
            ('performance', 'provider_global_daily', 'report_date'),
            ('performance', 'payment_global_daily', 'report_date'),
            ('finance', 'tenant_daily_kpi', 'report_date'),
            ('billing', 'monthly_invoices', 'created_at')
        ) AS t(schema_name, table_name, partition_column)
    LOOP
        -- Mevcut aydan başlayarak ileriye doğru partition oluştur
        FOR i IN 0..p_look_ahead_months LOOP
            v_start_date := DATE_TRUNC('month', CURRENT_DATE) + (i || ' months')::INTERVAL;
            v_end_date := v_start_date + '1 month'::INTERVAL;

            -- Partition adı: {tablo}_y{YYYY}m{MM}
            v_partition_name := v_table.table_name || '_y' || TO_CHAR(v_start_date, 'YYYY') || 'm' || TO_CHAR(v_start_date, 'MM');

            -- Partition zaten var mı kontrol et
            IF NOT EXISTS (
                SELECT 1
                FROM pg_catalog.pg_class c
                JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
                WHERE n.nspname = v_table.schema_name
                  AND c.relname = v_partition_name
            ) THEN
                -- Yeni partition oluştur
                v_sql := FORMAT(
                    'CREATE TABLE %I.%I PARTITION OF %I.%I FOR VALUES FROM (%L) TO (%L)',
                    v_table.schema_name,
                    v_partition_name,
                    v_table.schema_name,
                    v_table.table_name,
                    v_start_date,
                    v_end_date
                );

                EXECUTE v_sql;
                v_created_count := v_created_count + 1;

                v_details := v_details || jsonb_build_object(
                    'action', 'created',
                    'partition', v_table.schema_name || '.' || v_partition_name,
                    'range_from', v_start_date,
                    'range_to', v_end_date
                );
            ELSE
                v_skipped_count := v_skipped_count + 1;
            END IF;
        END LOOP;
    END LOOP;

    RETURN jsonb_build_object(
        'created_count', v_created_count,
        'skipped_count', v_skipped_count,
        'look_ahead_months', p_look_ahead_months,
        'details', v_details,
        'executed_at', NOW()
    );
END;
$$;

COMMENT ON FUNCTION maintenance.create_partitions IS 'Creates monthly partitions for all report tables. Generates current month plus look-ahead months. Skips already existing partitions. Returns JSONB with creation details.';
