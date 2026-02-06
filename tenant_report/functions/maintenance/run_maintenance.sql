-- ================================================================
-- RUN_MAINTENANCE: Cron job icin ana bakim fonksiyonu
-- Yeni partition olusturma + suresi dolan partition silme
-- Tek cagriyla tum bakim islemlerini yapar
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.run_maintenance(INT, INT);

CREATE OR REPLACE FUNCTION maintenance.run_maintenance(
    p_retention_days INT DEFAULT 36500,  -- Retention suresi (~100 yil, is verisi)
    p_look_ahead_months INT DEFAULT 3    -- Kac ay ileri partition olustur
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
    -- 1. Yeni partition'lari olustur
    FOR v_rec IN SELECT * FROM maintenance.create_partitions(p_look_ahead_months) LOOP
        IF v_rec.action = 'CREATED' THEN
            operation := 'CREATE';
            table_name := v_rec.table_name;
            partition_name := v_rec.partition_name;
            detail := format('Range: %s - %s', v_rec.range_start, v_rec.range_end);
            RETURN NEXT;
        END IF;
    END LOOP;

    -- 2. Suresi dolan partition'lari sil
    FOR v_rec IN SELECT * FROM maintenance.drop_expired_partitions(p_retention_days) LOOP
        operation := 'DROP';
        table_name := v_rec.table_name;
        partition_name := v_rec.partition_name;
        detail := format('Partition date: %s (retention: %s days)', v_rec.partition_date, p_retention_days);
        RETURN NEXT;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION maintenance.run_maintenance(INT, INT) IS 'Main maintenance function for cron jobs. Creates future monthly partitions and drops expired ones in a single call.';
