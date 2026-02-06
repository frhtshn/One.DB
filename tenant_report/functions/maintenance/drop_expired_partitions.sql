-- ================================================================
-- DROP_EXPIRED_PARTITIONS: Suresi dolan partition'lari siler
-- tenant_report veritabani icin retention yonetimi
-- Aktif (bu ayin) partition'i ASLA silmez
-- Varsayilan retention: 36500 gun (~100 yil, is verisi)
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.drop_expired_partitions(INT);

CREATE OR REPLACE FUNCTION maintenance.drop_expired_partitions(
    p_retention_days INT DEFAULT 36500  -- Varsayilan retention: ~100 yil (is verisi, suresiz saklanir)
)
RETURNS TABLE (
    table_name TEXT,
    partition_name TEXT,
    partition_date DATE,
    action TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cutoff_date DATE;
    v_rec RECORD;
    v_partition_date DATE;
    v_date_str TEXT;
BEGIN
    -- Kesim tarihi: bugunden retention_days gun oncesi
    v_cutoff_date := CURRENT_DATE - p_retention_days;

    -- Partitioned tablolarin tum child partition'larini tara
    FOR v_rec IN
        SELECT
            pn.nspname AS parent_schema,
            pc.relname AS parent_table,
            cn.nspname AS child_schema,
            cc.relname AS child_table,
            cc.oid AS child_oid
        FROM pg_inherits i
        JOIN pg_class pc ON pc.oid = i.inhparent
        JOIN pg_namespace pn ON pn.oid = pc.relnamespace
        JOIN pg_class cc ON cc.oid = i.inhrelid
        JOIN pg_namespace cn ON cn.oid = cc.relnamespace
        WHERE pn.nspname IN ('finance', 'game')
          AND cc.relname NOT LIKE '%_default'  -- Default partition'i atla
        ORDER BY cc.relname
    LOOP
        -- Partition adindan tarihi cikar (format: tablo_yYYYYmMM)
        BEGIN
            v_date_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2})$', '\1-\2-01');
            v_partition_date := v_date_str::DATE;
        EXCEPTION
            WHEN OTHERS THEN
                -- Tarih formati uyumsuz partition'i atla
                CONTINUE;
        END;

        -- Guvenlik: Bu ayin partition'ini ASLA silme
        IF v_partition_date >= date_trunc('month', CURRENT_DATE)::DATE THEN
            CONTINUE;
        END IF;

        -- Retention suresini asan partition'lari sil
        IF v_partition_date < v_cutoff_date THEN
            EXECUTE format('DROP TABLE IF EXISTS %I.%I', v_rec.child_schema, v_rec.child_table);

            table_name := v_rec.parent_schema || '.' || v_rec.parent_table;
            partition_name := v_rec.child_schema || '.' || v_rec.child_table;
            partition_date := v_partition_date;
            action := 'DROPPED';
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION maintenance.drop_expired_partitions(INT) IS 'Drops monthly partitions older than retention period. Default retention ~100 years (business data). Never drops current month partition.';
