-- ================================================================
-- RUN_MAINTENANCE: Cron job için ana bakım fonksiyonu
-- Finance veritabanı: Partition oluşturma + silme
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.run_maintenance(INT, INT);

CREATE OR REPLACE FUNCTION maintenance.run_maintenance(
    p_retention_days INT DEFAULT 14,    -- 14 gün retention
    p_look_ahead_days INT DEFAULT 14   -- 14 gün ileri partition
)
RETURNS TABLE (
    operation TEXT,
    table_name TEXT,
    partition_name TEXT,
    detail TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rec RECORD;
BEGIN
    -- 1. Yeni partition'ları oluştur
    FOR v_rec IN SELECT * FROM maintenance.create_partitions(p_look_ahead_days) LOOP
        IF v_rec.action = 'CREATED' THEN
            operation := 'CREATE';
            table_name := v_rec.table_name;
            partition_name := v_rec.partition_name;
            detail := format('Range: %s - %s', v_rec.range_start, v_rec.range_end);
            RETURN NEXT;
        END IF;
    END LOOP;

    -- 2. Süresi dolan partition'ları sil
    FOR v_rec IN SELECT * FROM maintenance.drop_expired_partitions(p_retention_days) LOOP
        operation := 'DROP';
        table_name := v_rec.table_name;
        partition_name := v_rec.partition_name;
        detail := format('Partition date: %s', v_rec.partition_date);
        RETURN NEXT;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION maintenance.run_maintenance(INT, INT) IS 'Main maintenance for finance DB. Creates daily partitions and drops expired ones for finance_log tables. Default: 14-day retention, 14-day look-ahead.';
