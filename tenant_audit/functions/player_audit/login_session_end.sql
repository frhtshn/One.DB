-- ================================================================
-- LOGIN_SESSION_END: Oyuncu oturumunu sonlandırır
-- Çıkış, timeout veya admin tarafından zorunlu sonlandırma
-- ================================================================

DROP FUNCTION IF EXISTS player_audit.login_session_end(UUID,VARCHAR);

CREATE OR REPLACE FUNCTION player_audit.login_session_end(
    p_session_token UUID,                    -- Oturum token'ı
    p_logout_type VARCHAR(20) DEFAULT 'MANUAL'  -- Çıkış tipi: MANUAL, TIMEOUT, FORCED, TOKEN_EXPIRED
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_updated BOOLEAN;
BEGIN
    UPDATE player_audit.login_sessions
    SET
        logout_at = NOW(),
        logout_type = p_logout_type,
        is_active = FALSE
    WHERE session_token = p_session_token
      AND is_active = TRUE;

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    RETURN v_updated > 0;
END;
$$;

COMMENT ON FUNCTION player_audit.login_session_end IS 'Ends an active player session. Returns TRUE if session was active and ended.';
