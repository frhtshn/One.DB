-- ================================================================
-- CREATE_PARTITIONS: Birleşik partition oluşturma
-- Core veritabanı: Monthly + Daily partition yönetimi
-- Tüm schema'lar: messaging, security, logs, backoffice_log,
--   backoffice_audit, performance, finance_report, billing_report
-- Idempotent: Zaten varsa atlar
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.create_partitions(INT);
DROP FUNCTION IF EXISTS maintenance.create_partitions(INT, INT);

CREATE OR REPLACE FUNCTION maintenance.create_partitions(
    p_look_ahead_months INT DEFAULT 3,  -- Monthly tablolar için kaç ay ileri
    p_look_ahead_days INT DEFAULT 7     -- Daily tablolar için kaç gün ileri
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
    v_day_start DATE;
    v_day_end DATE;
    v_partition_name TEXT;
    v_exists BOOLEAN;
    v_tbl RECORD;
BEGIN
    -- ============================================================
    -- MONTHLY PARTITIONS
    -- ============================================================
    FOR v_tbl IN
        SELECT * FROM (VALUES
            -- Core Business (mevcut)
            ('messaging', 'user_messages', 'created_at'),
            ('security', 'user_sessions', 'created_at'),
            -- Report (eski core_report)
            ('performance', 'client_traffic_hourly', 'period_hour'),
            ('performance', 'provider_global_daily', 'report_date'),
            ('performance', 'payment_global_daily', 'report_date'),
            ('finance_report', 'client_daily_kpi', 'report_date'),
            ('billing_report', 'monthly_invoices', 'created_at')
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

    -- ============================================================
    -- DAILY PARTITIONS
    -- ============================================================
    FOR v_tbl IN
        SELECT * FROM (VALUES
            -- Log (eski core_log)
            ('logs', 'error_logs', 'occurred_at'),
            ('logs', 'audit_logs', 'created_at'),
            ('logs', 'dead_letter_messages', 'created_at'),
            ('backoffice_log', 'audit_logs', 'created_at'),
            -- Audit (eski core_audit)
            ('backoffice_audit', 'auth_audit_log', 'created_at')
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

COMMENT ON FUNCTION maintenance.create_partitions(INT, INT) IS 'Creates monthly and daily partitions for all core DB tables. Monthly: messaging, security, performance, finance_report, billing_report. Daily: logs, backoffice_log, backoffice_audit. Idempotent.';
