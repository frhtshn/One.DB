-- ================================================================
-- DROP_EXPIRED_PARTITIONS: Süresi dolan partition'ları siler
-- Core veritabanı: Monthly + Daily retention yönetimi
-- Tablo bazlı retention desteği (her tablo kendi süresiyle)
-- Aktif ayın/günün partition'ını ASLA silmez
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.drop_expired_partitions(INT);

CREATE OR REPLACE FUNCTION maintenance.drop_expired_partitions(
    p_retention_days INT DEFAULT NULL  -- NULL = tablo bazlı varsayılanlar, INT = global override
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
    v_cutoff_date DATE;
    v_rec RECORD;
    v_tbl RECORD;
    v_partition_date DATE;
    v_year_str TEXT;
    v_month_str TEXT;
    v_day_str TEXT;
BEGIN
    -- ============================================================
    -- MONTHLY PARTITIONS
    -- ============================================================
    FOR v_tbl IN
        SELECT * FROM (VALUES
            ('messaging', 180),        -- 6 ay (kullanıcı mesajları)
            ('security', 90),          -- 3 ay (kullanıcı oturumları)
            ('performance', 36500),    -- ~100 yıl (sınırsız)
            ('finance_report', 36500), -- ~100 yıl (sınırsız)
            ('billing_report', 36500)  -- ~100 yıl (sınırsız)
        ) AS t(schema_name, default_retention)
    LOOP
        v_cutoff_date := CURRENT_DATE - COALESCE(p_retention_days, v_tbl.default_retention);

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
            WHERE pn.nspname = v_tbl.schema_name
              AND cc.relname NOT LIKE '%_default'
            ORDER BY cc.relname
        LOOP
            BEGIN
                v_year_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2}).*$', '\1');
                v_month_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2}).*$', '\2');
                v_partition_date := make_date(v_year_str::INT, v_month_str::INT, 1);
            EXCEPTION
                WHEN OTHERS THEN
                    CONTINUE;
            END;

            -- Güvenlik: Bu ayın partition'ını ASLA silme
            IF v_partition_date >= date_trunc('month', CURRENT_DATE)::DATE THEN
                CONTINUE;
            END IF;

            IF v_partition_date < v_cutoff_date THEN
                EXECUTE format('DROP TABLE IF EXISTS %I.%I', v_rec.child_schema, v_rec.child_table);

                table_name := v_rec.parent_schema || '.' || v_rec.parent_table;
                partition_name := v_rec.child_schema || '.' || v_rec.child_table;
                partition_date := v_partition_date::TEXT;
                action := 'DROPPED';
                RETURN NEXT;
            END IF;
        END LOOP;
    END LOOP;

    -- ============================================================
    -- DAILY PARTITIONS
    -- ============================================================
    FOR v_tbl IN
        SELECT * FROM (VALUES
            ('logs', 90),              -- 3 ay (system logs)
            ('backoffice_log', 90),    -- 3 ay (backoffice activity logs)
            ('backoffice_audit', 90)   -- 3 ay (auth audit logs)
        ) AS t(schema_name, default_retention)
    LOOP
        v_cutoff_date := CURRENT_DATE - COALESCE(p_retention_days, v_tbl.default_retention);

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
            WHERE pn.nspname = v_tbl.schema_name
              AND cc.relname NOT LIKE '%_default'
            ORDER BY cc.relname
        LOOP
            BEGIN
                v_year_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2})d(\d{2})$', '\1');
                v_month_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2})d(\d{2})$', '\2');
                v_day_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2})d(\d{2})$', '\3');
                v_partition_date := make_date(v_year_str::INT, v_month_str::INT, v_day_str::INT);
            EXCEPTION
                WHEN OTHERS THEN
                    CONTINUE;
            END;

            -- Güvenlik: Bugünün partition'ını ASLA silme
            IF v_partition_date >= CURRENT_DATE THEN
                CONTINUE;
            END IF;

            IF v_partition_date < v_cutoff_date THEN
                EXECUTE format('DROP TABLE IF EXISTS %I.%I', v_rec.child_schema, v_rec.child_table);

                table_name := v_rec.parent_schema || '.' || v_rec.parent_table;
                partition_name := v_rec.child_schema || '.' || v_rec.child_table;
                partition_date := v_partition_date::TEXT;
                action := 'DROPPED';
                RETURN NEXT;
            END IF;
        END LOOP;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION maintenance.drop_expired_partitions(INT) IS 'Drops expired monthly and daily partitions. Monthly: messaging=180d, security=90d, report=unlimited. Daily: logs/backoffice_log/backoffice_audit=90d. Override with p_retention_days. Never drops current period.';
