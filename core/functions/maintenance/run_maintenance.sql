-- ================================================================
-- RUN_MAINTENANCE: Cron job için ana bakım fonksiyonu
-- Yeni partition oluşturma + süresi dolan partition silme
-- Tek çağrıyla tüm schema'lardaki bakım işlemlerini yapar
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.run_maintenance(INT, INT);
DROP FUNCTION IF EXISTS maintenance.run_maintenance(INT, INT, INT);

CREATE OR REPLACE FUNCTION maintenance.run_maintenance(
    p_retention_days INT DEFAULT NULL,  -- NULL = tablo bazlı varsayılanlar
    p_look_ahead_months INT DEFAULT 3,  -- Monthly tablolar için kaç ay ileri
    p_look_ahead_days INT DEFAULT 7     -- Daily tablolar için kaç gün ileri
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
    -- 1. Yeni partition'ları oluştur (monthly + daily)
    FOR v_rec IN SELECT * FROM maintenance.create_partitions(p_look_ahead_months, p_look_ahead_days) LOOP
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

COMMENT ON FUNCTION maintenance.run_maintenance(INT, INT, INT) IS 'Main maintenance function for cron jobs. Creates future partitions (monthly + daily) and drops expired ones across all core DB schemas. Per-table retention defaults or global override.';
