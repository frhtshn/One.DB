-- ================================================================
-- LOGIN_SESSION_UPDATE_ACTIVITY: Oturum son aktivite zamanını günceller
-- Her istek/aktivitede çağrılabilir
-- ================================================================

DROP FUNCTION IF EXISTS player_audit.login_session_update_activity(UUID);

CREATE OR REPLACE FUNCTION player_audit.login_session_update_activity(
    p_session_token UUID       -- Oturum token'ı
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE player_audit.login_sessions
    SET last_activity_at = NOW()
    WHERE session_token = p_session_token
      AND is_active = TRUE;
END;
$$;

COMMENT ON FUNCTION player_audit.login_session_update_activity IS 'Updates last activity timestamp for an active player session';
