-- ================================================================
-- BONUS_REQUEST_EXPIRE: Süresi dolan talepleri expire et (batch)
-- ================================================================
-- pending veya assigned durumunda olup expires_at geçmiş olan
-- talepleri expired durumuna geçirir. SKIP LOCKED ile concurrent
-- çalışma güvenlidir. Günlük cron ile çağrılır (Bonus Worker).
-- Auth-agnostic.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_expire(INT);

CREATE OR REPLACE FUNCTION bonus.bonus_request_expire(
    p_batch_size INT DEFAULT 100
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_expired_count INT := 0;
    v_request_id    BIGINT;
BEGIN
    FOR v_request_id IN
        SELECT id
        FROM bonus.bonus_requests
        WHERE status IN ('pending', 'assigned')
          AND expires_at IS NOT NULL
          AND expires_at < NOW()
        LIMIT p_batch_size
        FOR UPDATE SKIP LOCKED
    LOOP
        UPDATE bonus.bonus_requests SET
            status = 'expired',
            updated_at = NOW()
        WHERE id = v_request_id;

        INSERT INTO bonus.bonus_request_actions (
            request_id, action, performed_by_id, performed_by_type, created_at
        ) VALUES (
            v_request_id, 'EXPIRED', NULL, 'SYSTEM', NOW()
        );

        v_expired_count := v_expired_count + 1;
    END LOOP;

    RETURN v_expired_count;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_expire IS 'Batch expires pending/assigned bonus requests past their expiration date. Uses SKIP LOCKED for concurrency safety. Called daily by Bonus Worker.';
