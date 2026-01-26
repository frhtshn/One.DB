-- ================================================================
-- SESSION_REVOKE: Belirli bir oturumu sonlandır
-- ================================================================

DROP FUNCTION IF EXISTS security.session_revoke(VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION security.session_revoke(
    p_session_id VARCHAR(50),
    p_reason VARCHAR(200) DEFAULT 'User requested'
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE security.user_sessions
    SET
        is_revoked = TRUE,
        revoked_at = NOW(),
        revoke_reason = p_reason
    WHERE id = p_session_id
    AND is_revoked = FALSE;

    RETURN FOUND;
END;
$$;

COMMENT ON FUNCTION security.session_revoke IS 'Revokes a specific session';
