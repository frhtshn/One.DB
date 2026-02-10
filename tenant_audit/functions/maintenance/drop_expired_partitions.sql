-- ================================================================
-- DROP_EXPIRED_PARTITIONS: Süresi dolan partition'ları siler
-- tenant_audit veritabanı için retention yönetimi
-- login_attempts: günlük partition, varsayılan 365 gün retention
-- login_sessions: aylık partition, varsayılan 1825 gün (5 yıl) retention
-- Aktif partition'ı ASLA silmez
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.drop_expired_partitions(INT, INT);

CREATE OR REPLACE FUNCTION maintenance.drop_expired_partitions(
    p_daily_retention_days INT DEFAULT 365,     -- Günlük tablolar retention (gün)
    p_monthly_retention_days INT DEFAULT 1825   -- Aylık tablolar retention (gün, ~5 yıl)
)
RETURNS TABLE (
    table_name TEXT,
    partition_name TEXT,
    partition_date TEXT,
    action TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_daily_cutoff DATE;
    v_monthly_cutoff DATE;
    v_rec RECORD;
    v_partition_date DATE;
    v_date_str TEXT;
    v_year_str TEXT;
    v_month_str TEXT;
    v_is_daily BOOLEAN;
BEGIN
    v_daily_cutoff := CURRENT_DATE - p_daily_retention_days;
    v_monthly_cutoff := CURRENT_DATE - p_monthly_retention_days;

    -- Partitioned tabloların tüm child partition'larını tara
    FOR v_rec IN
        SELECT
            pn.nspname AS parent_schema,
            pc.relname AS parent_table,
            cn.nspname AS child_schema,
            cc.relname AS child_table
        FROM pg_inherits i
        JOIN pg_class pc ON pc.oid = i.inhparent
        JOIN pg_namespace pn ON pn.oid = pc.relnamespace
        JOIN pg_class cc ON cc.oid = i.inhrelid
        JOIN pg_namespace cn ON cn.oid = cc.relnamespace
        WHERE pn.nspname = 'player_audit'
          AND cc.relname NOT LIKE '%_default'
        ORDER BY cc.relname
    LOOP
        -- Günlük mü aylık mı? (dDD varsa günlük)
        v_is_daily := v_rec.child_table ~ '_y\d{4}m\d{2}d\d{2}$';

        BEGIN
            IF v_is_daily THEN
                -- Günlük: _yYYYYmMMdDD
                v_date_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2})d(\d{2})$', '\1-\2-\3');
                v_partition_date := v_date_str::DATE;

                -- Güvenlik: Bugünün partition'ını ASLA silme
                IF v_partition_date >= CURRENT_DATE THEN
                    CONTINUE;
                END IF;

                -- Retention kontrolü
                IF v_partition_date < v_daily_cutoff THEN
                    EXECUTE format('DROP TABLE IF EXISTS %I.%I', v_rec.child_schema, v_rec.child_table);
                    table_name := v_rec.parent_schema || '.' || v_rec.parent_table;
                    partition_name := v_rec.child_schema || '.' || v_rec.child_table;
                    partition_date := v_partition_date::TEXT;
                    action := 'DROPPED';
                    RETURN NEXT;
                END IF;
            ELSE
                -- Aylık: _yYYYYmMM
                v_year_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2})$', '\1');
                v_month_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2})$', '\2');
                v_partition_date := make_date(v_year_str::INT, v_month_str::INT, 1);

                -- Güvenlik: Bu ayın partition'ını ASLA silme
                IF v_partition_date >= date_trunc('month', CURRENT_DATE)::DATE THEN
                    CONTINUE;
                END IF;

                -- Retention kontrolü
                IF v_partition_date < v_monthly_cutoff THEN
                    EXECUTE format('DROP TABLE IF EXISTS %I.%I', v_rec.child_schema, v_rec.child_table);
                    table_name := v_rec.parent_schema || '.' || v_rec.parent_table;
                    partition_name := v_rec.child_schema || '.' || v_rec.child_table;
                    partition_date := v_partition_date::TEXT;
                    action := 'DROPPED';
                    RETURN NEXT;
                END IF;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                CONTINUE;
        END;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION maintenance.drop_expired_partitions(INT, INT) IS 'Drops expired partitions for tenant_audit. Daily tables: default 365 days. Monthly tables: default 5 years. Never drops active partitions.';
