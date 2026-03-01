-- ================================================================
-- CREATE_PARTITIONS: Birleşik partition oluşturma
-- Tüm schema'lar için monthly ve daily partition yönetimi
-- Monthly: Bu ay + 3 ay ileri | Daily: Bugün + 7 gün ileri
-- Idempotent: Zaten varsa atlar
-- ================================================================

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
    v_start DATE;
    v_end DATE;
    v_partition_name TEXT;
    v_exists BOOLEAN;
    v_tbl RECORD;
BEGIN
    -- ============================================================
    -- MONTHLY PARTITIONS
    -- Core business + report + audit sessions + affiliate tracking
    -- ============================================================
    FOR v_tbl IN
        SELECT * FROM (VALUES
            -- Core Business
            ('transaction',     'transactions',             'created_at'),
            ('messaging',       'player_messages',          'created_at'),
            -- Audit (monthly)
            ('player_audit',    'login_sessions',           'created_at'),
            -- Report
            ('finance_report',  'player_hourly_stats',      'period_hour'),
            ('finance_report',  'transaction_hourly_stats',  'period_hour'),
            ('finance_report',  'system_hourly_kpi',         'period_hour'),
            ('game_report',     'game_hourly_stats',         'period_hour'),
            ('game_report',     'game_performance_daily',    'report_date'),
            ('support_report',  'ticket_daily_stats',        'report_date'),
            -- Affiliate Tracking
            ('tracking',        'player_game_stats_daily',   'stat_date'),
            ('tracking',        'player_finance_stats_daily', 'stat_date'),
            ('tracking',        'player_stats_monthly',      'stat_month'),
            ('tracking',        'affiliate_stats_daily',     'stat_date'),
            ('tracking',        'affiliate_stats_monthly',   'stat_month'),
            ('tracking',        'transaction_events',        'created_at')
        ) AS t(schema_name, tbl_name, partition_key)
    LOOP
        FOR i IN 0..p_look_ahead_months LOOP
            v_start := date_trunc('month', CURRENT_DATE)::DATE + (i || ' months')::INTERVAL;
            v_end := v_start + INTERVAL '1 month';

            v_partition_name := v_tbl.schema_name || '.' || v_tbl.tbl_name
                || '_y' || to_char(v_start, 'YYYY')
                || 'm' || to_char(v_start, 'MM');

            SELECT EXISTS (
                SELECT 1 FROM pg_class c
                JOIN pg_namespace n ON n.oid = c.relnamespace
                WHERE n.nspname = v_tbl.schema_name
                  AND c.relname = v_tbl.tbl_name
                    || '_y' || to_char(v_start, 'YYYY')
                    || 'm' || to_char(v_start, 'MM')
            ) INTO v_exists;

            IF NOT v_exists THEN
                EXECUTE format(
                    'CREATE TABLE %s PARTITION OF %I.%I FOR VALUES FROM (%L) TO (%L)',
                    v_partition_name,
                    v_tbl.schema_name,
                    v_tbl.tbl_name,
                    v_start::TEXT,
                    v_end::TEXT
                );
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_start::TEXT;
                range_end := v_end::TEXT;
                action := 'CREATED';
                RETURN NEXT;
            ELSE
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_start::TEXT;
                range_end := v_end::TEXT;
                action := 'EXISTS';
                RETURN NEXT;
            END IF;
        END LOOP;
    END LOOP;

    -- ============================================================
    -- DAILY PARTITIONS
    -- Log tabloları + audit login attempts
    -- ============================================================
    FOR v_tbl IN
        SELECT * FROM (VALUES
            -- Log
            ('affiliate_log',  'api_requests',             'created_at'),
            ('bonus_log',      'bonus_evaluation_logs',    'created_at'),
            ('kyc_log',        'player_kyc_provider_logs', 'created_at'),
            ('messaging_log',  'message_delivery_logs',    'created_at'),
            ('game_log',       'game_rounds',              'created_at'),
            ('support_log',    'ticket_activity_logs',     'created_at'),
            -- Audit (daily)
            ('player_audit',   'login_attempts',           'attempted_at')
        ) AS t(schema_name, tbl_name, partition_key)
    LOOP
        FOR i IN 0..p_look_ahead_days LOOP
            v_start := CURRENT_DATE + i;
            v_end := v_start + INTERVAL '1 day';

            v_partition_name := v_tbl.schema_name || '.' || v_tbl.tbl_name
                || '_y' || to_char(v_start, 'YYYY')
                || 'm' || to_char(v_start, 'MM')
                || 'd' || to_char(v_start, 'DD');

            SELECT EXISTS (
                SELECT 1 FROM pg_class c
                JOIN pg_namespace n ON n.oid = c.relnamespace
                WHERE n.nspname = v_tbl.schema_name
                  AND c.relname = v_tbl.tbl_name
                    || '_y' || to_char(v_start, 'YYYY')
                    || 'm' || to_char(v_start, 'MM')
                    || 'd' || to_char(v_start, 'DD')
            ) INTO v_exists;

            IF NOT v_exists THEN
                EXECUTE format(
                    'CREATE TABLE %s PARTITION OF %I.%I FOR VALUES FROM (%L) TO (%L)',
                    v_partition_name,
                    v_tbl.schema_name,
                    v_tbl.tbl_name,
                    v_start::TEXT,
                    v_end::TEXT
                );
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_start::TEXT;
                range_end := v_end::TEXT;
                action := 'CREATED';
                RETURN NEXT;
            ELSE
                table_name := v_tbl.schema_name || '.' || v_tbl.tbl_name;
                partition_name := v_partition_name;
                range_start := v_start::TEXT;
                range_end := v_end::TEXT;
                action := 'EXISTS';
                RETURN NEXT;
            END IF;
        END LOOP;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION maintenance.create_partitions(INT, INT) IS 'Creates monthly and daily partitions for all client schemas. Monthly: core business, report, audit sessions, affiliate tracking (+N months). Daily: log tables, audit login attempts (+N days). Idempotent.';
