-- ================================================================
-- LOGIN_SESSION_END_ALL: Oyuncunun tüm aktif oturumlarını sonlandırır
-- Admin tarafından zorunlu çıkış veya güvenlik müdahalesi
-- İsteğe bağlı olarak belirli bir oturum hariç tutulabilir
-- ================================================================

DROP FUNCTION IF EXISTS player_audit.login_session_end_all(BIGINT,VARCHAR,UUID);

CREATE OR REPLACE FUNCTION player_audit.login_session_end_all(
    p_player_id BIGINT,                              -- Player ID
    p_logout_type VARCHAR(20) DEFAULT 'FORCED',      -- Çıkış tipi
    p_exclude_token UUID DEFAULT NULL                 -- Hariç tutulacak oturum (mevcut oturum)
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    UPDATE player_audit.login_sessions
    SET
        logout_at = NOW(),
        logout_type = p_logout_type,
        is_active = FALSE
    WHERE player_id = p_player_id
      AND is_active = TRUE
      AND (p_exclude_token IS NULL OR session_token != p_exclude_token);

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION player_audit.login_session_end_all IS 'Ends all active sessions for a player. Optionally excludes one session. Returns count of ended sessions.';
