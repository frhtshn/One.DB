-- ================================================================
-- SESSION_ENFORCE_LIMIT: Atomic session limit kontrolu
-- Limit asilmissa en eski (en az aktif) session'i revoke eder.
-- Asilmamissa NULL doner.
-- ================================================================

DROP FUNCTION IF EXISTS security.session_enforce_limit(BIGINT, INT);

CREATE OR REPLACE FUNCTION security.session_enforce_limit(
    p_user_id      BIGINT,
    p_max_sessions INT
)
RETURNS VARCHAR(50)
LANGUAGE plpgsql
AS $$
DECLARE
    v_session_count INT;
    v_oldest_session_id VARCHAR(50);
    v_oldest_created_at TIMESTAMPTZ;
BEGIN
    SELECT COUNT(*) INTO v_session_count
    FROM security.user_sessions
    WHERE user_id = p_user_id
      AND is_revoked = FALSE
      AND expires_at > NOW();

    IF v_session_count < p_max_sessions THEN
        RETURN NULL;
    END IF;

    SELECT id, created_at
    INTO v_oldest_session_id, v_oldest_created_at
    FROM security.user_sessions
    WHERE user_id = p_user_id
      AND is_revoked = FALSE
      AND expires_at > NOW()
    ORDER BY last_activity_at ASC
    LIMIT 1;

    UPDATE security.user_sessions
    SET is_revoked = TRUE,
        revoked_at = NOW(),
        revoke_reason = 'Session limit exceeded - oldest session closed'
    WHERE id = v_oldest_session_id
      AND created_at = v_oldest_created_at;

    RETURN v_oldest_session_id;
END;
$$;

COMMENT ON FUNCTION security.session_enforce_limit IS 'Atomic session limit enforcement - revokes oldest session if limit exceeded';
