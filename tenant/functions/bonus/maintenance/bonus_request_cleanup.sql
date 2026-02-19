-- ================================================================
-- BONUS_REQUEST_CLEANUP: İptal/expire talepleri temizle (retention)
-- ================================================================
-- cancelled veya expired durumundaki talepleri belirli süre sonra
-- siler. completed ve rejected talepler ASLA silinmez (cooldown
-- hesabı için geçmiş veri gereklidir).
-- Haftalık cron ile çağrılır (Bonus Worker).
-- Auth-agnostic.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_cleanup(INT, INT);

CREATE OR REPLACE FUNCTION bonus.bonus_request_cleanup(
    p_retention_days    INT DEFAULT 90,
    p_batch_size        INT DEFAULT 500
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_deleted_count INT := 0;
    v_request_id    BIGINT;
BEGIN
    FOR v_request_id IN
        SELECT id
        FROM bonus.bonus_requests
        WHERE status IN ('cancelled', 'expired')
          AND updated_at + (p_retention_days || ' days')::INTERVAL < NOW()
        LIMIT p_batch_size
        FOR UPDATE SKIP LOCKED
    LOOP
        -- Önce aksiyonları sil
        DELETE FROM bonus.bonus_request_actions
        WHERE request_id = v_request_id;

        -- Sonra talebi sil
        DELETE FROM bonus.bonus_requests
        WHERE id = v_request_id;

        v_deleted_count := v_deleted_count + 1;
    END LOOP;

    RETURN v_deleted_count;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_cleanup IS 'Deletes cancelled/expired bonus requests older than retention period. Never deletes completed/rejected requests (needed for cooldown calculation). Called weekly by Bonus Worker.';
