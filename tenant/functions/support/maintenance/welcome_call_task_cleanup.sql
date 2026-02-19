-- ================================================================
-- WELCOME_CALL_TASK_CLEANUP: Tamamlanan görevleri temizle
-- ================================================================
-- Completed veya failed durumundaki eski görevleri siler.
-- Retention süresi aşılmış kayıtları batch olarak temizler.
-- SKIP LOCKED ile concurrent güvenli.
-- ================================================================

DROP FUNCTION IF EXISTS support.welcome_call_task_cleanup(INT, INT);

CREATE OR REPLACE FUNCTION support.welcome_call_task_cleanup(
    p_retention_days    INT DEFAULT 180,
    p_batch_size        INT DEFAULT 500
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_deleted   INT;
BEGIN
    -- Tamamlanan veya başarısız görevleri sil
    DELETE FROM support.welcome_call_tasks
    WHERE id IN (
        SELECT id
        FROM support.welcome_call_tasks
        WHERE status IN ('completed', 'failed')
          AND updated_at < NOW() - (p_retention_days || ' days')::INTERVAL
        LIMIT p_batch_size
        FOR UPDATE SKIP LOCKED
    );

    GET DIAGNOSTICS v_deleted = ROW_COUNT;

    RETURN v_deleted;
END;
$$;

COMMENT ON FUNCTION support.welcome_call_task_cleanup IS 'Deletes completed/failed welcome call tasks older than retention period. Uses batch processing with SKIP LOCKED for concurrency safety.';
