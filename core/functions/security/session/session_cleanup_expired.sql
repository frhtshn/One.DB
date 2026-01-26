-- ================================================================
-- SESSION_CLEANUP_EXPIRED: Suresi dolmus veya revoked session'lari temizler
-- Batch processing ile buyuk tablolarda lock sorunlarini onler
-- ================================================================

DROP FUNCTION IF EXISTS security.session_cleanup_expired(INT, INT);

CREATE OR REPLACE FUNCTION security.session_cleanup_expired(
    p_batch_size INT DEFAULT 1000,
    p_revoked_retention_days INT DEFAULT 7
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_expired_deleted INT := 0;
    v_revoked_deleted INT := 0;
    v_total_deleted INT := 0;
BEGIN
    -- 1. Suresi dolmus session'lari sil (batch ile)
    WITH deleted_expired AS (
        DELETE FROM security.user_sessions
        WHERE id IN (
            SELECT id FROM security.user_sessions
            WHERE expires_at < NOW()
            LIMIT p_batch_size
        )
        RETURNING 1
    )
    SELECT COUNT(*) INTO v_expired_deleted FROM deleted_expired;

    -- 2. Eski revoked session'lari sil (audit icin belirli sure tutulur)
    WITH deleted_revoked AS (
        DELETE FROM security.user_sessions
        WHERE id IN (
            SELECT id FROM security.user_sessions
            WHERE is_revoked = TRUE
              AND revoked_at < NOW() - (p_revoked_retention_days || ' days')::INTERVAL
            LIMIT p_batch_size
        )
        RETURNING 1
    )
    SELECT COUNT(*) INTO v_revoked_deleted FROM deleted_revoked;

    v_total_deleted := v_expired_deleted + v_revoked_deleted;

    RETURN jsonb_build_object(
        'success', true,
        'expiredDeleted', v_expired_deleted,
        'revokedDeleted', v_revoked_deleted,
        'totalDeleted', v_total_deleted,
        'hasMore', v_total_deleted >= p_batch_size
    );
END;
$$;

COMMENT ON FUNCTION security.session_cleanup_expired IS 'Cleans up expired and old revoked sessions securely using batches to avoid table locks.';
