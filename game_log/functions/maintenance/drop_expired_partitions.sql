-- ================================================================
-- DROP_EXPIRED_PARTITIONS: Süresi dolan partition'ları siler
-- game_log veritabanı için retention yönetimi
-- Aktif (bugünün) partition'ını ASLA silmez
-- Varsayılan retention: 7 gün (gateway logları kısa ömürlü)
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.drop_expired_partitions(INT);

CREATE OR REPLACE FUNCTION maintenance.drop_expired_partitions(
    p_retention_days INT DEFAULT 7  -- Varsayılan retention: 7 gün
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
    -- Kesim tarihi: bugünden retention_days gün öncesi
    v_cutoff_date := CURRENT_DATE - p_retention_days;

    -- Partitioned tabloların tüm child partition'larını tara
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
        WHERE pn.nspname IN ('game_log')
          AND cc.relname NOT LIKE '%_default'
        ORDER BY cc.relname
    LOOP
        -- Partition adından tarihi çıkar (format: tablo_yYYYYmMMdDD)
        BEGIN
            v_date_str := regexp_replace(v_rec.child_table, '.*_y(\d{4})m(\d{2})d(\d{2})$', '\1-\2-\3');
            v_partition_date := v_date_str::DATE;
        EXCEPTION
            WHEN OTHERS THEN
                -- Tarih formatı uyumsuz partition'ı atla
                CONTINUE;
        END;

        -- Güvenlik: Bugünün partition'ını ASLA silme
        IF v_partition_date >= CURRENT_DATE THEN
            CONTINUE;
        END IF;

        -- Retention süresini aşan partition'ları sil
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

COMMENT ON FUNCTION maintenance.drop_expired_partitions(INT) IS 'Drops daily partitions older than retention period (default 7 days). Never drops current day partition. Safety-first design.';
