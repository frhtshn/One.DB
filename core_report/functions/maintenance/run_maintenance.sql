-- ================================================================
-- RUN_MAINTENANCE: Tüm partition bakım işlemlerini çalıştırır
-- Yeni partition oluşturma ve süresi dolmuş partition silme
-- işlemlerini tek seferde gerçekleştirir.
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.run_maintenance(INT, INT);

CREATE OR REPLACE FUNCTION maintenance.run_maintenance(
    p_look_ahead_months INT DEFAULT 3,        -- Kaç ay ileriye partition oluşturulsun
    p_retention_days INT DEFAULT 36500         -- Saklama süresi (gün)
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_create_result JSONB;
    v_drop_result JSONB;
    v_partition_summary JSONB;
BEGIN
    -- 1. Yeni partition'ları oluştur
    v_create_result := maintenance.create_partitions(p_look_ahead_months);

    -- 2. Süresi dolmuş partition'ları sil
    v_drop_result := maintenance.drop_expired_partitions(p_retention_days);

    -- 3. Mevcut partition özeti
    SELECT jsonb_build_object(
        'total_partitions', COUNT(*),
        'default_partitions', COUNT(*) FILTER (WHERE is_default),
        'by_schema', jsonb_object_agg(
            schema_group,
            partition_count
        )
    )
    INTO v_partition_summary
    FROM (
        SELECT
            parent_schema AS schema_group,
            COUNT(*) AS partition_count,
            BOOL_OR(is_default) AS is_default
        FROM maintenance.partition_info()
        GROUP BY parent_schema
    ) summary;

    RETURN jsonb_build_object(
        'create_result', v_create_result,
        'drop_result', v_drop_result,
        'partition_summary', COALESCE(v_partition_summary, '{}'::JSONB),
        'executed_at', NOW()
    );
END;
$$;

COMMENT ON FUNCTION maintenance.run_maintenance IS 'Runs complete partition maintenance: creates future partitions and drops expired ones. Should be scheduled as a periodic job (e.g., weekly or monthly). Returns JSONB with combined results.';
