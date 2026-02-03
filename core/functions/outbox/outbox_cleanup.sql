-- ================================================================
-- OUTBOX_CLEANUP: Eski kayıtları temizler
-- ================================================================

DROP FUNCTION IF EXISTS outbox.outbox_cleanup CASCADE;
CREATE OR REPLACE FUNCTION outbox.outbox_cleanup(
    p_retention_days INT DEFAULT 7
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_cutoff TIMESTAMPTZ;
    v_deleted_completed INT;
    v_deleted_failed INT;
BEGIN
    v_cutoff := NOW() - (p_retention_days || ' days')::INTERVAL;

    -- Completed olanları sil
    DELETE FROM outbox.messages
    WHERE status = 'completed' AND processed_at < v_cutoff;
    GET DIAGNOSTICS v_deleted_completed = ROW_COUNT;

    -- Max retry'a ulaşmış failed olanları sil
    DELETE FROM outbox.messages
    WHERE status = 'failed'
      AND retry_count >= max_retries
      AND processed_at < v_cutoff;
    GET DIAGNOSTICS v_deleted_failed = ROW_COUNT;

    RETURN jsonb_build_object(
        'deleted_completed', v_deleted_completed,
        'deleted_failed', v_deleted_failed,
        'cutoff_date', v_cutoff,
        'retention_days', p_retention_days,
        'executed_at', NOW()
    );
END;
$$;

COMMENT ON FUNCTION outbox.outbox_cleanup IS 'Removes old processed messages to prevent table bloat. Deletes completed and permanently failed messages older than retention period. Returns JSONB with deletion stats.';
