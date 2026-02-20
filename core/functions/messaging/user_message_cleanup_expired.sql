-- ================================================================
-- USER_MESSAGE_CLEANUP_EXPIRED: Süresi dolmuş mesajları soft-delete eder
-- Batch bazlı çalışır, SKIP LOCKED ile concurrent-safe
-- MessageCleanupService tarafından periyodik olarak çağrılır
-- ================================================================

DROP FUNCTION IF EXISTS messaging.user_message_cleanup_expired(INTEGER);

CREATE OR REPLACE FUNCTION messaging.user_message_cleanup_expired(
    p_batch_size INTEGER DEFAULT 10000
)
RETURNS INTEGER
AS $$
DECLARE
    v_affected INTEGER;
BEGIN
    UPDATE messaging.user_messages
    SET is_deleted = TRUE, deleted_at = NOW()
    WHERE ctid IN (
        SELECT ctid FROM messaging.user_messages
        WHERE expires_at IS NOT NULL
          AND expires_at < NOW()
          AND is_deleted = FALSE
        LIMIT p_batch_size
        FOR UPDATE SKIP LOCKED
    );

    GET DIAGNOSTICS v_affected = ROW_COUNT;
    RETURN v_affected;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION messaging.user_message_cleanup_expired(INTEGER) IS 'Soft-deletes expired messages in batches. Uses SKIP LOCKED for concurrent safety. Returns number of affected rows.';
