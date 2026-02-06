-- ================================================================
-- DROP_EXPIRED_PARTITIONS: Süresi dolan partition'ları siler
-- tenant veritabanı için retention yönetimi
-- Varsayılan: Sınırsız retention (finansal işlemler)
-- Aktif ayın partition'ını ASLA silmez
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.drop_expired_partitions(INT);

CREATE OR REPLACE FUNCTION maintenance.drop_expired_partitions(
    p_retention_days INT DEFAULT 36500  -- Varsayılan: ~100 yıl (sınırsız retention)
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
    v_partition_date DATE;
    v_year_str TEXT;
    v_month_str TEXT;
BEGIN
    v_cutoff_date := CURRENT_DATE - p_retention_days;

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
        WHERE pn.nspname = 'transaction'
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
END;
$$;

COMMENT ON FUNCTION maintenance.drop_expired_partitions(INT) IS 'Drops monthly partitions older than retention period. Default: indefinite (financial ledger data). Never drops current month.';
