-- ================================================================
-- SESSION_CLEANUP_EXPIRED - Expire/Revoked/Inactive Session Cleanup
-- Called by SessionCleanupService
-- PostgreSQL compatible, batch-safe version
-- GÜNCELLENDİ: PK-based DELETE (partitioned tablo uyumlu)
-- ================================================================

DROP FUNCTION IF EXISTS security.session_cleanup_expired(INT, INT, INT);

CREATE OR REPLACE FUNCTION security.session_cleanup_expired(
    p_batch_size INT DEFAULT 1000,
    p_revoked_retention_days INT DEFAULT 7,
    p_inactivity_days INT DEFAULT 5
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_now TIMESTAMPTZ := NOW();
    v_expired_deleted  INT := 0;
    v_revoked_deleted  INT := 0;
    v_inactive_deleted INT := 0;
    v_has_more BOOLEAN := FALSE;
BEGIN
    -- 1. Expired sessions
    WITH to_delete AS (
        SELECT id, created_at
        FROM security.user_sessions
        WHERE is_revoked = FALSE
          AND expires_at < v_now
        ORDER BY expires_at
        LIMIT p_batch_size
    ),
    deleted AS (
        DELETE FROM security.user_sessions s
        USING to_delete d
        WHERE s.id = d.id AND s.created_at = d.created_at
        RETURNING 1
    )
    SELECT COUNT(*) INTO v_expired_deleted FROM deleted;

    -- 2. Old revoked sessions
    WITH to_delete AS (
        SELECT id, created_at
        FROM security.user_sessions
        WHERE is_revoked = TRUE
          AND revoked_at < v_now - (p_revoked_retention_days || ' days')::INTERVAL
        ORDER BY revoked_at
        LIMIT p_batch_size
    ),
    deleted AS (
        DELETE FROM security.user_sessions s
        USING to_delete d
        WHERE s.id = d.id AND s.created_at = d.created_at
        RETURNING 1
    )
    SELECT COUNT(*) INTO v_revoked_deleted FROM deleted;

    -- 3. Inactive sessions (not expired yet)
    IF p_inactivity_days > 0 THEN
        WITH to_delete AS (
            SELECT id, created_at
            FROM security.user_sessions
            WHERE is_revoked = FALSE
              AND last_activity_at < v_now - (p_inactivity_days || ' days')::INTERVAL
              AND expires_at > v_now
            ORDER BY last_activity_at
            LIMIT p_batch_size
        ),
        deleted AS (
            DELETE FROM security.user_sessions s
            USING to_delete d
            WHERE s.id = d.id AND s.created_at = d.created_at
            RETURNING 1
        )
        SELECT COUNT(*) INTO v_inactive_deleted FROM deleted;
    END IF;

    -- Has more check (EXISTS, no COUNT)
    SELECT EXISTS (
        SELECT 1
        FROM security.user_sessions
        WHERE (is_revoked = FALSE AND expires_at < v_now)
           OR (is_revoked = TRUE AND revoked_at < v_now - (p_revoked_retention_days || ' days')::INTERVAL)
           OR (
                p_inactivity_days > 0
                AND is_revoked = FALSE
                AND last_activity_at < v_now - (p_inactivity_days || ' days')::INTERVAL
                AND expires_at > v_now
           )
    ) INTO v_has_more;

    RETURN jsonb_build_object(
        'success', TRUE,
        'expiredDeleted', v_expired_deleted,
        'revokedDeleted', v_revoked_deleted,
        'inactiveDeleted', v_inactive_deleted,
        'totalDeleted', v_expired_deleted + v_revoked_deleted + v_inactive_deleted,
        'hasMore', v_has_more
    );
END;
$$;

COMMENT ON FUNCTION security.session_cleanup_expired
IS 'Cleans up expired, old revoked, and inactive session records in batches. Uses PK-based delete for partitioned table compatibility.';
