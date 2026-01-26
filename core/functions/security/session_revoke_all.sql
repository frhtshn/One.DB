-- ================================================================
-- SESSION_REVOKE_ALL: Kullanıcının tüm oturumlarını sonlandır
-- ================================================================

DROP FUNCTION IF EXISTS security.session_revoke_all(BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION security.session_revoke_all(
    p_user_id BIGINT,
    p_reason VARCHAR(200) DEFAULT 'User requested logout all',
    p_except_session_id VARCHAR(50) DEFAULT NULL
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    UPDATE security.user_sessions
    SET
        is_revoked = TRUE,
        revoked_at = NOW(),
        revoke_reason = p_reason
    WHERE user_id = p_user_id
    AND is_revoked = FALSE
    AND (p_except_session_id IS NULL OR id != p_except_session_id);

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION security.session_revoke_all IS 'Revokes all sessions for a user (optionally keeping current one)';
