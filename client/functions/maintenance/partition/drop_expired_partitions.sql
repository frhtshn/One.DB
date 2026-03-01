-- ================================================================
-- DROP_EXPIRED_PARTITIONS: Süresi dolan partition'ları siler
-- Tüm schema'lar için birleşik retention yönetimi
-- Tablo bazlı retention desteği (her tablo kendi süresiyle)
-- Aktif gün/ayın partition'ını ASLA silmez
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
    v_is_daily BOOLEAN;
BEGIN
    -- Tablo bazlı retention tanımları
    -- retention_days: Kaç gün geriye tutulsun
    -- is_daily: true = daily partition (yYYYYmMMdDD), false = monthly (yYYYYmMM)
    FOR v_tbl IN
        SELECT * FROM (VALUES
            -- Core Business (monthly)
            ('transaction',     36500, false),  -- ~100 yıl (finansal - sınırsız)
            ('messaging',       180,   false),  -- 6 ay (oyuncu mesajları)
            -- Log (daily)
            ('affiliate_log',   90,    true),   -- 90 gün
            ('bonus_log',       90,    true),   -- 90 gün
            ('kyc_log',         90,    true),   -- 90 gün (KYC compliance)
            ('messaging_log',   90,    true),   -- 90 gün
            ('game_log',        30,    true),   -- 30 gün (yüksek hacim)
            ('support_log',     90,    true),   -- 90 gün
            -- Audit
            ('player_audit',    1825,  false),  -- 5 yıl (login sessions - monthly)
            -- player_audit login_attempts handled separately below
            -- Report (monthly - sınırsız)
            ('finance_report',  36500, false),  -- sınırsız
            ('game_report',     36500, false),  -- sınırsız
            ('support_report',  36500, false),  -- sınırsız
            -- Affiliate Tracking (monthly - sınırsız)
            ('tracking',        36500, false)   -- sınırsız
        ) AS t(schema_name, default_retention, is_daily)
    LOOP
        v_cutoff_date := CURRENT_DATE - COALESCE(p_retention_days, v_tbl.default_retention);
        v_is_daily := v_tbl.is_daily;

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
                IF v_is_daily THEN
                    -- Daily: _yYYYYmMMdDD
                    v_year_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2})d(\d{2})$', '\1');
                    v_month_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2})d(\d{2})$', '\2');
                    v_day_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2})d(\d{2})$', '\3');
                    v_partition_date := make_date(v_year_str::INT, v_month_str::INT, v_day_str::INT);

                    -- Bugünün partition'ını ASLA silme
                    IF v_partition_date >= CURRENT_DATE THEN
                        CONTINUE;
                    END IF;
                ELSE
                    -- Monthly: _yYYYYmMM
                    v_year_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2}).*$', '\1');
                    v_month_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2}).*$', '\2');
                    v_partition_date := make_date(v_year_str::INT, v_month_str::INT, 1);

                    -- Bu ayın partition'ını ASLA silme
                    IF v_partition_date >= date_trunc('month', CURRENT_DATE)::DATE THEN
                        CONTINUE;
                    END IF;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    CONTINUE;
            END;

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

    -- player_audit.login_attempts ayrı (daily, 365 gün retention)
    v_cutoff_date := CURRENT_DATE - COALESCE(p_retention_days, 365);
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
          AND pc.relname = 'login_attempts'
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
END;
$$;

COMMENT ON FUNCTION maintenance.drop_expired_partitions(INT) IS 'Drops expired partitions across all schemas. Retention: game_log 30d, other logs 90d, audit attempts 365d, audit sessions 5yr, report/tracking/transactions unlimited. Override with p_retention_days. Never drops current period.';
